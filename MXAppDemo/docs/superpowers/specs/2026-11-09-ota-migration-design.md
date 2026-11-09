# OTA 能力迁移设计（mxapp_ios → MXAppDemo）

日期：2026-11-09  
状态：待用户确认后进入实现计划

## 背景与目标

将 `/Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp` 中的 OTA（固件升级）相关能力迁移到本项目 `MXAppDemo`，使设备可在 App 内完成 Wi‑Fi / BLE 固件升级。

**成功标准：**

- 设备详情可检查并进入固件 / MCU OTA
- Wi‑Fi OTA 与 BLE OTA 两条链路均可跑通
- 个人中心、工具批量 OTA、强制升级弹窗均无入口

## 范围

### 纳入

- Wi‑Fi OTA + BLE/Mesh OTA 完整流程页与执行逻辑
- 设备详情：固件版本 + MCU 版本两个入口（含新版本红点）
- OTA 模型、`MXAPI.OTA`、路由注册、Wi‑Fi MQTT 进度通知、固件缓存目录
- 复用本项目已有 `RTKOTA` Pod 声明与 OTA 本地化文案

### 不纳入

- 「我的 → 固件升级」列表（`MXOTAListViewController`）
- 工具页批量 OTA / 扫描 OTA 整套页面
- 打开控制面板时的强制升级弹窗
- 首页状态栏 OTA 入口

## 方案选择

采用 **按源项目结构原样迁入 + 本项目适配**：

- 业务代码从源项目对应模块拷贝并适配命名空间/依赖
- 仅在本项目设备详情接入入口
- 不精简重写核心流程，降低漏逻辑风险

## 架构

```
设备详情 MXDeviceDetailViewController
  ├─ 固件版本行 → checkDevice(iotId)
  └─ MCU 版本行 → checkDevice(iotId, module=mcu)
           │
           ▼ 有新版本且有权限
     gotoOTAPage(info)
           │
     ┌─────┴─────┐
 ota_type=1    ota_type=2
     │             │
 Wi‑Fi OTA页    BLE OTA页
 (确认+MQTT)   (下载+RTK DFU)
```

### 迁入模块

| 目标路径（MXAppDemo） | 来源 | 职责 |
|---|---|---|
| `MXApp/Modules/MXDeviceOTA/` | 同名模块（不含 List） | `MXWiFiOTAViewController`、`MXDeviceOTAViewController` |
| `MXApp/Modules/MXMeshOTA/` | 同名模块 | `MXMeshOTAHandle` BLE/RTK DFU |
| `MXApp/Modules/MXDevice/Models/MXOTAInfo.swift` | 源 Models | OTA 元数据 |
| `MXApp/Modules/MXBasicManager/MXAPI.swift` | 扩展 `MXAPI.OTA` | check / confirmation / cancel 等 |
| `MXApp/MXConfigs/MXRouterConfig.swift` | 增加路由 | `page/device/OTA`、`page/device/WiFiOTA` |
| 消息分发（HomeManager 或等价） | 源 MQTT 处理 | `ota_progress` / `ota_version` → Notification |
| App 启动处 | 源 AppDelegate | 创建 `Caches/firmwares` |

### 明确不迁文件

- `MXOTAListViewController` 及个人中心 OTA 红点/菜单逻辑
- `MXToolPages/MXMeshOTAPage/**` 批量 OTA
- 强制升级相关 UI 调用（`checkDeviceOTAVersion` 面板拦截）

## 设备详情接入

**文件：** `MXApp/Modules/MXDevice/Views/MXDeviceDetailViewController.swift`

1. 增加 `otaInfo`、`mcu_otaInfo`
2. 加载时 `loadDeviceOTAInfo()`：
   - 查主固件 OTA
   - 非 `gateway-sub` 再查 `module=mcu`
3. `updateDataSources()`：
   - 固件版本行始终展示（有当前版本则显示）
   - MCU 版本行有信息才展示
   - 有新版本：红点 + `disclosureIndicator`
4. `didSelectRowAt`：仅固件/MCU 行；有新版本且有操作权限时 `gotoOTAPage`
5. `gotoOTAPage`：
   - `ota_type == 1` → `https://com.mxchip.bta/page/device/WiFiOTA`
   - `ota_type == 2` → `https://com.mxchip.bta/page/device/OTA`
   - params：`iotId` / `device` / `info`（对齐源项目）
6. 分享设备或无操作权限：不可进入

## Wi‑Fi / BLE 流程

### Wi‑Fi（`ota_type == 1`）

1. 进入 `MXWiFiOTAViewController`
2. 用户确认 → `PUT app/v3/ota/upgrade/confirmation`
3. 监听 MQTT/Fog：`biz_code=ota_progress` → `WiFiOTAOngoing`；`ota_version` → `WiFiOTAFinish`
4. 可取消 → `PUT app/v3/ota/upgrade/cancel`
5. UI 与文案复用已有 `MXLocalizable` OTA keys

### BLE（`ota_type == 2`）

1. 进入 `MXDeviceOTAViewController`
2. 下载 `oss_url` 到 `Library/Caches/firmwares/`
3. `MXMeshOTAHandle` + `RTKOTA` 执行 DFU（扫描/连接/传输/升级）
4. 成功后调用设备版本上报（对齐源项目 `updateDeviceVersion`）
5. 离开页面时恢复 Mesh 连接（若本项目具备同等能力则对齐）

## 依赖与适配

| 项 | 说明 |
|---|---|
| `RTKOTA` | Podfile 已声明；实现前校验 `MXFrameworks/RTKOTA` 二进制完整性，缺失则从源 SDK 对齐 |
| 本地化 | 已有 `mx_OTA`、`mx_firmware_version`、`mx_mcu_version`、`mx_ota_step_*` 等，优先复用 |
| API | 在本项目 `MXAPI` 增加 `OTA` 命名空间，路径与源项目一致 |
| 路由 | `MXURLRouter` 注册两条设备 OTA 路由；不注册 OTAList / batchOTA |
| 通知 | Wi‑Fi 进度依赖现有消息通道；若本项目尚无 `ota_progress`/`ota_version` 分支则补上 |

## 错误处理

- 下载失败、蓝牙未开/连接失败、升级失败：沿用源项目提示与结束态
- 无新版本：详情行不可进入 OTA
- 无权限/分享设备：不可进入
- API 失败：toast / 页面内错误态，不崩溃

## 验证计划

- [ ] 设备详情展示固件版本；有 MCU 信息时展示 MCU 行
- [ ] 有新版本时红点可见，点击按 `ota_type` 进入对应页
- [ ] Wi‑Fi OTA：确认后进度更新，完成态正确；取消可用
- [ ] BLE OTA：下载 → DFU → 上报版本成功
- [ ] 无「我的→固件升级」、无批量 OTA、无强制升级弹窗
- [ ] 分享设备/无权限时无法进入 OTA

## 风险

- `RTKOTA` 二进制若不完整，BLE 链路无法编译/运行，需先对齐 framework
- 本项目 MQTT/Fog 消息结构若与源项目略有差异，需在消息分发处做字段适配
- 权限字段（分享设备、操作权限）命名若不一致，需对照本项目 `MXDeviceInfo` 适配

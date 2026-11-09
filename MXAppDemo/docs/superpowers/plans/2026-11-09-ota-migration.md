# OTA Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将 mxapp_ios 的 Wi‑Fi / BLE OTA 能力迁入 MXAppDemo，入口仅保留在设备详情的固件版本 / MCU 版本行。

**Architecture:** 从源项目拷贝 `MXDeviceOTA`（不含 List）、`MXMeshOTAHandle`、`MXOTAInfo`，补齐 API / 路由 / MQTT 进度通知 / firmwares 目录与 RTKOTA 二进制；在 `MXDeviceDetailViewController` 接入检查与跳转。不迁个人中心列表、批量 OTA、强制升级弹窗。

**Tech Stack:** UIKit、MXURLRouter、MXAPIManager、RTKOTA（Realtek DFU）、MeshSDK、PinLayout、NotificationCenter、CocoaPods

**Spec:** `MXAppDemo/docs/superpowers/specs/2026-11-09-ota-migration-design.md`

**Source root:** `/Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp/MXApp/`  
**Target root:** `/Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/`  
**Git root:** `/Users/huafeng/Desktop/mx_git/MXFramework_iOS`

---

## File map

| Action | Path | Responsibility |
|---|---|---|
| Replace binaries | `MXFrameworks/RTKOTA/*.framework` | BLE DFU SDK（从 `mx_sdk_ios` 对齐） |
| Create | `MXApp/Modules/MXDevice/Models/MXOTAInfo.swift` | OTA 元数据模型 |
| Create | `MXApp/Modules/MXDeviceOTA/MXWiFiOTAViewController.swift` | Wi‑Fi OTA 页 |
| Create | `MXApp/Modules/MXDeviceOTA/MXDeviceOTAViewController.swift` | BLE OTA 页（适配去掉 `MXAppFunConfig`） |
| Create | `MXApp/Modules/MXMeshOTA/MXMeshOTAHandle.swift` | RTK DFU 执行器 |
| Modify | `MXApp/Modules/MXBasicManager/MXAPI.swift` | 增加 `device.updateVersion` + `OTA` |
| Modify | `MXApp/Modules/MXDevice/ViewModels/MXDeviceManager.swift` | 增加 `updateDeviceVersion` |
| Modify | `MXApp/MXConfigs/MXRouterConfig.swift` | 注册两条 OTA 路由 |
| Modify | `MXApp/Modules/MXBasicManager/MXHomeManager.swift` | `biz_code` → WiFiOTA 通知 |
| Modify | `MXApp/AppDelegate.swift` | `createFirmwaresPath()` |
| Modify | `MXApp/Modules/MXDevice/Views/MXDeviceDetailViewController.swift` | 入口 UI + 跳转 |
| Modify | `MXAppDemo/MXApp.xcodeproj/project.pbxproj` | 加入新 Swift 文件与 group |

**Do NOT create/copy:** `MXOTAListViewController`、`MXToolPages/MXMeshOTAPage/**`、强制升级弹窗调用。

---

### Task 1: 对齐 RTKOTA 二进制

**Files:**
- Replace: `/Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXFrameworks/RTKOTA/`
- Source: `/Users/huafeng/Desktop/mx_git/mx_sdk_ios/MXFrameworks/RTKOTA/`

- [ ] **Step 1: 确认目标目录当前为空壳**

Run:

```bash
ls -la /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXFrameworks/RTKOTA/RTKOTASDK.framework/
file /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXFrameworks/RTKOTA/RTKOTASDK.framework/RTKOTASDK
```

Expected: 无可用 Mach-O 二进制（`No such file` 或非 Mach-O）。

- [ ] **Step 2: 用 mx_sdk_ios 完整 framework 覆盖**

Run:

```bash
SRC=/Users/huafeng/Desktop/mx_git/mx_sdk_ios/MXFrameworks/RTKOTA
DST=/Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXFrameworks/RTKOTA
rm -rf "$DST/RTKOTASDK.framework" "$DST/RTKLEFoundation.framework" "$DST/RTKBBproSDK.framework"
cp -R "$SRC/RTKOTASDK.framework" "$SRC/RTKLEFoundation.framework" "$SRC/RTKBBproSDK.framework" "$DST/"
file "$DST/RTKOTASDK.framework/RTKOTASDK"
du -sh "$DST"/*.framework
```

Expected: `Mach-O universal binary`；三个 framework 总大小约十几 MB+。

- [ ] **Step 3: 确认 Podspec 指向正确路径**

`/Users/huafeng/Desktop/mx_git/MXFramework_iOS/RTKOTA.podspec` 应包含：

```ruby
s.vendored_frameworks = 'MXFrameworks/RTKOTA/*.framework'
```

若缺失，从当前工作区 `RTKOTA.podspec` 保留/提交。然后：

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo && pod install
```

Expected: Pods 安装成功，无 RTKOTA 相关错误。

- [ ] **Step 4: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXFrameworks/RTKOTA RTKOTA.podspec MXAppDemo/Podfile.lock MXAppDemo/Pods 2>/dev/null || true
git add MXFrameworks/RTKOTA RTKOTA.podspec
# Podfile.lock / Pods 若被项目跟踪则一并 add；若 .gitignore 忽略 Pods 则不要强加
git status
git commit -m "$(cat <<'EOF'
chore: restore RTKOTA frameworks for BLE OTA

Copy complete Realtek OTA binaries from mx_sdk_ios so MXAppDemo can link DFU.
EOF
)"
```

---

### Task 2: 迁入 MXOTAInfo 模型

**Files:**
- Create: `MXAppDemo/MXApp/Modules/MXDevice/Models/MXOTAInfo.swift`
- Modify: `MXAppDemo/MXApp.xcodeproj/project.pbxproj`

- [ ] **Step 1: 从源项目复制模型**

Run:

```bash
cp /Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp/MXApp/Modules/MXDevice/Models/MXOTAInfo.swift \
   /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXDevice/Models/MXOTAInfo.swift
```

- [ ] **Step 2: 核对关键属性存在**

打开目标文件，确认包含：`oss_url`、`version`、`current_version`、`task_id`、`ota_type`、`module`、`has_newVersion`、`CodingKeys` 中 `hash`→`mxHash`、`description`→`des`。

- [ ] **Step 3: 将文件加入 Xcode 工程**

在 `project.pbxproj` 中：

1. 新增 `PBXFileReference`（选一个未占用的 24 位 hex，例如 `A1OTA00120261109001` 风格不合法——必须用 24 hex chars，如 `A11OTA01202611090001AB` → 用 `A11F0A01202611090001AB`）
2. 在 `FB131FCC2B05B663009C5A4B /* Models */` 的 `children` 加入该 fileRef
3. 新增 `PBXBuildFile`，并加入 `PBXSourcesBuildPhase` 的 `files` 列表

最小可用片段（UUID 可替换为随机 24 hex）：

```
A11F0A01202611090001AB /* MXOTAInfo.swift in Sources */ = {isa = PBXBuildFile; fileRef = A11F0A02202611090001AB /* MXOTAInfo.swift */; };
A11F0A02202611090001AB /* MXOTAInfo.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MXOTAInfo.swift; sourceTree = "<group>"; };
```

Group `FB131FCC2B05B663009C5A4B` children 增加 `A11F0A02202611090001AB /* MXOTAInfo.swift */,`  
Sources build phase 增加 `A11F0A01202611090001AB /* MXOTAInfo.swift in Sources */,`

- [ ] **Step 4: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/Modules/MXDevice/Models/MXOTAInfo.swift MXAppDemo/MXApp.xcodeproj/project.pbxproj
git commit -m "$(cat <<'EOF'
feat: add MXOTAInfo model for device firmware upgrade

Bring OTA metadata Codable model from mxapp_ios into MXAppDemo.
EOF
)"
```

---

### Task 3: API — `MXAPI.OTA` + `updateVersion`

**Files:**
- Modify: `MXAppDemo/MXApp/Modules/MXBasicManager/MXAPI.swift`
- Modify: `MXAppDemo/MXApp/Modules/MXDevice/ViewModels/MXDeviceManager.swift`

- [ ] **Step 1: 在 `MXAPI.device` 末尾（`sendMeshMessage` 之后、`} ` 结束 device 之前）加入 `updateVersion`**

```swift
        public static func updateVersion(iotId: String, version: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            var params = [String: Any]()
            params["version"] = version
            params["iotid"] = iotId
            MXAPI.request(path: "app/v1/device/version/update", method: .put, parameters: params, response: response)
        }
```

- [ ] **Step 2: 在 `MXAPI` 内（例如 `product` 结构体之后、`provisioning` 之前）新增 `OTA`（本项目只迁详情入口所需方法，不迁 devices/remind）**

```swift
    public struct OTA {
        
        public static func startWiFiDevice(with product_key: String, iotid: String, task_id: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            let path = "app/v3/ota/upgrade/confirmation"
            let params: [String: Any] = ["product_key": product_key, "iotid": iotid, "task_id": task_id]
            MXAPI.request(path: path, method: .put, parameters: params, response: response)
        }
        
        public static func cancelWiFiDevice(with product_key: String, iotid: String, task_id: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            let path = "app/v3/ota/upgrade/cancel"
            let params: [String: Any] = ["product_key": product_key, "iotid": iotid, "task_id": task_id]
            MXAPI.request(path: path, method: .put, parameters: params, response: response)
        }
        
        public static func checkDevice(iotid: String, module: String? = nil, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            let path = "app/v3/ota/newVersion"
            var params: [String: Any] = ["iotid": iotid]
            params["module"] = module
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
    }
```

- [ ] **Step 3: 在 `MXDeviceManager` 的 `requestDeviceInfo` 之后增加版本上报**

```swift
    //更新设备固件版本号
    public func updateDeviceVersion(iotId: String, version: String?, handler:@escaping() -> Void) {
        guard let version = version, version.count > 0 else {
            handler()
            return
        }
        MXAPI.device.updateVersion(iotId: iotId, version: version) { (data: Any, message: String, code: Int) in
            handler()
        }
    }
```

- [ ] **Step 4: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/Modules/MXBasicManager/MXAPI.swift \
        MXAppDemo/MXApp/Modules/MXDevice/ViewModels/MXDeviceManager.swift
git commit -m "$(cat <<'EOF'
feat: add OTA and device version update APIs

Expose check/confirm/cancel OTA endpoints and version report used by upgrade flows.
EOF
)"
```

---

### Task 4: 迁入 MXMeshOTAHandle

**Files:**
- Create: `MXAppDemo/MXApp/Modules/MXMeshOTA/MXMeshOTAHandle.swift`
- Modify: `MXAppDemo/MXApp.xcodeproj/project.pbxproj`

- [ ] **Step 1: 创建目录并复制**

```bash
mkdir -p /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXMeshOTA
cp /Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp/MXApp/Modules/MXMeshOTA/MXMeshOTAHandle.swift \
   /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXMeshOTA/MXMeshOTAHandle.swift
```

- [ ] **Step 2: 确认 import 可在本项目编译**

文件顶部应为：

```swift
import Foundation
import RTKOTASDK
import CoreBluetooth
```

`mxAppLog` 已在本项目 `MXAppConfig.swift` 存在，无需改。

- [ ] **Step 3: 加入 pbxproj**

1. 在 Modules group `DCA7D6E526565DFD0038D2B7` 增加新 group `MXMeshOTA`
2. 加入 `MXMeshOTAHandle.swift` fileRef + Sources build phase

建议 UUID：
- Group: `A11F0B01202611090001AB`
- FileRef: `A11F0B02202611090001AB`
- BuildFile: `A11F0B03202611090001AB`

- [ ] **Step 4: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/Modules/MXMeshOTA MXAppDemo/MXApp.xcodeproj/project.pbxproj
git commit -m "$(cat <<'EOF'
feat: add MXMeshOTAHandle for BLE DFU

Migrate Realtek OTA executor used by device firmware upgrade.
EOF
)"
```

---

### Task 5: 迁入 Wi‑Fi / BLE OTA 页面

**Files:**
- Create: `MXAppDemo/MXApp/Modules/MXDeviceOTA/MXWiFiOTAViewController.swift`
- Create: `MXAppDemo/MXApp/Modules/MXDeviceOTA/MXDeviceOTAViewController.swift`
- Modify: `MXAppDemo/MXApp.xcodeproj/project.pbxproj`

- [ ] **Step 1: 复制页面（明确不复制 List）**

```bash
mkdir -p /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXDeviceOTA
cp /Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp/MXApp/Modules/MXDeviceOTA/MXWiFiOTAViewController.swift \
   /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXDeviceOTA/
cp /Users/huafeng/Desktop/mx_git/mxapp_ios/MXApp/MXApp/Modules/MXDeviceOTA/MXDeviceOTAViewController.swift \
   /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo/MXApp/Modules/MXDeviceOTA/
# 不要复制 MXOTAListViewController.swift
```

- [ ] **Step 2: 适配 `MXDeviceOTAViewController` 中不存在的 `MXAppFunConfig`**

将：

```swift
        if MXAppFunConfig.MX_Function_Mesh {
            MeshSDK.sharedInstance.connect()
        }
```

改为（本项目始终使用 MeshSDK）：

```swift
        MeshSDK.sharedInstance.connect()
```

全文搜索该文件，确认无其它 `MXAppFunConfig` 引用。

- [ ] **Step 3: 确认两页路由工厂仍在**

`MXWiFiOTAViewController` / `MXDeviceOTAViewController` 末尾应有：

```swift
extension ...: MXURLRouterDelegate {
    public static func controller(withParams params: [String : Any]) -> AnyObject {
        // iotId / device / info
    }
}
```

- [ ] **Step 4: 加入 pbxproj**

Modules 下新建 group `MXDeviceOTA`，加入两个 swift 文件到 Sources。

建议 UUID：
- Group: `A11F0C01202611090001AB`
- WiFi FileRef/Build: `A11F0C02202611090001AB` / `A11F0C03202611090001AB`
- BLE FileRef/Build: `A11F0C04202611090001AB` / `A11F0C05202611090001AB`

- [ ] **Step 5: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/Modules/MXDeviceOTA MXAppDemo/MXApp.xcodeproj/project.pbxproj
git commit -m "$(cat <<'EOF'
feat: migrate Wi-Fi and BLE OTA view controllers

Copy device OTA pages from mxapp_ios and adapt Mesh reconnect for MXAppDemo.
EOF
)"
```

---

### Task 6: 路由 / MQTT / firmwares 目录

**Files:**
- Modify: `MXAppDemo/MXApp/MXConfigs/MXRouterConfig.swift`
- Modify: `MXAppDemo/MXApp/Modules/MXBasicManager/MXHomeManager.swift`
- Modify: `MXAppDemo/MXApp/AppDelegate.swift`

- [ ] **Step 1: 注册路由（不注册 OTAList / batchOTA）**

在 `registerRouter()` 的 `page/device/detail` 附近加入：

```swift
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/OTA", module: MXDeviceOTAViewController.self)
        MXURLRouterService.register(key: "com.mxchip.bta/page/device/WiFiOTA", module: MXWiFiOTAViewController.self)
```

- [ ] **Step 2: 在 `MXHomeManager.receiveMessageHander` 的设备消息分支之后增加 fog OTA 分支**

在 `} else if let iot_id = dict["iotId"] as? String { ... }` 整块结束后、方法结束前，追加：

```swift
        } else if let biz_code = dict["biz_code"] as? String {  //fog相关的消息
            if biz_code == "ota_progress" {
                NotificationCenter.default.post(name: NSNotification.Name("WiFiOTAOngoing"), object: nil, userInfo: dict)
            } else if biz_code == "ota_version" {
                NotificationCenter.default.post(name: NSNotification.Name("WiFiOTAFinish"), object: nil, userInfo: dict)
            }
        }
```

注意：当前方法在 iotId 分支后直接结束；要把原来的结尾 `}` 结构调整为上述 `else if`，避免语法错误。完整结构应为：

```swift
        if let msgType = ... {
            ...
        } else if let iot_id = dict["iotId"] as? String {
            ...
        } else if let biz_code = dict["biz_code"] as? String {
            ...
        }
```

- [ ] **Step 3: AppDelegate 创建固件缓存目录**

在 `AppDelegate` 增加：

```swift
    func createFirmwaresPath() {
        let pathes = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        let path = pathes.first!
        let s = "\(path)/firmwares"
        try? FileManager.default.createDirectory(atPath: s, withIntermediateDirectories: true)
    }
```

并在 `application(_:didFinishLaunchingWithOptions:)` 中 `MXRouterConfig.registerRouter()` 之后调用：

```swift
        self.createFirmwaresPath()
```

- [ ] **Step 4: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/MXConfigs/MXRouterConfig.swift \
        MXAppDemo/MXApp/Modules/MXBasicManager/MXHomeManager.swift \
        MXAppDemo/MXApp/AppDelegate.swift
git commit -m "$(cat <<'EOF'
feat: wire OTA routes, MQTT progress, and firmware cache

Register device OTA pages, forward fog OTA biz_codes, and ensure firmwares cache exists.
EOF
)"
```

---

### Task 7: 设备详情入口接入

**Files:**
- Modify: `MXAppDemo/MXApp/Modules/MXDevice/Views/MXDeviceDetailViewController.swift`

- [ ] **Step 1: 增加属性**

在 `var info : MXDeviceInfo?` 附近增加：

```swift
    var otaInfo: MXOTAInfo?
    var mcu_otaInfo: MXOTAInfo?
```

- [ ] **Step 2: 改 `updateDataSources()`**

```swift
    func updateDataSources() {
        self.dataSources.removeAll()
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_device_id")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_product_key")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_mac")))
        self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_firmware_version")))
        if self.mcu_otaInfo != nil || (self.info?.mcu_version?.count ?? 0) > 0 {
            self.dataSources.append(MXCellModel(title: MXAppConfig.mxLocalized(key:"mx_mcu_version")))
        }
    }
```

- [ ] **Step 3: 改 `loadRequestData()` —— 设备信息返回后继续拉 OTA**

将现有：

```swift
        group.notify(queue: DispatchQueue.main) {
            self.updateDataSources()
            self.headerView.refreshView(info: self.info!)
            self.tableView.reloadData()
        }
```

改为在 notify 里调用 `loadDeviceOTAInfo()`（若 `info` 为 nil 则直接 return）：

```swift
        group.notify(queue: DispatchQueue.main) {
            guard let info = self.info else { return }
            self.headerView.refreshView(info: info)
            self.loadDeviceOTAInfo()
        }
```

- [ ] **Step 4: 新增 `loadDeviceOTAInfo()` / `gotoOTAPage(info:)`**

```swift
    func loadDeviceOTAInfo() {
        let group = DispatchGroup()
        group.enter()
        MXAPI.OTA.checkDevice(iotid: self.iotId) { data, message, code in
            if code == 0, let dict = data as? [String: Any], let info = MXOTAInfo.mx_Decode(dict) {
                self.otaInfo = info
                if let current_version = info.current_version {
                    self.info?.firmware_version = current_version
                }
            } else {
                self.otaInfo = nil
            }
            group.leave()
        }
        
        if let deviceType = self.info?.productInfo?.node_type_v2,
           deviceType != "gateway-sub" {
            group.enter()
            MXAPI.OTA.checkDevice(iotid: self.iotId, module: "mcu") { data, message, code in
                if code == 0, let dict = data as? [String: Any], let info = MXOTAInfo.mx_Decode(dict) {
                    self.mcu_otaInfo = info
                    if let current_version = info.current_version {
                        self.info?.mcu_version = current_version
                    }
                } else {
                    self.mcu_otaInfo = nil
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            self.updateDataSources()
            if let info = self.info {
                self.headerView.refreshView(info: info)
            }
            self.tableView.reloadData()
        }
    }
    
    func gotoOTAPage(info: MXOTAInfo?) {
        if (self.info?.isShare ?? false) {
            return
        }
        if !MXHomeManager.shard.operationAuthorityCheck() {
            return
        }
        guard let _ = info?.version else { return }
        var params = [String: Any]()
        params["iotId"] = self.iotId
        params["device"] = self.info
        params["info"] = info
        
        if info?.ota_type == 1 {
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/WiFiOTA", params: params)
        } else if info?.ota_type == 2 {
            MXURLRouter.open(url: "https://com.mxchip.bta/page/device/OTA", params: params)
        }
    }
```

- [ ] **Step 5: 更新 `cellForRow` 中固件/MCU 行展示**

将 `mx_firmware_version` case 替换为：

```swift
            case MXAppConfig.mxLocalized(key:"mx_firmware_version"):
                if (self.info?.isShare ?? false) || !MXHomeManager.shard.operationAuthorityCheck() {
                    cell?.accessoryType = .none
                    cell?.detailTextLabel?.text = (self.info?.firmware_version ??  "")
                } else {
                    if (self.otaInfo?.has_newVersion ?? false) {
                        let str = NSMutableAttributedString()
                        var version = self.info?.firmware_version ?? ""
                        if version.count == 0, let new_version = self.otaInfo?.version {
                            version = new_version
                        }
                        let str1 = NSAttributedString(string: version, attributes: [.font: UIFont.mxSystemFont(ofSize: 16),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                        str.append(str1)
                        let str2 = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.mxIconFont(ofSize: 16),.foregroundColor:UIColor.red])
                        str.append(str2)
                        cell?.detailTextLabel?.attributedText = str
                        cell?.accessoryType = .disclosureIndicator
                    } else {
                        cell?.detailTextLabel?.text = self.info?.firmware_version
                        cell?.accessoryType = .none
                    }
                }
                break
            case MXAppConfig.mxLocalized(key:"mx_mcu_version"):
                if (self.info?.isShare ?? false) || !MXHomeManager.shard.operationAuthorityCheck() {
                    cell?.accessoryType = .none
                    cell?.detailTextLabel?.text = (self.info?.mcu_version ??  "")
                } else {
                    if (self.mcu_otaInfo?.has_newVersion ?? false) {
                        let str = NSMutableAttributedString()
                        var version = self.info?.mcu_version ?? ""
                        if version.count == 0, let new_version = self.mcu_otaInfo?.version {
                            version = new_version
                        }
                        let str1 = NSAttributedString(string: version, attributes: [.font: UIFont.mxSystemFont(ofSize: 16),.foregroundColor:MXAppConfig.MXColor.secondaryText])
                        str.append(str1)
                        let str2 = NSAttributedString(string: "\u{e72e}", attributes: [.font: UIFont.mxIconFont(ofSize: 16),.foregroundColor:UIColor.red])
                        str.append(str2)
                        cell?.detailTextLabel?.attributedText = str
                        cell?.accessoryType = .disclosureIndicator
                    } else {
                        cell?.detailTextLabel?.text = self.info?.mcu_version
                        cell?.accessoryType = .none
                    }
                }
                break
```

- [ ] **Step 6: 实现 `didSelectRowAt`**

```swift
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataSources.count > indexPath.row {
            let model = self.dataSources[indexPath.row]
            switch model.title {
            case MXAppConfig.mxLocalized(key:"mx_firmware_version"):
                self.gotoOTAPage(info: self.otaInfo)
            case MXAppConfig.mxLocalized(key:"mx_mcu_version"):
                self.gotoOTAPage(info: self.mcu_otaInfo)
            default:
                break
            }
        }
    }
```

- [ ] **Step 7: Commit**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS
git add MXAppDemo/MXApp/Modules/MXDevice/Views/MXDeviceDetailViewController.swift
git commit -m "$(cat <<'EOF'
feat: enable firmware and MCU OTA entry on device detail

Load OTA metadata, show update affordance, and route to Wi-Fi or BLE upgrade pages.
EOF
)"
```

---

### Task 8: 编译验证与范围核对

**Files:** 无新文件；验证既有改动。

- [ ] **Step 1: 编译 MXApp target**

```bash
cd /Users/huafeng/Desktop/mx_git/MXFramework_iOS/MXAppDemo
xcodebuild -workspace MXApp.xcworkspace -scheme MXApp -configuration Debug -destination 'generic/platform=iOS' build CODE_SIGNING_ALLOWED=NO 2>&1 | tail -80
```

Expected: `BUILD SUCCEEDED`。若失败，按报错修缺失符号/未加入工程的文件，再重编。

- [ ] **Step 2: 范围核对（必须全部满足）**

```bash
# 不应存在列表页
test ! -f MXApp/Modules/MXDeviceOTA/MXOTAListViewController.swift && echo "OK no OTAList"
# 不应注册个人中心/批量路由
! grep -n "OTAList\|batchOTA" MXApp/MXConfigs/MXRouterConfig.swift && echo "OK no list/batch routes"
# 应注册两条设备 OTA 路由
grep -n "page/device/OTA\|page/device/WiFiOTA" MXApp/MXConfigs/MXRouterConfig.swift
# 详情页应有入口方法
grep -n "loadDeviceOTAInfo\|gotoOTAPage\|mcu_otaInfo" MXApp/Modules/MXDevice/Views/MXDeviceDetailViewController.swift
```

- [ ] **Step 3: 手动验证清单（真机/联调时勾选）**

- [ ] 设备详情展示固件版本；有 MCU 信息时展示 MCU 行
- [ ] 有新版本时版本旁红点图标 + disclosure；点击按 `ota_type` 进对应页
- [ ] 分享设备 / 无权限不可进入
- [ ] Wi‑Fi：确认后进度更新，完成/取消可用
- [ ] BLE：下载 → DFU → `updateDeviceVersion`
- [ ] 无「我的→固件升级」、无批量 OTA、无强制升级弹窗

- [ ] **Step 4: 若有编译修复，单独 commit**

```bash
git add -u
git commit -m "$(cat <<'EOF'
fix: resolve OTA migration build issues

Address compile errors found while verifying MXAppDemo OTA integration.
EOF
)"
```

---

## Spec coverage self-check

| Spec 要求 | Task |
|---|---|
| Wi‑Fi + BLE 两条链路 | Task 5 |
| 设备详情固件 + MCU 入口 | Task 7 |
| 不迁个人中心 / 批量 / 强制弹窗 | Task 5 明确不拷 List；Task 6 不注册；Task 8 核对 |
| `MXAPI.OTA` | Task 3 |
| MQTT `ota_progress`/`ota_version` | Task 6 |
| `Caches/firmwares` | Task 6 |
| RTKOTA 二进制 | Task 1 |
| 路由注册 | Task 6 |
| 版本上报 | Task 3 + BLE 页内已有调用 |
| 本地化复用 | 无新 key；沿用现有 strings |

## Placeholder / consistency notes

- `ota_type`: `1` = Wi‑Fi，`2` = BLE（与源项目及详情跳转一致）
- 通知名：`WiFiOTAOngoing` / `WiFiOTAFinish`
- 路由 key：`com.mxchip.bta/page/device/OTA`、`com.mxchip.bta/page/device/WiFiOTA`
- 本项目无 `MXAppFunConfig`：BLE 页一律 `MeshSDK.sharedInstance.connect()`

//
//  MXDeviceManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/29.
//

import Foundation
import UIKit

public class MXDeviceManager: NSObject {
    public static var shard = MXDeviceManager()
    
    public var allDeviceObjects = [MXObjectInfo]()
    
    override init() {
        super.init()
    }
    
    /*请求所有设备(调用V5的API）
     @params: pageNo 分页参数，默认从1开始
     @params：pageSize 每页数量，不分页199
     @params: homeId  家庭ID
     @params: roomId  房间ID
     @params: list 已经请求过的列表
     @params: favorite 是否首页展示
     @callback: handler 返回完整的列表数据
     */
    static public func requestAllDevices(pageNo:Int = 1,
                                         pageSize: Int = 199,
                                         homeId: Int,
                                         roomId: Int? = nil,
                                         favorite: Bool? = nil,
                                         product_key: String? = nil,
                                         is_gateway: Int? = nil,
                                         list: [MXDeviceInfo]? = nil,
                                         handler:@escaping (_ list: [MXDeviceInfo], _ isSuccess: Bool) -> Void) {
        
        var device_list = [MXDeviceInfo]()
        if let oldList = list {
            device_list = oldList;
        }
        var page_no = pageNo;
        MXAPI.device.allDevices(home_id: homeId,
                                room_id: roomId,
                                page: page_no,
                                size: pageSize,
                                favorite: favorite,
                                product_key: product_key,
                                is_gateway: is_gateway) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let result = dict["list"] as? Array<[String : Any]> {
                    if let list = MXDeviceInfo.mx_Decode(result) {
                        device_list.append(contentsOf: list)
                    }
                    if let pageParams = dict["page"] as? [String: Any], let total = pageParams["total"] as? Int, total > page_no * pageSize {
                        page_no += 1
                        MXDeviceManager.requestAllDevices(pageNo: page_no,
                                                          pageSize: pageSize,
                                                          homeId: homeId,
                                                          roomId: roomId,
                                                          favorite: favorite,
                                                          product_key: product_key,
                                                          is_gateway: is_gateway,
                                                          list: device_list,
                                                          handler: handler)
                        return;
                    }
                }
            }
            handler(device_list, code == 0)
        }
    }
    
    //获取设备详情信息
    public func requestDeviceInfo(iotId:String, handler:@escaping (_ info: MXDeviceInfo?) -> Void) {
        guard let home_id = MXHomeManager.shard.currentHome?.homeId else {
            handler(nil)
            return
        }
        MXAPI.device.detail(home_id: home_id, iotId: iotId) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any] {
                    if let info = MXDeviceInfo.mx_Decode(dict) {
                        handler(info)
                        return
                    }
                }
                handler(nil)
            } else {
                handler(nil)
            }
        }
    }
    //给设备发送物模型消息（云端发送）
    public func sendDeviceMessage(iotId: String, curSet: [String : Any], handler:@escaping (_ isSuccess: Bool) -> Void) {
        MXAPI.device.setProperties(iotId: iotId, items: curSet) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                handler(true)
            } else {
                handler(false)
            }
        }
    }
}

extension MXDeviceManager {
    
    public static func feedbackGenerator() {
        let gen = UIImpactFeedbackGenerator.init(style: .medium);//light震动效果的强弱
        gen.prepare();//反馈延迟最小化
        gen.impactOccurred()//触发效果
    }
    
    // 修改属性
    public func setProperty(with device: MXDeviceInfo, pInfo: MXDevicePropertyItem) {
        //添加震动反馈
        MXDeviceManager.feedbackGenerator()
        guard let identifierStr = pInfo.identifier else {
            return
        }
        
        var newValue = 0
        if let pValue = pInfo.value as? Int {
            newValue = pValue
        }
        if let specs = pInfo.dataType?.specs as? [String: String], specs.count > 0 {
            let sList = specs.keys.sorted { (s1:String, s2:String) in
                return (Int(s1) ?? 0) < (Int(s2) ?? 0) ? true : false
            }
            if let index = sList.firstIndex(where: {Int($0) == newValue}) {
                let nextIndex = index + 1
                if sList.count > nextIndex {
                    newValue = Int(sList[nextIndex]) ?? 0
                } else {
                    newValue = Int(sList[0]) ?? 0
                }
            } else {
                newValue = Int(sList[0]) ?? 0
            }
        } else {
            if newValue == 0 {
                newValue = 1
            } else {
                newValue = 0
            }
        }
        if let uuidStr = device.uuid, uuidStr.count > 0, MeshSDK.sharedInstance.isConnected(), !device.isShare {  //Mesh设备
            let attrMap = MXProductManager.getProductInfo(uuid: uuidStr)?.attrMap
            if let typeStr = MXMeshMessageHandle.identifierConvertToAttrType(identifier: identifierStr, attrMap: attrMap),
               let typeHex = UInt16(typeStr.bigEndian, radix: 16),
                (typeHex & 0x0FFF) == 0x0100 {
                newValue = 2
            }
            if let msgHex = MXMeshMessageHandle.properiesToMessageHex(identifier: identifierStr, value: newValue, attrMap: attrMap) {
                MeshSDK.sharedInstance.sendMeshMessage(opCode: "11", uuid: uuidStr, message: msgHex)
            }
            
        } else {  //云端控制
            var newParams = [String : Any]()
            newParams[identifierStr] = newValue
            if let iot_id = device.iotId {
                MXDeviceManager.shard.sendDeviceMessage(iotId: iot_id, curSet: newParams) { (isSuccess: Bool) in
                    
                }
            }
        }
    }
}

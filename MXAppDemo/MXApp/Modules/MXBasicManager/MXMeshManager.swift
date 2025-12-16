//
//  MXMeshManager.swift
//  MXApp
//
//  Created by 华峰 on 2023/7/13.
//

import Foundation
@_exported import MeshSDK

public class MXMeshManager: NSObject {
    public static var shard = MXMeshManager()
    
    public override init() {
        super.init()
        let meshConfig = ["cacheInvalid": 5.0, "proxyRSSI": -80] as [String : Any]
        MeshSDK.sharedInstance.setup(config: meshConfig)
        MeshSDK.sharedInstance.delegate = self
    }
    
    public func loadMeshNetwork(home: MXHomeInfo) {
        if let jsonStr = home.meshInfoString {
            MeshSDK.sharedInstance.disconnect()
            MeshSDK.sharedInstance.importMeshNetworkConfig(jsonString: jsonStr) { (isSuccess : Bool) in
                if isSuccess {
                    if let meshAddress = home.meshAddress, meshAddress > 0 {
                        MeshSDK.sharedInstance.resetProvisionerUnicastAddress(address: UInt16(meshAddress))
                        let seqNumber = home.seq ?? 0
                        MeshSDK.sharedInstance.setMeshNetworkSequence(seq: UInt32(seqNumber + 200), updateInterval: 50)
                        home.seq = seqNumber + 200
                        MXMeshManager.shard.updateMeshSeqNumber(home_id: home.homeId, seq: Int(seqNumber + 200))
                        if let currentNK = home.networkKey {
                            MeshSDK.sharedInstance.disconnect()
                            if !MeshSDK.sharedInstance.isNetworkKeyExists(networkKey: currentNK) {
                                _ = MeshSDK.sharedInstance.createNetworkKey(key: currentNK, appKey: home.appKey)
                            }
                            MeshSDK.sharedInstance.setCurrentNetworkKey(key: currentNK)
                            MeshSDK.sharedInstance.connect()
                        }
                    }
                }
            }
        }
    }
    
    public func resetMeshNetwork() {
        guard let home_id = MXHomeManager.shard.currentHome?.homeId else {
            return
        }
        //获取mesh配置
        MXMeshManager.shard.getMeshConfig(home_id: home_id) { (isSuccess: Bool) in
            //获取用户手机mesh地址
            MXMeshManager.shard.getMeshAddress(home_id: home_id, type: 1, uuid: nil) { (meshAddress: Int) in
                //获取seq
                MXMeshManager.shard.getMeshSeqNumber(home_id: home_id) { (seqNumber: Int) in
                    if let home = MXHomeManager.shard.currentHome {
                        MXMeshManager.shard.loadMeshNetwork(home: home)
                    }
                }
            }
        }
    }
    
    public func updateMeshNetwork() {
        guard let home_id = MXHomeManager.shard.currentHome?.homeId else {
            return
        }
        //获取mesh配置
        MXMeshManager.shard.getMeshConfig(home_id: home_id) { (isSuccess: Bool) in
            
        }
    }
    
    public func getMeshConfig(home_id : Int, handler:@escaping (_ isSuccess: Bool) -> Void) {
        MXAPI.Mesh.config(homeId: home_id) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted), let jsonStr = String(data: jsonData, encoding: .utf8) {
                    guard home_id == MXHomeManager.shard.currentHome?.homeId else {
                        handler(false)
                        return
                    }
                    MXHomeManager.shard.currentHome?.meshInfoString = jsonStr
                   mxAppLog("Mesh数据更新")
                    MXHomeManager.shard.updateCache()
                    handler(true)
                } else {
                    handler(false)
                }
            } else {
                handler(false)
            }
        }
    }
    
    public func getMeshAddress(home_id : Int, type: Int = 0, uuid: String?, iotid: String? = nil, handler:@escaping (_ address: Int) -> Void) {
        MXAPI.Mesh.address(homeId: home_id, type: type, uuid: uuid, iotid: iotid) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let mesh_address = dict["mesh_address"] as? Int {
                    if type == 1, home_id == MXHomeManager.shard.currentHome?.homeId {
                        MXHomeManager.shard.currentHome?.meshAddress = mesh_address
                    }
                    handler(mesh_address)
                } else {
                    handler(0)
                }
            } else {
                handler(0)
            }
        }
    }
    
    public func getMeshSeqNumber(home_id : Int, handler:@escaping (_ seqNumber: Int) -> Void) {
        MXAPI.Mesh.sequence(homeId: home_id) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let seq = dict["sequence_number"] as? Int {
                    guard home_id == MXHomeManager.shard.currentHome?.homeId else {
                        handler(0)
                        return
                    }
                    MXHomeManager.shard.currentHome?.seq = seq
                    handler(seq)
                } else {
                    handler(0)
                }
            } else {
                handler(0)
            }
        }
    }
    
    public func updateMeshSeqNumber(home_id : Int, seq: Int) {
        if home_id == MXHomeManager.shard.currentHome?.homeId {
            MXHomeManager.shard.currentHome?.seq = seq
           mxAppLog("seq更新")
            MXHomeManager.shard.updateCache()
        }
        MXAPI.Mesh.sequenceUpdate(homeId: home_id, seq: seq) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                
            }
        }
    }
    
    public func downloadDeviceAttrConfig() {
        MXAPI.Mesh.attrMap { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let attr_map = dict["attr_map"] as? String  {
                    if let attr_data = attr_map.data(using: .utf8) {
                        let attrMap = try? JSONSerialization.jsonObject(with: attr_data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any]
                        MXMeshMessageHandle.shard.updateTranscodingMapping(data: attrMap)
                    }
                }
            }
        }
    }
    
    func subscribeMeshGroupAddress() {
        //订阅组播地址
        MeshSDK.sharedInstance.subscribeMeshProxyFilter(address: 0xD003)
    }
    
}

extension MXMeshManager : MXMeshDelegate {
    /*
     连接改变回调
     @params status Int 连接状态 0未连接 1连接成功
     */
    public func meshConnectChange(status: Int) {
        if MeshSDK.sharedInstance.isConnected() {
            self.subscribeMeshGroupAddress()
            //清除mesh缓存，避免控制状态不同步的问题
            MXMeshDeviceManager.shard.initDeviceCache()
        }
        NotificationCenter.default.post(name: NSNotification.Name("kMeshConnectStatusChange"), object: nil)
    }
    /*
     ivIndex更新
     @params index Int 更新后的ivIndex.index
     */
    public func meshNetworkIvIndexUpdate(index: Int) {
        
    }
    /*
     sequence更新
     @params seq Int 当前的sequence number
     */
    public func provisionerSequenceUpdate(seq: Int) {
        let seq = MeshSDK.sharedInstance.getMeshNetworkSequence()
        if let home_id = MXHomeManager.shard.currentHome?.homeId {
            self.updateMeshSeqNumber(home_id: home_id, seq: Int(seq))
        }
    }
    /*
     收到设备上报消息
     @params uuid Int 设备唯一标识
     @params elementIndex Int 设备的element index， 默认为0
     @params message  String 消息内容
     */
    public func receiveMeshMessage(uuid: String, elementIndex: Int, message: String) {
        let result = [uuid: ["code":0, "message":message, "elemnetIndex": elementIndex] as [String : Any]]
        
        let attrMap = MXProductManager.getProductInfo(uuid: uuid)?.attrMap
        
        let properyParams = MXMeshMessageHandle.resolveMeshMessageToProperties(message: message, attrMap: attrMap)
        //更新设备影子
        MXMeshDeviceManager.shard.updateDeviceStatusCache(uuid: uuid, properties: properyParams)
        
        NotificationCenter.default.post(name: NSNotification.Name("kDevicePropertyChangeFromLocate"), object: result)
    }
}

public class MXMeshDeviceManager: NSObject {
    
    public static var shard = MXMeshDeviceManager()
    //监听的设备
    public var listenResult = [String : Any]()
    public var cacheInvalid: Double = 5.0
    var workItem: DispatchWorkItem?
    
    //初始化设备缓存
    public func initDeviceCache() {
        
        var allNodes = MeshSDK.sharedInstance.meshNetworkManager.meshNetwork?.nodes ?? [Node]()
        if allNodes.count > 0 {
            allNodes.remove(at: 0)
        }
        for node in allNodes {
            var linstenParams = [String : Any]()
            linstenParams["timestamp"] = Date().timeIntervalSince1970
            linstenParams["isOnline"] = true
            self.listenResult[node.uuid.uuidString] = linstenParams
        }
        self.checkDeviceStatus()
    }
    
    /*
     更新设备影子
     @params  uuid  设备唯一标识
     @params  properties 设备物模型键值对
     */
    public func updateDeviceStatusCache(uuid: String, properties:[String: Any]) {
        //更新影子消息
        var linstenParams = self.listenResult[uuid] as? [String : Any]
        if linstenParams == nil {
            linstenParams = [String : Any]()
        }
        var propertyParams = linstenParams?["properties"] as? [String: Any]
        if propertyParams == nil {
            propertyParams = [String : Any]()
        }
        properties.forEach { (params) in
            propertyParams?[params.key] = params.value
        }
        linstenParams?["properties"] = propertyParams
        linstenParams?["timestamp"] = Date().timeIntervalSince1970
        self.listenResult[uuid] = linstenParams
    }
    /*
     获取设备影子
     @params  uuid  设备唯一标识
     @retrun  properties 设备物模型键值对
     */
    public func getDeviceCacheProperties(uuid: String) -> [String: Any]? {
        if let params = self.listenResult[uuid] as? [String: Any], let properties = params["properties"] as? [String: Any] {
            return properties
        }
        return nil
    }
    
    func checkDeviceStatus(){
        self.workItem?.cancel()
        self.workItem = nil
        self.workItem = DispatchWorkItem { [weak self] in
            self?.checkDeviceStatus()
        }
        // 添加延时任务
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: self.workItem!)
        
        for uuid in self.listenResult.keys {
            if var result = self.listenResult[uuid] as? [String: Any], let timestamp = result["timestamp"] as? Double {
                let time = Date().timeIntervalSince1970 - timestamp
                if time > self.cacheInvalid {  //缓存失效
                    result.removeValue(forKey: "properties")
                    self.listenResult[uuid] = result
                    
                    NotificationCenter.default.post(name: NSNotification.Name("kDevicePropertyCacheInvalidFromLocate"), object: uuid)
                }
            }
        }
    }
}

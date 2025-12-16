//
//  MXRoomManager.swift
//  MXApp
//
//  Created by mxchip on 2023/11/13.
//

import Foundation

public class MXRoomManager: NSObject {
    public static var shard = MXRoomManager()
    
    public var currentRoomList: [MXRoomInfo] {
        get {
            if let list = MXHomeManager.shard.currentHome?.rooms {
                return list
            }
            return [MXRoomInfo]()
        }
    }
    
    public func getCurrentDefaultRoomId() -> Int? {
        if let defaultRoom = MXHomeManager.shard.currentHome?.rooms?.first(where: {$0.is_default}) {
            return defaultRoom.roomId
        }
        return nil
    }
}

extension MXRoomManager {
    
    /*请求房间列表
     @params: pageNo 分页参数，默认从1开始
     @params：pageSize 每页数量，不分页199
     @params: homeId  家庭ID
     @params: list 已经请求过的列表
     @callback: handler 返回完整的列表数据
     */
    static public func requestRoomList(pageNo:Int = 1, pageSize: Int = 199, homeId: Int, list: [MXRoomInfo]? = nil, handler:@escaping (_ list: [MXRoomInfo]) -> Void) {
        
        var room_list = [MXRoomInfo]()
        if let oldList = list {
            room_list = oldList;
        }
        var page_no = pageNo;
        MXAPI.room.rooms(home_id: homeId, page: page_no, size: pageSize) { (data: Any, message: String, code: Int ) in
            if code == 0 {
                if let dict = data as? [String: Any], let result = dict["list"] as? Array<[String : Any]> {
                    if let list = MXRoomInfo.mx_Decode(result) {
                        room_list.append(contentsOf: list)
                    }
                    if let pageParams = dict["page"] as? [String: Any], let total = pageParams["total"] as? Int, total > page_no * pageSize {
                        page_no += 1
                        MXRoomManager.requestRoomList(pageNo: page_no, pageSize: pageSize, homeId: homeId, list: room_list, handler: handler)
                        return;
                    }
                }
                //如果获取的是当前家庭的房间列表
                if homeId == MXHomeManager.shard.currentHome?.homeId {
                    let oldRoomList = MXHomeManager.shard.currentHome?.rooms?.map { (info:MXRoomInfo) in
                        return info.roomId
                    }
                    for room in room_list {
                        if let info = MXHomeManager.shard.currentHome?.rooms?.first(where: {$0.roomId == room.roomId}) {
                            room.devices = info.devices
                        }
                    }
                    MXHomeManager.shard.currentHome?.rooms = room_list;
                    MXHomeManager.shard.updateCache()
                    let newRoomList = room_list.map { (info:MXRoomInfo) in
                        return info.roomId
                    }
                    //比较房间是否有变化，有变化需要通知UI刷新
                    if oldRoomList != newRoomList {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "kRoomDataSourceChange"), object: nil)
                    }
                }
            }
            handler(room_list)
        }
    }
}

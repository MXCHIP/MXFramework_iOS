//
//  MXAPI.swift
//  MXApp
//
//  Created by Khazan on 2021/9/26.
//

import Foundation
import Alamofire
import MXAPIManager

public class MXAPI: NSObject {
    
    // 用户相关
    public struct user {
        public static func signIn(with account: String,
                           password: String,
                           clientid: String = "",
                           area: String? = nil,
                           iso3: String? = nil,
                           response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            
            let url = "app/v1/auth/login"
            var parameters: [String: Any] = ["account": account,
                                             "password": password,
                                             "clientid": clientid]
            parameters["area"] = area
            
            if account.isValidEmail() {
                parameters["account_type"] = 1
            } else {
                parameters["account_type"] = 0
            }
            parameters["country_code"] = iso3
            
            MXAPI.toast.request(path: url, method: .post, parameters: parameters, response: response)
        }
    }
    
    // 设备相关
    public struct device {
        
        public static func allDevices(home_id: Int,
                               room_id: Int? = nil,
                               page: Int,
                               size: Int,
                               favorite: Bool?,
                               product_key: String? = nil,
                               is_gateway: Int? = nil,
                               response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v5/device/list"
            
            var params = [String :Any]()
            params["show"] = favorite
            params["page_no"] = page
            params["page_size"] = size
            params["home_id"] = home_id
            params["room_id"] = room_id
            params["product_key"] = product_key
            params["is_gateway"] = is_gateway
            
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func detail(home_id: Int, iotId:String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            var params = [String :Any]()
            params["iotid"] = iotId
            params["home_id"] = home_id
            MXAPI.toast.request(path: "app/v3/device/info", method: .get, parameters: params, response:response)
        }
        
        public static func getProperties(iotId: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            
            let path = "app/v3/device/properties/get"
            var params = [String : Any]()
            params["iotid"] = iotId
            
            MXAPI.toast.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func setProperties(iotId: String, items:[String: Any], response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            
            let path = "app/v3/device/properties/set"
            var params = [String : Any]()
            params["iotid"] = iotId
            params["items"] = items
            MXAPI.toast.request(path: path, method: .post, parameters: params, response: response)
        }
        
        public static func sendMeshMessage(homeId: Int, message: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            
            let path = "app/v3/device/gateway/mesh/message"
            var params = [String : Any]()
            params["home_id"] = homeId
            params["data"] = message
            MXAPI.toast.request(path: path, method: .post, parameters: params, response: response)
        }
        
    }
    
    public struct product {
        
        public static func categories(response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            let path = "app/v3/category/product/info"
            MXAPI.request(path: path, method: .get, parameters: nil , response: response)
        }
        
        public static func getProductGuide(productKey: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v1/product/bindGuide"
            var params = [String: Any]()
            params["product_key"] = productKey
            MXAPI.toast.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func h5PlanVersion(productKey: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v1/panel/h5/upgradeInfo"
            var params = [String : Any]()
            params["product_key"] =  productKey
            params["timestrame"] = String(Int(Date().timeIntervalSince1970))
            params["v3"] = 1
            MXAPI.toast.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func getProductManual(productKey: String, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v1/product/instructions/detail"
            var params = [String: Any]()
            params["product_key"] = productKey
            MXAPI.toast.request(path: path, method: .get, parameters: params, response: response)
        }
    }
    
    // 家庭相关
    public struct home {
        
        public static func list(page: Int, size: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            
            let path = "app/v3/home/list"
            var params = [String :Any]()
            params["page_no"] = page
            params["page_size"] = size
            
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func homeInfo(home_id: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            
            let url = "app/v3/home/info"
            let params = ["home_id": home_id]
            
            MXAPI.toast.request(path: url, method: .get, parameters: params, response: response)
        }
        
        public static func currentHome(homeId:Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            var params = [String :Any]()
            params["home_id"] = homeId
            
            MXAPI.toast.request(path: "app/v3/home/current/update", method: .put, parameters: params, response: response)
        }
    }
    
    // 房间相关
    public struct room {
        
        public static func rooms(home_id: Int, page: Int, size: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            
            let path = "app/v4/room/list"
            let params = ["home_id": home_id, "page_size": size, "page_no": page]
            
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
        
    }
    
    public struct APP {
        
        //webSocket
        public static func getWebSocketInfo(response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let reqPath = "app/v3/websocket/info"
            MXAPI.request(path: reqPath, method: .get, parameters: nil, response: response)
        }
    }
    
    public struct Mesh {
        public static func config(homeId: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/mesh/config"
            var params = [String :Any]()
            params["home_id"] = homeId
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func address(homeId: Int, type: Int = 0, uuid: String?, iotid: String? = nil, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            
            let path = "app/v3/mesh/address"
            
            var params = [String :Any]()
            params["home_id"] = homeId
            params["type"] = type
            params["uuid"] = uuid
            if let iotid = iotid {
                params["iotid"] = iotid
            }
            MXAPI.request(path: path, method: .post, parameters: params, response: response)
        }
        
        public static func sequence(homeId: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/mesh/sequence/info"
            var params = [String :Any]()
            params["home_id"] = homeId
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
        
        public static func sequenceUpdate(homeId: Int, seq: Int, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/mesh/sequence/update"
            var params = [String :Any]()
            params["home_id"] = homeId
            params["sequence_number"] = seq
            MXAPI.request(path: path, method: .put, parameters: params, response: response)
        }
        
        public static func attrMap(response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/whole/home/attr/map"
            MXAPI.request(path: path, method: .get, parameters: nil, response: response)
        }
    }
    
    public struct provisioning {
        
        public static func bind(params: [String: Any], response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/device/bind"
            MXAPI.request(path: path, method: .post, parameters: params, response: response)
        }
        
        public static func random(params: [String: Any]? = nil, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/fog/device/setNet/getRandom"
            MXAPI.request(path: path, method: .post, parameters: params, response: response)
        }
        
        public static func fogKey(params: [String: Any]? = nil, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/fog/device/setNet/getBleKey"
            MXAPI.request(path: path, method: .post, parameters: params, response: response)
        }
        
        public static func fogStatus(params: [String: Any]? = nil, response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) {
            let path = "app/v3/fog/device/bleConfigNetworking"
            MXAPI.request(path: path, method: .get, parameters: params, response: response)
        }
    }
    
    struct toast {
        
        static func request(path: String,
                            method: MXHTTPMethod,
                            parameters: [String: Any]?,
                            response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
            MXToastHUD.show()
            MXAPI.request(path: path, method: method, parameters: parameters) { (data: Any?, msg: String, code: Int) in
                MXToastHUD.dismiss()
                response(data, msg, code)
                if code != 0, code != 10404 {
                    MXToastHUD.showError(status: msg)
                }
            }
            
        }
    }
    
    // request with path
    static func request(path: String,
                        method: MXHTTPMethod,
                        parameters: [String: Any]?,
                        timeout: TimeInterval? = nil,
                        response: @escaping (_ data: Any?, _ message: String, _ code: Int) -> Void) -> Void {
        MXAPIManager.shared.request(path: path, method: method, parameters: parameters, timeout: timeout) { data, message, code in
            var msg = message
            if code == 8000 {
                msg = MXAppConfig.mxLocalized(key: "mx_server_error")
            } else if code == 8001 {
                msg = MXAppConfig.mxLocalized(key: "mx_network_error")
            }
            response(data, msg, code)
        }
    }
    
    override init() {
        super.init()
        
    }
    
}

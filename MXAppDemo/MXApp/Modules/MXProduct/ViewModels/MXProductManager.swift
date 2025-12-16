//
//  ProductManager.swift
//  MXApp
//
//  Created by 华峰 on 2021/6/29.
//

import Foundation
import Accelerate

public class MXProductManager: NSObject {
    public static var shard = MXProductManager()
    
    public var categoryList = Array<MXCategoryInfo>()
    public var productGroupList = [[String: Any]]()
    
    override init() {
        super.init()
        self.loadMXProductData()
        self.loadMXProductGroup()
    }
    
    public static func getCompositeIndex(uuid: String) -> Int {
        let uuidStr = uuid.replacingOccurrences(of: "-", with: "")
        let uuidBytes = [UInt8](Data(hex: uuidStr))
        guard uuidBytes.count == 16 else {
            return 0
        }
        return Int(uuidBytes[14]) >> 4
    }
    
    public static func getProductInfo(uuid: String?) -> MXProductInfo? {
        guard let uuidStr = uuid else {
            return nil
        }
        let pid = MXMeshTool.getDeviceProductId(uuid: uuidStr)
        let info = MXProductManager.shard.getProductInfo(pid: pid)
        if info?.is_composite == 1 {  //复合产品
            let index = MXProductManager.getCompositeIndex(uuid: uuidStr)
            if index > 0, let newInfo = info?.composite_products?.first(where: {$0.index == index}) {
                return MXProductManager.shard.getProductInfo(pk: newInfo.product_key)
            }
        }
        return info
    }
    
    public func getProductGroup(pk: String?) -> [String] {
        var pkList = [String]()
        guard let productKey = pk else {
            return pkList
        }
        pkList.append(productKey)
        
        for item in MXProductManager.shard.productGroupList {
            if let products = item["products"] as? [[String: Any]] {
                if products.first(where: { (pInfo:[String : Any]) in
                    if let product_key = pInfo["product_key"] as? String, product_key == pk {
                        return true
                    }
                    return false
                }) != nil {
                    products.forEach { (productInfo: [String : Any]) in
                        if let product_key = productInfo["product_key"] as? String, !pkList.contains(product_key) {
                            pkList.append(product_key)
                        }
                    }
                }
            }
        }
        return pkList
    }
    
    public func getProductInfo(pk: String?) -> MXProductInfo? {
        guard let productKey = pk else {
            return nil
        }
        for category1 in MXProductManager.shard.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if info.product_key == productKey {
                                return info
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    public func getProductInfo(pid: String?) -> MXProductInfo? {
        guard let productId = pid else {
            return nil
        }
        var newList = [MXProductInfo]()
        for category1 in MXProductManager.shard.categoryList {
            if let list1 = category1.categorys  {
                for category2 in list1 {
                    if let list2 = category2.products {
                        for info in list2 {
                            if let productIdStr = info.product_id,
                                productIdStr.count > 0,
                                Int(productIdStr) == Int(productId, radix: 16) {
                                if info.cloud_platform == 2 { //优先Fog平台
                                    return info
                                } else {
                                    newList.append(info)
                                }
                            } else if info.cloud_platform == 2,
                                        info.product_key?.lowercased() == productId.lowercased() {
                                return info
                            }
                        }
                    }
                }
            }
        }
//        if let newInfo = newList.first(where: {$0.cloud_platform == 2}) {  //优先Fog平台
//            return newInfo
//        }
        return newList.first
    }
    
    static public func loadCategoryListRequest(handler:@escaping (_ list: Array<MXCategoryInfo>) -> Void) {
        MXAPI.product.categories { (data: Any, message: String, code: Int) in
            if code == 0 {
                if let dataDic = data as? [String : Any] {
                    if let list = dataDic["list"] as? Array<[String : Any]> {
                        MXProductManager.shard.updateMXProductData(params: list)
                        if let pList = MXCategoryInfo.mx_Decode(list) {
                            MXProductManager.shard.categoryList = pList
                        }
                    }
                }
            }
            handler(MXProductManager.shard.categoryList)
        }
    }
    
    public func updateLocalProductData() {
        var list = [[String: Any]]()
        self.categoryList.forEach { (item:MXCategoryInfo) in
            if let item_params = MXCategoryInfo.mx_keyValue(item) {
                list.append(item_params)
            }
        }
        self.updateMXProductData(params: list)
    }
    
    /*
     加载本地缓存的产品列表
     */
    public func loadMXProductData() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductData.json")
        if let data = try? Data(contentsOf: url) {
            if let params = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String : Any]],
                let list = MXCategoryInfo.mx_Decode(params) {
                self.categoryList = list
            }
        }
    }
    /*
    更新本地缓存的产品列表
    @param data jsonString的数据
    */
    public func updateMXProductData(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductData.json")
        if let json_data = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed) {
            try? json_data.write(to: url)
        }
    }
    
    /*
     加载本地缓存的产品列表
     */
    public func loadMXProductGroup() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductGroup.json")
        if let data = try? Data(contentsOf: url) {
            if let params = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String : Any]] {
                self.productGroupList = params
            }
        }
    }
    /*
    更新本地缓存的产品列表
    @param data jsonString的数据
    */
    public func updateMXProductGroup(params: [[String : Any]]) {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true) as NSArray
        let documentsDirectory = paths[0] as! String
        let url = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("MXProductGroup.json")
        if let json_data = try? JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed) {
            try? json_data.write(to: url)
        }
    }
    
}

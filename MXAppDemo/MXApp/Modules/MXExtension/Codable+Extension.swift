//
//  Dictionary+Extension.swift
//  MXApp
//
//  Created by 华峰 on 2021/8/5.
//

import Foundation

extension Decodable {
    
    //dictionary 转 model
    public static func mx_Decode(_ dictionary: [String : Any]) -> Self? {
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {
            return nil
        }
        guard let model = try? JSONDecoder().decode(Self.self, from: jsonData) else {
            return nil
        }
        return model
    }
    
    //array 转 [model]
    public static func mx_Decode(_ array: [[String : Any]]) -> [Self]? {
        guard let jsonData: Data = try? JSONSerialization.data(withJSONObject: array, options: JSONSerialization.WritingOptions.fragmentsAllowed) else {
            return nil
        }
        guard let list = try? JSONDecoder().decode([Self].self, from: jsonData) else {
            return nil
        }
        return list
    }
}

extension Encodable {
    public static func mx_keyValue(_ object: Self) -> [String : Any]? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(object) else {
            return nil
        }
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String:Any] else {
            return nil
        }
        return dict
    }
}

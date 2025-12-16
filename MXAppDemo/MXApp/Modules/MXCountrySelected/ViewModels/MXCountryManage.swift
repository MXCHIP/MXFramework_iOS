//
//  MXCountryManage.swift
//  MXApp
//
//  Created by huafeng on 2025/2/28.
//

public class MXCountryManage: NSObject {
    public static var shard = MXCountryManage()
    public var countryList = [MXCountryInfo]()
    
    let supportStation = ["China"];
    
    public var currentCountry: MXCountryInfo? {
        get {
            if let obj = UserDefaults.standard.object(forKey: "MXUserDefaultsCurrentCountry") as? [String: Any],
               let country = MXCountryInfo.mx_Decode(obj) {
                return country
            }
            return nil
        }
        set {
            if let newObj = newValue,
               let obj = MXCountryInfo.mx_keyValue(newObj) {
                UserDefaults.standard.set(obj, forKey: "MXUserDefaultsCurrentCountry")
            }
        }
    }
    
    override init() {
        super.init()
        if let list = MXCountryManage.mxReadJsonFile(with: "countrys"),
           let countrys = MXCountryInfo.mx_Decode(list) {
            self.countryList = countrys.filter({ country in
                if let server = country.ServerStation, self.supportStation.contains(server) {
                    return true
                }
                return false
            })
        }
    }
    
    static public func defaultCountry() -> MXCountryInfo? {
        return MXCountryManage.shard.countryList.first(where: {$0.ISO3 == "CHN"})
    }
    
    public static func mxReadJsonFile(with fileName: String) -> [[String: Any]]? {
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            let url = URL(fileURLWithPath: path)
            if let data = try? Data(contentsOf: url),
               let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [[String: Any]] {
                return json
            }
        }
        
        return nil
    }
    
}

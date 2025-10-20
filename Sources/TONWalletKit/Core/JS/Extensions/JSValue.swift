//
//  JSValue.swift
//  TONWalletKit
//
//  Created by Nikita Rodionov on 30.09.2025.
//

extension JSValue {
    
    convenience init?(encodable: Encodable, in context: JSContext?) {
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(encodable)
            let dictionary = try JSONSerialization.jsonObject(with: data)
            
            self.init(object: dictionary, in: context)
        } catch {
            return nil
        }
    }
    
    func toData() -> Data? {
        if isString {
            return toString().data(using: .utf8)
        }
        
        if isObject, let dictionary = toDictionary() {
            return try? JSONSerialization.data(withJSONObject: dictionary)
        }
        
        return nil
    }
    
    func decode<T: Decodable>() throws -> T {
        let object: Any
        
        if self.isArray {
            object = self.toArray()
        } else if let dictionary = self.toDictionary() {
            object = dictionary
        } else {
            throw "Unable convert not JSON JSValue to \(T.self)"
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: jsonData)
    }
}

//
//  AtomicHelper.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/6/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import Foundation

class AtomicHelper {
   // Create JSON string for URL
   func generateUrl(product: String, demoMode: Bool, publicToken: String) -> String {
       let jsonObject: NSMutableDictionary = NSMutableDictionary()
       jsonObject.setValue(product, forKey: "product")
       jsonObject.setValue(demoMode, forKey: "demoMode")
       jsonObject.setValue(publicToken, forKey: "token")
       jsonObject.setValue(true, forKey: "inSdk")
       let jsonData: NSData
       do {
           jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
           let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue)! as String
           let originalString = "https://transact.atomicfi.com/\(product)/start/\(jsonString)"
           let encodedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
           print(encodedString!)
           return encodedString!
       } catch _ {
           return "Failed to create JSON string."
       }
   }
}

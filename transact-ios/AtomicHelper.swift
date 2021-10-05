//
//  AtomicHelper.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/6/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import UIKit

enum AtomicProduct: String {
    case deposit, verify, identify
}

enum AtomicLanguage: String {
    /// Default
    case english = "en"
    case spanish = "es"
}

enum AtomicURLBase: String {
    case prod = "https://transact.atomicfi.com/initialize/"
    case sandbox = "https://transact-sandbox.atomicfi.com/initialize/"
}

struct Theme {
    let brandColor: UIColor
    let overlayColor: UIColor?
}


class AtomicHelper {
    /// The product to initiate. Valid values include deposit, verify, and identify.
    let product: AtomicProduct
    /// The public token returned during [AccessToken creation](https://docs.atomicfi.com/reference/api#access-token__create-access-token)
    let publicToken: String
    // Whether to use the sandbox url or the production url
    let useSandbox: Bool
    /// Optionally pass in a language. Acceptable values: en for English and es for Spanish. Default value is en.
    let language: AtomicLanguage
    /// Default is true. When false, close buttons and SDK events are not broadcast.
    let inSDK: Bool
    /// Object containing properties to customize the look of Transact. e.g. brandColor and overlayColor
    let theme: Theme?
    
    init(product: AtomicProduct = .deposit, publicToken: String, useSandbox: Bool = false, language: AtomicLanguage = .english, inSDK: Bool = true, theme: Theme? = nil) {
        self.product = product
        self.publicToken = publicToken
        self.useSandbox = useSandbox
        self.language = language
        self.inSDK = inSDK
        self.theme = theme
    }
    
    
    /// Generates a URL with the parameters given at initiatlization
    /// - Returns: `URL?` from the given parameters
    func generatedURL() -> URL? {
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        jsonObject.setValue(product.rawValue, forKey: Keys.product)
        jsonObject.setValue(publicToken, forKey: Keys.token)
        jsonObject.setValue(language.rawValue, forKey: Keys.language)
        jsonObject.setValue(inSDK, forKey: Keys.inSdk)
        
        if let theme = theme {
            let themeJSONObject = NSMutableDictionary()
            themeJSONObject.setValue(theme.brandColor.hexString, forKey: Keys.brandColor)
            if let overlayHex = theme.overlayColor?.hexString {
                themeJSONObject.setValue(overlayHex, forKey: Keys.overlayColor)
            }
            jsonObject.setValue(themeJSONObject, forKey: Keys.theme)
        }
       let jsonData: NSData
       do {
           jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions()) as NSData
           guard let jsonString = NSString(data: jsonData as Data, encoding: String.Encoding.utf8.rawValue) else {
               throw AtomicError.encodingError(nil)
           }
           let base64String = self.toBase64(input: jsonString as String)
           let baseURLString = useSandbox ? AtomicURLBase.sandbox.rawValue : AtomicURLBase.prod.rawValue
           let fullURLString = baseURLString + base64String
           guard let encodedURLString = fullURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
               throw AtomicError.encodingError(fullURLString)
           }
           return URL(string: encodedURLString)
       } catch {
           return nil
       }
    }
    
}


// MARK: - Private

private extension AtomicHelper {
    
    enum Keys {
        static var brandColor: String { #function }
        static var color: String { #function }
        static var demoMode: String { #function }
        static var inSdk: String { #function }
        static var language: String { #function }
        static var overlayColor: String { #function }
        static var product: String { #function }
        static var theme: String { #function }
        static var token: String { #function }
    }
    
    func toBase64(input: String) -> String {
        return (input.data(using: .utf8)?.base64EncodedString())!
    }
    
}


// MARK: - Color Extension

extension UIColor {
    
    var hexString: String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
}

//
//  AtomicTransactEventController.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/5/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import Foundation
import WebKit

class AtomicTransactEventController: NSObject, WKScriptMessageHandler {
    var eventHandler: (_ event: String,_ payload: NSDictionary) -> Void
    init(eventHandler: @escaping (String, NSDictionary) -> Void) {
        self.eventHandler = eventHandler
    }
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("got '\(message.name)' event: \(message.body)")
        if let messageBody = message.body as? NSDictionary {
            eventHandler(message.name, messageBody)
        } else {
            let emptyDictionary: NSDictionary = NSDictionary()
            eventHandler(message.name, emptyDictionary)
        }
    }
}

//
//  AtomicTransactView.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/5/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import SwiftUI
import WebKit

enum AtomicEvent: String, CaseIterable {
    case eventOccurred = "atomic-transact-interaction"
    case unauthorized = "step-access-unauthorized"
    case openURL = "atomic-transact-open-url"
    case closed = "atomic-transact-close"
    case finished = "atomic-transact-finish"
}

enum AtomicError: Error {
    case encodingError(String?)
    case unauthorized
}

protocol AtomicTransactDelegate {
    func interactionOccurred(event: String)
    func errorOccurred(error: AtomicError)
    func openURL(url: URL)
    func didClose()
    func didFinish()
}


struct AtomicTransactView: UIViewRepresentable {
        
    @Binding var isPresented: Bool
    
    var delegate: AtomicTransactDelegate?
    private let atomicHelper: AtomicHelper
    
    init(isPresented: Binding<Bool>, delegate: AtomicTransactDelegate?, publicToken: String) {
        self._isPresented = isPresented
        self.delegate = delegate
        self.atomicHelper = AtomicHelper(publicToken: publicToken)
    }
    
    func makeUIView(context: Context) -> AtomicWebView  {
        let uiView = AtomicWebView()
        for event in AtomicEvent.allCases {
            uiView.configuration.userContentController.add(context.coordinator, name: event.rawValue)
        }
        return uiView
    }
    
    func updateUIView(_ uiView: AtomicWebView, context: Context) {
        guard let url = atomicHelper.generatedURL(), case let urlRequest = URLRequest(url: url) else { return }
        uiView.load(urlRequest)
    }
    
    public func closeView() -> Void {
        self.isPresented = false
    }
    
    func makeCoordinator() -> AtomicTransactEventController {
        return AtomicTransactEventController(delegate: delegate)
    }
    
}


// MARK: - Coordinator

class AtomicTransactEventController: NSObject, WKScriptMessageHandler {
    
    var delegate: AtomicTransactDelegate?
    
    init(delegate: AtomicTransactDelegate?) {
        self.delegate = delegate
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        debugPrint("got '\(message.name)' event: \(message.body)")
        let eventName = message.name
        let eventPayload = message.body as? NSDictionary
        var url: URL? = nil
        if let urlString = eventPayload?.object(forKey: "url") as? String, let payloadURL = URL(string: urlString) {
            url = payloadURL
        }
        var atomicEvent = AtomicEvent(rawValue: eventName) ?? AtomicEvent.eventOccurred
        if atomicEvent == .eventOccurred, let payload = eventPayload, let payloadName = payload["name"] as? String, let differentEvent = AtomicEvent(rawValue: payloadName)  {
            atomicEvent = differentEvent
        }
        
        switch atomicEvent {
        case .openURL:
            if let url = url {
                delegate?.openURL(url: url)
            } else {
                fallthrough
            }
        case .eventOccurred:
            delegate?.interactionOccurred(event: eventName)
        case .unauthorized:
            delegate?.errorOccurred(error: .unauthorized)
        case .closed:
            delegate?.didClose()
        case .finished:
            delegate?.didFinish()
        }
    }
    
}

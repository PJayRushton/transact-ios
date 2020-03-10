//
//  AtomicTransactView.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/5/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import SwiftUI
import WebKit


struct AtomicTransactView: UIViewRepresentable {
    let request: URLRequest
    @Binding var isPresented: Bool
    var transactEventController:AtomicTransactEventController
    
    func makeUIView(context: Context) -> AtomicWebView  {
        let uiView = AtomicWebView()
        uiView.configuration.userContentController.add(transactEventController, name: "atomic-transact-close")
        uiView.configuration.userContentController.add(transactEventController, name: "atomic-transact-finish")
        uiView.configuration.userContentController.add(transactEventController, name: "atomic-transact-open-url")
        return uiView
    }
    
    func updateUIView(_ uiView: AtomicWebView, context: Context) {
        uiView.load(request)
    }
    
    public func closeView() -> Void {
        self.isPresented = false
    }

}

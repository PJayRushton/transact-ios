//
//  ContentView.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/5/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import SwiftUI

let atomicBlue = UIColor(red: 0.00, green: 0.00, blue: 0.22, alpha: 1.0)
let atomicHelper = AtomicHelper()

struct ContentView: View {
    @State var showingTransact = false
    var body: some View {
        ZStack
        {
            Color(atomicBlue)
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: -15) {
                Image("atomic-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200.0, height: 200.0)
                Button(action: {
                    self.showingTransact = true
                    }) {
                    Text("Launch Transact")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding()
                        .border(Color(.white), width: 3)
                }.sheet(isPresented: $showingTransact, content: {
                    // Configure Transact SDK with this call. For example, set a publicToken
                    AtomicTransactView(request: URLRequest(url: URL(string: atomicHelper.generateUrl(product: "deposit", demoMode: false,publicToken: "PUBLIC_TOKEN_HERE",color:"" ))!), isPresented: self.$showingTransact, transactEventController: AtomicTransactEventController(eventHandler: self.eventHandler)).edgesIgnoringSafeArea(.all)
                        })
            }
        }
    }
    
    // Handle postMessage events from Transact
    func eventHandler(_ event: String, payload: NSDictionary) {
        switch event {
        case "atomic-transact-close", "atomic-transact-finish":
            showingTransact = false
        case "atomic-transact-open-url":
            if let url = URL(string: payload.object(forKey: "url") as! String) {
                UIApplication.shared.open(url)
            }
        case "atomic-transact-interaction":
            print("Interaction event: '\(event)'")
        default:
            print("Unrecognized event: '\(event)'")
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

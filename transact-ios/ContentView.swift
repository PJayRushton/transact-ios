//
//  ContentView.swift
//  transact-ios
//
//  Created by Scott Weinert on 3/5/20.
//  Copyright © 2020 Atomic FI Inc. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: - State
    
    @State private var isShowingAtomicView = false
    @State private var isLoadingToken = false
    @State private var publicToken = "PUBLIC_TOKEN_HERE"
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Color.atomicBlue
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: -15) {
                Image("atomic-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200.0, height: 200.0)
                
                Button(action: {
                    self.isShowingAtomicView = true
                }) {
                    Text(isLoadingToken ? "Loading Token" : "Launch Transact")
                        .foregroundColor(.white)
                        .font(.title)
                        .padding()
                        .border(Color(.white), width: 3)
                        .opacity(isLoadingToken ? 0.3 : 1)
                        .disabled(isLoadingToken)
                }
            }
            .sheet(isPresented: $isShowingAtomicView) {
                // Configure Transact SDK with this call. For example, set a publicToken
                AtomicTransactView(isPresented: $isShowingAtomicView, delegate: self, publicToken: publicToken)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            self.loadPublicToken()
        }
    }

}


// MARK: - Private

private extension ContentView {
    
    func loadPublicToken() {
        isLoadingToken = true
        // Fetch public token from server
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.publicToken = "LOADED_TOKEN"
            self.isLoadingToken = false
        }
    }
    
}


// MARK: - Transact Delegate

extension ContentView: AtomicTransactDelegate {
    
    func interactionOccurred(event: String) {
        debugPrint("ℹ️\(event)")
    }
    
    func errorOccurred(error: AtomicError) {
        debugPrint("❌\(error.localizedDescription)")
    }
    
    func openURL(url: URL) {
        debugPrint("🌎 Opening URL: \(url.absoluteURL)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func didClose() {
        debugPrint("⚠️ closed")
        isShowingAtomicView = false
    }
    
    func didFinish() {
        debugPrint("✅ FINISHED!")
        isShowingAtomicView = false
    }
    
}


// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}


// MARK: - Color Extension

extension Color {
    static let atomicBlue = Color(UIColor(red: 0.00, green: 0.00, blue: 0.22, alpha: 1.0))
}

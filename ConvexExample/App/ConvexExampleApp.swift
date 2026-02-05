//
//  ConvexExampleApp.swift
//  ConvexExample
//

import ClerkKitConvex
import ClerkKitUI
import ConvexMobile
import SwiftUI

let convexClient = ConvexClientWithAuth(
  deploymentUrl: "YOUR_CONVEX_DEPLOYMENT_URL",
  authProvider: ClerkConvexAuthProvider()
)

@main
struct ConvexExampleApp: App {
  init() {
    Clerk.configure(publishableKey: "YOUR_CLERK_PUBLISHABLE_KEY")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .prefetchClerkImages()
        .environment(Clerk.shared)
        .atlantisProxy()
    }
  }
}

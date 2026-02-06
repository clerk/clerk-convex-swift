//
//  WorkoutTrackerApp.swift
//  WorkoutTracker
//
//

import ClerkConvex
import ClerkKit
import ClerkKitUI
import ConvexMobile
import SwiftUI

@MainActor
let client = ConvexClientWithAuth(
  deploymentUrl: Env.convexDeploymentUrl,
  authProvider: ClerkConvexAuthProvider()
)

@main
struct WorkoutTrackerApp: App {
  init() {
    Clerk.configure(publishableKey: Env.clerkPublishableKey)
  }

  var body: some Scene {
    WindowGroup {
      LandingPage()
        .environment(Clerk.shared)
        .prefetchClerkImages()
    }
  }
}

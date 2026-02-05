//
//  ConvexClientWithAuth+Clerk.swift
//  ClerkKitConvex
//

import ConvexMobile

public extension ConvexClientWithAuth where T == String {
  /// Creates a Convex client with Clerk auth and automatically starts session sync.
  ///
  /// - Important: Call `Clerk.configure(...)` before the first access that initializes this client.
  @MainActor
  convenience init(deploymentUrl: String, authProvider: ClerkConvexAuthProvider) {
    self.init(deploymentUrl: deploymentUrl, authProvider: authProvider as any AuthProvider<String>)
    authProvider.bind(client: self)
  }
}

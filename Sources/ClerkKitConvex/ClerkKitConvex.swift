//
//  ClerkKitConvex.swift
//  ClerkKitConvex
//

/// ClerkKitConvex provides integration between Clerk authentication and Convex backends.
///
/// This module implements Convex's `AuthProvider` protocol using Clerk's session
/// management, enabling seamless authentication with Convex backend services.
///
/// ## Quick Start
///
/// 1. Configure Clerk in your app:
/// ```swift
/// Clerk.configure(publishableKey: "YOUR_PUBLISHABLE_KEY")
/// ```
///
/// 2. Create a Convex client with Clerk authentication:
/// ```swift
/// let convexClient = ConvexClientWithAuth(
///   deploymentUrl: "YOUR_CONVEX_DEPLOYMENT_URL",
///   authProvider: ClerkConvexAuthProvider(jwtTemplate: "convex")
/// )
/// ```
///
/// - Important: Call `Clerk.configure(...)` before creating the Convex client.
///
/// 3. After user signs in with Clerk's AuthView, authenticate with Convex:
/// ```swift
/// _ = await convexClient.login()
/// ```
///
/// 4. Use the client for authenticated Convex operations:
/// ```swift
/// let data: MyType = try await convexClient.query("myFunction")
/// ```
///
/// ## Prerequisites
///
/// - A Clerk application with a "convex" JWT template configured
/// - A Convex deployment configured to accept Clerk-issued JWTs
///
/// See the ConvexExample app for a complete implementation example.

// Re-export ConvexMobile for convenience so users don't need to import both
@_exported import ConvexMobile

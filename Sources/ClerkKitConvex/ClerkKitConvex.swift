//
//  ClerkKitConvex.swift
//  ClerkKitConvex
//

/// ClerkConvex bridges Clerk and Convex by syncing Clerk session auth into Convex clients.
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
///   authProvider: ClerkConvexAuthProvider()
/// )
/// ```
///
/// - Important: Call `Clerk.configure(...)` before creating the Convex client.
///
/// 3. After user signs in with Clerk, Convex auth sync runs automatically.
///    No explicit `convexClient.login()` call is required.
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
/// See this README for integration steps and usage examples.

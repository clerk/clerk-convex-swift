//
//  ClerkConvexAuthError.swift
//  ClerkKitConvex
//

import Foundation

/// Error types for Clerk-Convex authentication.
public enum ClerkConvexAuthError: LocalizedError, Sendable, Equatable {
  /// Clerk has not finished loading. Wait for `Clerk.shared.isLoaded` to be true.
  case clerkNotLoaded

  /// No active Clerk session exists. The user must sign in first.
  case noActiveSession

  /// Failed to retrieve a JWT token from the Clerk session.
  case tokenRetrievalFailed(_ reason: String)

  public var errorDescription: String? {
    switch self {
    case .clerkNotLoaded:
      "Clerk has not finished loading. Ensure Clerk.shared.isLoaded is true before authenticating."
    case .noActiveSession:
      "No active Clerk session. Please sign in first using Clerk's AuthView."
    case .tokenRetrievalFailed(let reason):
      reason
    }
  }
}

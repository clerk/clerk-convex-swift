//
//  ClerkConvexAuthProvider.swift
//  ClerkKitConvex
//

import ClerkKit
@preconcurrency import ConvexMobile

/// An AuthProvider implementation that bridges Clerk authentication with Convex.
///
/// This provider uses Clerk's session management and JWT token generation
/// to authenticate with a Convex backend. It automatically listens for token
/// refresh events and pushes fresh tokens to Convex.
///
/// ## Usage
///
/// ```swift
/// let client = ConvexClientWithAuth(
///   deploymentUrl: "YOUR_CONVEX_DEPLOYMENT_URL",
///   authProvider: ClerkConvexAuthProvider()
/// )
/// ```
///
/// - Important: Users must first sign in using Clerk.
///   This provider then syncs Convex authentication
///   automatically; no manual `client.login()` call is required.
@MainActor
public final class ClerkConvexAuthProvider: AuthProvider {
  public typealias T = String

  /// Callback to notify Convex of token updates.
  private var onIdToken: (@Sendable (String?) -> Void)?

  /// Task that listens for token refresh events.
  private var tokenRefreshListenerTask: Task<Void, Never>?

  /// Task that syncs Clerk session state with Convex.
  private var sessionSyncTask: Task<Void, Never>?

  /// Weak reference to the Convex client for session sync.
  private weak var client: ConvexClientWithAuth<String>?

  /// Creates a new ClerkConvexAuthProvider.
  public init() {}

  /// Binds a Convex client to this auth provider and starts session sync.
  ///
  /// This automatically performs an initial sync and listens for Clerk session changes,
  /// calling `loginFromCache()` or `logout()` on the client as needed.
  ///
  /// - Important: `Clerk.configure(...)` must be called before binding.
  public func bind(client: ConvexClientWithAuth<String>) {
    self.client = client
    startSessionSync()
  }

  /// Retrieves a JWT token from the current Clerk session and sets up token refresh listening.
  ///
  /// - Parameter onIdToken: Callback to invoke with fresh tokens. Store this and call it
  ///   whenever tokens are refreshed.
  /// - Returns: A JWT token string for Convex authentication.
  /// - Throws: `ClerkConvexAuthError.clerkNotLoaded` if Clerk hasn't finished loading.
  /// - Throws: `ClerkConvexAuthError.noActiveSession` if no user is signed in.
  /// - Throws: `ClerkConvexAuthError.tokenRetrievalFailed` if token retrieval fails.
  public func login(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> String {
    try await authenticate(onIdToken: onIdToken)
  }

  /// Retrieves a JWT token from the current Clerk session using cached credentials.
  ///
  /// This method attempts to return a cached token if available and not expired,
  /// avoiding unnecessary network requests. It also sets up token refresh listening.
  ///
  /// - Parameter onIdToken: Callback to invoke with fresh tokens. Store this and call it
  ///   whenever tokens are refreshed.
  /// - Returns: A JWT token string for Convex authentication.
  /// - Throws: `ClerkConvexAuthError.clerkNotLoaded` if Clerk hasn't finished loading.
  /// - Throws: `ClerkConvexAuthError.noActiveSession` if no user is signed in.
  /// - Throws: `ClerkConvexAuthError.tokenRetrievalFailed` if token retrieval fails.
  public func loginFromCache(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> String {
    try await authenticate(onIdToken: onIdToken)
  }

  /// Signs out of the current Clerk session.
  ///
  /// This will end the active Clerk session, notify Convex of the logout,
  /// and stop listening for token refresh events.
  public func logout() async throws {
    tokenRefreshListenerTask?.cancel()
    tokenRefreshListenerTask = nil
    onIdToken = nil
    try await Clerk.shared.auth.signOut()
  }

  /// Extracts the JWT ID token from the authentication result.
  ///
  /// Since our `T` type is already a `String` (the JWT token), this
  /// method simply returns the input unchanged.
  ///
  /// - Parameter authResult: The JWT token string.
  /// - Returns: The same JWT token string.
  public nonisolated func extractIdToken(from authResult: String) -> String {
    authResult
  }

  // MARK: - Private

  /// Common implementation for login and loginFromCache.
  ///
  /// Stores the callback, sets up the token refresh listener, and returns the current token.
  private func authenticate(onIdToken: @Sendable @escaping (String?) -> Void) async throws -> String {
    self.onIdToken = onIdToken
    let token = try await fetchToken()
    setupTokenRefreshListener()
    return token
  }

  /// Fetches a JWT token from the active Clerk session.
  ///
  /// - Returns: A JWT token string for Convex authentication.
  /// - Throws: `ClerkConvexAuthError.clerkNotLoaded` if Clerk hasn't finished loading.
  /// - Throws: `ClerkConvexAuthError.noActiveSession` if no user is signed in.
  /// - Throws: `ClerkConvexAuthError.tokenRetrievalFailed` if the token is nil.
  private func fetchToken() async throws -> String {
    guard Clerk.shared.isLoaded else {
      throw ClerkConvexAuthError.clerkNotLoaded
    }

    guard let session = Clerk.shared.session, session.status == .active else {
      throw ClerkConvexAuthError.noActiveSession
    }

    guard let token = try await session.getToken() else {
      throw ClerkConvexAuthError.tokenRetrievalFailed("Token returned nil")
    }

    return token
  }

  /// Sets up a listener for Clerk auth events to handle token refresh.
  ///
  /// Note: Session changes are handled by the session sync started via `bind(client:)`,
  /// which triggers `loginFromCache()` or `logout()` on the Convex client. This listener
  /// only handles ongoing token refreshes while authenticated.
  private func setupTokenRefreshListener() {
    tokenRefreshListenerTask?.cancel()

    tokenRefreshListenerTask = Task { [weak self] in
      guard let self else { return }

      for await event in Clerk.shared.auth.events {
        guard !Task.isCancelled else { break }

        switch event {
        case .tokenRefreshed(let token):
          onIdToken?(token)
        default:
          break
        }
      }
    }
  }

  /// Starts syncing Clerk session state with the bound Convex client.
  private func startSessionSync() {
    sessionSyncTask?.cancel()

    sessionSyncTask = Task { @MainActor [weak self] in
      guard let self else { return }

      await syncSession(newSession: Clerk.shared.session)

      for await event in Clerk.shared.auth.events {
        guard !Task.isCancelled else { break }

        switch event {
        case .sessionChanged(let oldSession, let newSession):
          await syncSession(oldSession: oldSession, newSession: newSession)
        default:
          break
        }
      }
    }
  }

  /// Syncs a Clerk session transition with the Convex client.
  ///
  /// Convex login only runs when a session transitions from non-active to active.
  /// Convex logout runs when a session transitions from any value to nil.
  private func syncSession(oldSession: Session? = nil, newSession: Session?) async {
    guard let client else { return }

    if shouldLogin(oldSession: oldSession, newSession: newSession) {
      _ = await client.loginFromCache()
    } else if shouldLogout(oldSession: oldSession, newSession: newSession) {
      await client.logout()
    }
  }

  /// Returns true when we should authenticate Convex from cached Clerk credentials.
  private func shouldLogin(oldSession: Session?, newSession: Session?) -> Bool {
    newSession?.status == .active &&
    (oldSession?.status != .active || oldSession?.id != newSession?.id)
  }

  /// Returns true when we should clear Convex auth due to session removal.
  private func shouldLogout(oldSession: Session?, newSession: Session?) -> Bool {
    oldSession?.id != nil && newSession == nil
  }
}

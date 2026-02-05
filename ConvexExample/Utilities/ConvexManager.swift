//
//  ConvexManager.swift
//  ConvexExample
//

import ClerkKitConvex
import ClerkKitUI
import Combine
import Foundation

@MainActor
@Observable
final class ConvexManager {
  private(set) var authState: AuthState<String> = .unauthenticated

  private var cancellables = Set<AnyCancellable>()

  init() {
    convexClient.authState
      .replaceError(with: .unauthenticated)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        self?.authState = state
      }
      .store(in: &cancellables)
  }
}

// MARK: - Preview Support

#if DEBUG
extension ConvexManager {
  static func preview(authState: AuthState<String> = .unauthenticated) -> ConvexManager {
    let manager = ConvexManager()
    manager.cancellables.removeAll()
    manager.authState = authState
    return manager
  }
}
#endif

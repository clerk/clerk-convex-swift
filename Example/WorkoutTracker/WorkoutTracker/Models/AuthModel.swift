//
//  AuthModel.swift
//  WorkoutTracker
//
//

import Combine
import ConvexMobile
import SwiftUI

@MainActor
class AuthModel: ObservableObject {
  @Published var authState: AuthState<String> = .loading

  init() {
    client.authState
      .replaceError(with: .unauthenticated)
      .receive(on: DispatchQueue.main)
      .assign(to: &$authState)
  }
}

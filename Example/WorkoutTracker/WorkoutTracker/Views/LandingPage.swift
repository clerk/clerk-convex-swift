//
//  LandingPage.swift
//  WorkoutTracker
//
//

import ClerkKitUI
import SwiftUI
import ConvexMobile

struct LandingPage: View {
  @State private var authState: AuthState<String> = .loading
  @State private var authViewIsPresented = false

  var body: some View {
    Color.workoutBackground
      .ignoresSafeArea()
      .overlay {
        Group {
          switch authState {
          case .loading:
            ProgressView()
          case .unauthenticated:
            VStack {
              Image(uiImage: UIImage(named: "AppLogo") ?? UIImage())
              Text("Workout Tracker")
                .font(.largeTitle)
              Button {
                authViewIsPresented = true
              } label: {
                Text("Login")
                  .font(.title)
              }
            }
            .padding()
          case .authenticated:
            WorkoutsPage()
          }
        }
      }
      .sheet(isPresented: $authViewIsPresented) {
        AuthView()
      }
      .task {
        for await state in client.authState.values {
          authState = state
        }
      }
  }
}

#Preview {
  LandingPage()
}

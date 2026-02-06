//
//  LandingPage.swift
//  WorkoutTracker
//
//

import ClerkKitUI
import SwiftUI

struct LandingPage: View {
  @StateObject var authModel = AuthModel()
  @State private var authViewIsPresented = false

  var body: some View {
    Color.workoutBackground
      .ignoresSafeArea()
      .overlay {
        Group {
          switch authModel.authState {
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
  }
}

#Preview {
  LandingPage()
}

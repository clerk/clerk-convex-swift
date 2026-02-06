//
//  NavigationModel.swift
//  WorkoutTracker
//
//

import Foundation

class NavigationModel: ObservableObject {
  @Published var path: [WorkoutsPage.SubPages] = []

  func openEditor() {
    path.append(.workoutEditor)
  }

  func closeEditor() {
    path.removeAll()
  }
}

//
//  WorkoutDetailPage.swift
//  WorkoutTracker
//
//

import SwiftUI

struct WorkoutEditorPage: View {

  @StateObject var pendingWorkout = PendingWorkoutModel()
  @EnvironmentObject var navigationModel: NavigationModel

  var body: some View {
    Color.workoutBackground
      .ignoresSafeArea()
      .overlay {
        VStack {
          List {
            DatePicker(
              "Date",
              selection: $pendingWorkout.date,
              displayedComponents: .date
            ).listRowBackground(Color.workoutForeground)
            Picker("Activity", selection: $pendingWorkout.activity) {
              if pendingWorkout.activity == nil {
                Text("No selection").tag(nil as Activity?)
              }
              ForEach(Array(Activity.allCases)) { activity in
                Text(activity.rawValue).tag(Optional(activity))
              }
            }.listRowBackground(Color.workoutForeground)
            TextField("Duration", text: $pendingWorkout.rawDuration).keyboardType(.decimalPad)
              .listRowBackground(Color.workoutForeground)
          }.scrollContentBackground(.hidden)

          Button(action: { pendingWorkout.save(onSuccess: navigationModel.closeEditor) }) {
            Text("Save")
          }.disabled(!pendingWorkout.canSave).padding()
        }.navigationTitle("New workout")
      }
  }
}

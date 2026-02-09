//
//  WorkoutsModel.swift
//  WorkoutTracker
//
//

import Combine
import ConvexMobile
import SwiftUI

class WorkoutsModel: ObservableObject {
  @Published var workouts: [Workout] = []
  @Published var selectedStartOfWeek: Date
  @Published var workoutDays: Set<Day> = []

  init() {
    let dayOfWeek = Calendar.current.component(.weekday, from: Date.now)
    selectedStartOfWeek = calendar.date(
      byAdding: .day, value: dayTranslation[dayOfWeek]!, to: Date.now)!

    $selectedStartOfWeek
      .map({ week in
        client.subscribe(
          to: "workouts:getInRange",
          with: [
            "startDate": week.localIso8601DateFormat(),
            "endDate": calendar.date(byAdding: .day, value: 6, to: week)!
              .localIso8601DateFormat(),
          ]
        )
        .removeDuplicates()
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
      }).switchToLatest().assign(to: &$workouts)

    $workouts
      .map { weekWorkouts in
        Set(
          weekWorkouts.map { workout in
            workout.day
          })
      }.assign(to: &$workoutDays)
  }

  func nextWeek() {
    selectedStartOfWeek = calendar.date(
      byAdding: .day, value: 7, to: selectedStartOfWeek)!
  }

  func previousWeek() {
    selectedStartOfWeek = calendar.date(
      byAdding: .day, value: -7, to: selectedStartOfWeek)!
  }

  func delete(workout: Workout) {
    let args: [String: ConvexEncodable] = ["workoutId": workout.id]
    Task { @MainActor in
      try? await client.mutation("workouts:remove", with: args)
    }
  }
}

/// Keeps a map of Calendar component .weekday values to the number of days to subtract to reach
/// the most recent Monday.
private let dayTranslation = [1: -6, 2: 0, 3: -1, 4: -2, 5: -3, 6: -4, 7: -5]

enum Day: CaseIterable, Identifiable {
  var id: Self {
    self
  }

  case monday
  case tuesday
  case wednesday
  case thursday
  case friday
  case saturday
  case sunday
}

var calendar: Calendar {
  var calendar = Calendar.current
  calendar.timeZone = TimeZone(abbreviation: "UTC")!
  return calendar
}

extension Date {
  func localIso8601DateFormat() -> String {
    return self.ISO8601Format(.iso8601Date(timeZone: TimeZone.current))
  }
}

extension Workout {
  var day: Day {
    calendar.component(.weekday, from: self.date).toDay()
  }
}

extension Int {
  internal func toDay() -> Day {
    switch self {
    case 1: Day.sunday
    case 2: Day.monday
    case 3: Day.tuesday
    case 4: Day.wednesday
    case 5: Day.thursday
    case 6: Day.friday
    case 7: Day.saturday
    default:
      fatalError()
    }
  }
}

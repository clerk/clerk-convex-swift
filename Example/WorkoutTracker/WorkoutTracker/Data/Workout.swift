//
//  Workout.swift
//  WorkoutTracker
//
//

import ConvexMobile
import Foundation

private var dateFormatter: ISO8601DateFormatter {
  let dateFormatter = ISO8601DateFormatter()
  dateFormatter.formatOptions = [.withFullDate]
  dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
  return dateFormatter
}

struct Workout: Identifiable, Equatable, Decodable {
  let id: String
  let _date: String
  let activity: Activity
  @OptionalConvexInt
  var duration: Int?

  enum CodingKeys: String, CodingKey {
    case id = "_id"
    case _date = "date"
    case activity
    case duration
  }
}

extension Workout {
  var date: Date {
    dateFormatter.date(from: self._date)!
  }
}

enum Activity: String, Identifiable, CaseIterable, Codable {
  var id: Self {
    self
  }

  case running = "Running"
  case lifting = "Lifting"
  case walking = "Walking"
  case swimming = "Swimming"
}

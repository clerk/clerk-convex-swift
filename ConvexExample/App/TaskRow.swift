//
//  TaskRow.swift
//  ConvexExample
//

import ClerkKitUI
import SwiftUI

// MARK: - Task Row

struct TaskRow: View {
  @Environment(\.clerkTheme) private var theme
  let task: TodoTask
  let onToggle: () -> Void

  var body: some View {
    HStack {
      Button {
        onToggle()
      } label: {
        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
          .foregroundStyle(task.isCompleted ? theme.colors.success : theme.colors.mutedForeground)
          .font(theme.fonts.title2)
      }
      .buttonStyle(.plain)

      Text(task.text)
        .font(theme.fonts.body)
        .strikethrough(task.isCompleted)
        .foregroundStyle(task.isCompleted ? theme.colors.mutedForeground : theme.colors.foreground)

      Spacer()
    }
  }
}

// MARK: - Task Model

struct TodoTask: Decodable, Identifiable {
  let _id: String
  let text: String
  let isCompleted: Bool

  var id: String { _id }
}

// MARK: - Mock Data

extension TodoTask {
  static var mockIncomplete: TodoTask {
    TodoTask(_id: "1", text: "Buy groceries", isCompleted: false)
  }

  static var mockCompleted: TodoTask {
    TodoTask(_id: "2", text: "Walk the dog", isCompleted: true)
  }

  static var mockList: [TodoTask] {
    [
      TodoTask(_id: "1", text: "Buy groceries", isCompleted: false),
      TodoTask(_id: "2", text: "Walk the dog", isCompleted: true),
      TodoTask(_id: "3", text: "Finish project report", isCompleted: false),
      TodoTask(_id: "4", text: "Call mom", isCompleted: true),
      TodoTask(_id: "5", text: "Schedule dentist appointment", isCompleted: false),
    ]
  }
}

// MARK: - Previews

#Preview("Incomplete Task") {
  List {
    TaskRow(task: .mockIncomplete) {}
  }
  .listStyle(.plain)
}

#Preview("Completed Task") {
  List {
    TaskRow(task: .mockCompleted) {}
  }
  .listStyle(.plain)
}

#Preview("Task List") {
  List {
    ForEach(TodoTask.mockList) { task in
      TaskRow(task: task) {}
    }
  }
  .listStyle(.plain)
}

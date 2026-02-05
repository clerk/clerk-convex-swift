//
//  ContentView.swift
//  ConvexExample
//

import ClerkKit
import ClerkKitConvex
import ClerkKitUI
import Combine
import SwiftUI

struct ContentView: View {
  @State private var convex = ConvexManager()
  @State private var authViewIsPresented = false

  var body: some View {
    NavigationStack {
      Group {
        switch convex.authState {
        case .authenticated:
          TasksView()
        case .loading:
          ProgressView("Connecting...")
        case .unauthenticated:
          SignedOutView()
        }
      }
      .padding()
      .navigationTitle("Clerk + Convex")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          UserButton(signedOutContent: {
            Button("Sign in") {
              authViewIsPresented = true
            }
          })
        }
      }
      .sheet(isPresented: $authViewIsPresented) {
        AuthView()
      }
      .environment(convex)
    }
  }
}

// MARK: - Signed Out View

private struct SignedOutView: View {
  @Environment(\.clerkTheme) private var theme

  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "checklist")
        .font(.system(size: 60))
        .foregroundStyle(theme.colors.mutedForeground)
      Text("Sign in to see your tasks")
        .font(theme.fonts.headline)
        .foregroundStyle(theme.colors.foreground)
      Text("Your tasks are stored securely in Convex")
        .font(theme.fonts.subheadline)
        .foregroundStyle(theme.colors.mutedForeground)
    }
    .frame(maxHeight: .infinity)
  }
}

// MARK: - Tasks View

private struct TasksView: View {
  @Environment(\.clerkTheme) private var theme
  @Environment(ConvexManager.self) private var convex
  @State private var tasks: [TodoTask] = []
  @State private var newTaskText = ""

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        TextField("Add a task...", text: $newTaskText)
          .textFieldStyle(.roundedBorder)
          .onSubmit {
            Task {
              await addTask()
            }
          }

        Button {
          Task {
            await addTask()
          }
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(theme.fonts.title2)
            .foregroundStyle(theme.colors.primary)
        }
        .disabled(newTaskText.isEmpty)
      }

      List {
        ForEach(tasks) { task in
          TaskRow(task: task) {
            Task {
              await toggleTask(task)
            }
          }
        }
        .onDelete { indexSet in
          for index in indexSet {
            Task {
              await deleteTask(tasks[index])
            }
          }
        }
      }
      .listStyle(.plain)
    }
    .task {
      for await tasks in convexClient.subscribe(to: "tasks:get", yielding: [TodoTask].self)
        .replaceError(with: []).values
      {
        self.tasks = tasks
      }
    }
  }

  private func addTask() async {
    guard !newTaskText.isEmpty else { return }
    let text = newTaskText
    newTaskText = ""

    do {
      try await convexClient.mutation("tasks:add", with: ["text": text])
    } catch {
      await MainActor.run { newTaskText = text }
    }
  }

  private func toggleTask(_ task: TodoTask) async {
    try? await convexClient.mutation("tasks:toggle", with: ["id": task._id])
  }

  private func deleteTask(_ task: TodoTask) async {
    try? await convexClient.mutation("tasks:remove", with: ["id": task._id])
  }
}

// MARK: - Previews

#Preview("Signed Out") {
  ContentView()
    .environment(Clerk.preview { $0.isSignedIn = false })
    .environment(ConvexManager.preview(authState: .unauthenticated))
}

#Preview("Loading") {
  ContentView()
    .environment(Clerk.preview())
    .environment(ConvexManager.preview(authState: .loading))
}

#Preview("Signed In") {
  ContentView()
    .environment(Clerk.preview())
    .environment(ConvexManager.preview(authState: .authenticated("mock-token")))
}

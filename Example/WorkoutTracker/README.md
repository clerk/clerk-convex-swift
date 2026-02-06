# WorkoutTracker Example

Example iOS app for `ClerkConvex` using Clerk authentication with Convex.

## Setup

1. Open `ClerkConvex.xcworkspace` from the repository root.
2. Edit `Example/WorkoutTracker/WorkoutTracker/Env.swift` and set your Clerk publishable key and Convex deployment URL.
3. In `Example/WorkoutTracker/convex/auth.config.ts`, set your Clerk issuer URL.
4. Run `npx convex dev` from `Example/WorkoutTracker/convex`.
5. Build and run the `WorkoutTracker` scheme.

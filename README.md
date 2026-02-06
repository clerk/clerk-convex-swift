# ClerkConvex

`ClerkConvex` is a Swift package that bridges Clerk and Convex by automatically syncing Clerk session auth into `ConvexClientWithAuth`.

## Getting Started

If you haven't started a Convex app yet, begin with the
[Convex Swift iOS quickstart](https://docs.convex.dev/quickstart/ios) to get a working
Swift app connected to Convex.

Once you have a working Convex + Swift app, use the steps below to integrate Clerk.
Follow the [Clerk iOS quickstart](https://clerk.com/docs/ios/getting-started/quickstart) for app-side Clerk setup details.

1. Set up Clerk in your iOS app (create an app in Clerk, get your publishable key, and add Clerk SDK dependencies).
2. Configure Convex auth by creating `convex/auth.config.ts`:

```typescript
export default {
  providers: [
    {
      domain: "YOUR_CLERK_ISSUER_URL",
      applicationID: "convex",
    },
  ],
};
```

3. Run `npx convex dev` to sync backend auth configuration.
4. Add `ClerkConvex` to your app.
5. Wherever you currently create `ConvexClient`, switch to `ConvexClientWithAuth` and pass `ClerkConvexAuthProvider`:

```swift
import ClerkKit
import ClerkConvex
import ConvexMobile

Clerk.configure(publishableKey: "YOUR_CLERK_PUBLISHABLE_KEY")

let client = ConvexClientWithAuth(
  deploymentUrl: "YOUR_CONVEX_DEPLOYMENT_URL",
  authProvider: ClerkConvexAuthProvider()
)
```

6. Update other references of `ConvexClient` in your app code to `ConvexClientWithAuth`.

## Example App

This repo includes a full example app at `Example/WorkoutTracker`.

Open `ClerkConvex.xcworkspace` and run the `WorkoutTracker` scheme.

## Reacting to Authentication State

`ConvexClientWithAuth.authState` is a `Publisher` you can use to drive UI state for loading, signed-out, and signed-in flows.

With Clerk integration, the authenticated payload is the Clerk JWT string (`AuthState<String>`), which is sent to Convex for verification.

## Session Sync Behavior

`ClerkConvexAuthProvider` listens to Clerk session changes and keeps Convex auth in sync automatically.

- Sign in with Clerk: Convex auth is established automatically.
- Token refresh in Clerk: Convex receives refreshed tokens automatically.
- Sign out from Clerk: Convex auth is cleared automatically.

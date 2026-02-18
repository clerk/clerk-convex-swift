# ClerkConvex

`ClerkConvex` is a Swift package that bridges Clerk and Convex by automatically syncing Clerk session auth into `ConvexClientWithAuth`.

## Getting Started

If you haven't started a Convex app yet, begin with the
[Convex Swift quickstart](https://docs.convex.dev/quickstart/swift) to get a working
Swift app connected to Convex.

Once you have a working Convex + Swift app, use the steps below to integrate Clerk.
Follow the [Clerk iOS quickstart](https://clerk.com/docs/ios/getting-started/quickstart) for app-side Clerk setup details.

1. Set up Clerk in your iOS app (create an app in Clerk, get your publishable key, and add Clerk SDK dependencies).
2. In the Clerk Dashboard, complete the [Convex integration setup](https://dashboard.clerk.com/apps/setup/convex)
3. Configure Convex auth by creating `convex/auth.config.ts`:

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

4. Run `npx convex dev` to sync backend auth configuration.
5. Add `ClerkConvex` to your app.
6. Wherever you currently create `ConvexClient`, switch to `ConvexClientWithAuth` and pass `ClerkConvexAuthProvider`:

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

6. Authenticate users via Clerk; auth state is automatically synced to Convex.

### Reacting to authentication state

The `ConvexClientWithAuth.authState` field is a `Publisher` that contains the latest authentication state from the client. You can set up your UI to react to new `authState` values and show the appropriate screens (e.g. login/logout buttons, loading screens, authenticated content).

## Example App

This repo includes a full example app at `Example/WorkoutTracker`.

Open `ClerkConvex.xcworkspace` and run the `WorkoutTracker` scheme.

# ClerkConvex

`ClerkConvex` is an iOS Swift package that bridges Clerk and Convex by automatically syncing Clerk session auth into `ConvexClientWithAuth`.

## Prerequisites

1. A [Clerk](https://clerk.com) account and application
2. A [Convex](https://convex.dev) account and project
3. A Convex JWT provider configured for Clerk in your Convex backend project

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

## Installation

Add this package to your app and include `ClerkConvex`.

## Usage

```swift
import ClerkKit
import ClerkConvex
import ConvexMobile

Clerk.configure(publishableKey: "YOUR_CLERK_PUBLISHABLE_KEY")

let client = ConvexClientWithAuth(
  deploymentUrl: "YOUR_CONVEX_DEPLOYMENT_URL",
  authProvider: ClerkConvexAuthProvider()
)

// No manual client.login() call needed.
// ClerkConvexAuthProvider automatically syncs Convex auth with Clerk session changes.

// Queries and mutations
let result: MyType = try await client.query("myQuery")
```

## How It Works

1. User signs in with Clerk.
2. `ClerkConvexAuthProvider` observes Clerk session changes and triggers Convex auth sync.
3. The token is passed to Convex through `ConvexClientWithAuth`.
4. Convex validates the token and authenticates the user.

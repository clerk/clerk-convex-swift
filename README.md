# Clerk + Convex Example

This example app demonstrates how to integrate Clerk authentication with a Convex backend using the `ClerkKitConvex` module.

## Prerequisites

1. A [Clerk](https://clerk.com) account and application
2. A [Convex](https://convex.dev) account and project

## Setup

### 1. Configure Clerk

1. Get your **Publishable Key** from the [Clerk Dashboard](https://dashboard.clerk.com)
2. Create a JWT Template for Convex:
   - Go to **JWT Templates** in your Clerk Dashboard
   - Click **New Template** → **Convex**
   - Note the template name (default: "convex")
   - Copy the **Issuer URL** for Convex configuration

### 2. Configure Convex

1. Get your **Deployment URL** from the [Convex Dashboard](https://dashboard.convex.dev)
2. Configure authentication in your `convex/auth.config.ts`:

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

### 3. Update the App

Open `ConvexExample/App/ConvexExampleApp.swift` and replace:

- `YOUR_CLERK_PUBLISHABLE_KEY` with your Clerk publishable key
- `YOUR_CONVEX_DEPLOYMENT_URL` with your Convex deployment URL

### 4. Run the App

1. Open `ConvexExample.xcodeproj` in Xcode
2. Build and run on a simulator or device

## Usage

1. **Sign in with Clerk**: Tap the "Sign in with Clerk" button to authenticate using Clerk's pre-built UI
2. **Login to Convex**: After signing in, use the "Login" button to authenticate with Convex
3. **Auth State**: The auth state indicator shows your current Convex authentication status:
   - 🔴 Red = Not authenticated
   - 🟠 Orange = Authenticating
   - 🟢 Green = Authenticated
4. **Logout**: Use "Logout from Convex" to sign out of Convex, or sign out via the user button to sign out of both

## How It Works

The integration uses `ClerkKitConvex` which provides:

### ClerkConvexAuthProvider

Implements Convex's `AuthProvider` protocol using Clerk sessions:

```swift
// Create the auth provider
let authProvider = ClerkConvexAuthProvider(jwtTemplate: "convex")

// login() - Gets a fresh JWT token from the active Clerk session
let token = try await authProvider.login()

// loginFromCache() - Gets a cached token (if available and not expired)
let cachedToken = try await authProvider.loginFromCache()

// logout() - Signs out of the Clerk session
try await authProvider.logout()
```

### Creating a Convex Client

```swift
let client = ConvexClientWithAuth(
  deploymentUrl: "YOUR_CONVEX_URL",
  authProvider: ClerkConvexAuthProvider(jwtTemplate: "convex")
)

// Clerk.configure(...) must be called before creating the client.
// Session sync starts automatically; no separate sync object is required.

// After user signs in with Clerk
_ = await client.login()

// Use client for queries/mutations
let data: MyType = try await client.query("myQuery")
```

### Authentication Flow

1. User signs in via Clerk's `AuthView`
2. ClerkConvexAuthProvider detects the session change and calls `client.loginFromCache()`
3. ClerkConvexAuthProvider gets a JWT from the Clerk session using the "convex" template
4. JWT is passed to Convex via `setAuth(token:)`
5. Convex validates the JWT and authenticates the user
6. App can now make authenticated Convex queries/mutations

## Files Overview

```
ConvexExample/
├── App/
│   ├── ConvexExampleApp.swift    # App entry, configuration
│   └── ContentView.swift         # Main view with auth state
├── Utilities/
│   ├── ConvexManager.swift       # Convex + Clerk integration
│   └── AtlantisModifier.swift    # Network debugging
```

## Troubleshooting

### "No active Clerk session" error
Make sure to sign in with Clerk before attempting to login to Convex.

### Token not accepted by Convex
Verify that:
1. Your JWT template in Clerk is configured correctly
2. The issuer URL in Convex matches the one in your JWT template
3. The template name matches (default: "convex")

### Network debugging
This example includes [Atlantis](https://github.com/ProxymanApp/atlantis) for network debugging. Use [Proxyman](https://proxyman.io) to inspect network traffic.

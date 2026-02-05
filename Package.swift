// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "ClerkConvexIOS",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v26),
  ],
  products: [
    .library(name: "ClerkKitConvex", targets: ["ClerkKitConvex"]),
  ],
  dependencies: [
    .package(url: "https://github.com/clerk/clerk-ios.git", branch: "mike/clerk-v1"),
    .package(url: "https://github.com/seanperez29/convex-swift.git", branch: "feature/Handling-token-refresh"),
  ],
  targets: [
    .target(
      name: "ClerkKitConvex",
      dependencies: [
        .product(name: "ClerkKit", package: "clerk-ios"),
        .product(name: "ClerkKitUI", package: "clerk-ios"),
        .product(name: "ConvexMobile", package: "convex-swift"),
      ],
      path: "Sources/ClerkKitConvex",
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
  ]
)

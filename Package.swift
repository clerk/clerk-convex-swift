// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "ClerkConvex",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
  ],
  products: [
    .library(name: "ClerkConvex", targets: ["ClerkConvex"]),
  ],
  dependencies: [
    .package(url: "https://github.com/clerk/clerk-ios.git", branch: "mike/clerk-v1"),
    .package(url: "https://github.com/seanperez29/convex-swift.git", branch: "feature/Handling-token-refresh"),
  ],
  targets: [
    .target(
      name: "ClerkConvex",
      dependencies: [
        .product(name: "ClerkKit", package: "clerk-ios"),
        .product(name: "ConvexMobile", package: "convex-swift"),
      ],
      path: "Sources/ClerkKitConvex",
      swiftSettings: [
        .enableExperimentalFeature("StrictConcurrency"),
      ]
    ),
  ]
)

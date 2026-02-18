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
    .package(url: "https://github.com/clerk/clerk-ios.git", from: "1.0.0"),
    .package(url: "https://github.com/get-convex/convex-swift", from: "0.8.0"),
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

// swift-tools-version:5.3
import PackageDescription

let package = Package(
  name: "my-project",
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50500.0"))
  ],
  targets: [
    .target(name: "ast-test", dependencies: [
      .product(name: "SwiftSyntax", package: "swift-syntax")
      ]),
    ]
  )
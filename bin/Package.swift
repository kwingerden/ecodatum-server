// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "bin",
  products: [
    .library(name: "lib", targets: ["lib"]),
    .executable(name: "bin", targets: ["bin"])
  ],
  dependencies: [
    .package(
      url: "https://github.com/kylef/Commander.git", 
      .upToNextMajor(from: "0.8.0"))
  ],
  targets: [
    .target(
      name: "lib",
      dependencies: ["Commander"]),
    .target(
      name: "bin",
      dependencies: ["lib"]),
  ]
)

// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "ecodatum-server",
  products: [
    .library(
      name: "EcoDatumLib", 
      targets: [
        "EcoDatumLib"
      ]
    ),
    .executable(
      name: "EcoDatumServer", 
      targets: [
        "EcoDatumServer"
      ]
    )
  ],
  dependencies: [
    .package(
      url: "https://github.com/vapor/auth-provider.git", 
      .upToNextMajor(from: "1.2.0")),
    .package(
      url: "https://github.com/vapor/fluent-provider.git", 
      .upToNextMajor(from: "1.3.0")),
    .package(
      url: "https://github.com/vapor/leaf-provider.git", 
      .upToNextMajor(from: "1.1.0")),
    .package(
      url: "https://github.com/vapor/mysql-provider.git", 
      .upToNextMajor(from: "2.0.0")),
    .package(
      url: "https://github.com/vapor/vapor.git", 
      .upToNextMajor(from: "2.2.0")),
  ],
  targets: [
    .target(
      name: "EcoDatumLib", 
      dependencies: [
        "AuthProvider",
        "FluentProvider",
        "LeafProvider",
        "MySQLProvider",
        "Vapor"
      ],
      exclude: [
        "Config",
        "Database",
        "Public",
        "Resources"
      ]
    ),
    .target(
      name: "EcoDatumServer", 
      dependencies: [
        "EcoDatumLib"
      ]
    ),
    .testTarget(
      name: "EcoDatumLibTests", 
      dependencies: [
        "EcoDatumLib", 
        "Testing"
      ]
    )
  ]
)


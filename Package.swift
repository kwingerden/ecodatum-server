// swift-tools-version:4.0

import PackageDescription

let DEPENDENCIES = [
  "Vapor": (
    majorVersion: 2,
    url: "https://github.com/vapor/vapor.git"),
  "AuthProvider": (
    majorVersion: 1,
    url: "https://github.com/vapor/auth-provider.git"),
  "FluentProvider": (
    majorVersion: 1,
    url: "https://github.com/vapor/fluent-provider.git"),
  "LeafProvider": (
    majorVersion: 1,
    url: "https://github.com/vapor/leaf-provider.git"),
  "MySQLProvider": (
    majorVersion: 2,
    url: "https://github.com/vapor/mysql-provider.git")
]

func toPackage(_ name: String) -> PackageDescription.Package.Dependency {
  let url = DEPENDENCIES[name]!.url
  let majorVersion = DEPENDENCIES[name]!.majorVersion
  let upToNextMajor = PackageDescription.Package.Dependency.Requirement.upToNextMajor(
    from: PackageDescription.Version(majorVersion, 0, 0))
  return PackageDescription.Package.Dependency.package(url: url, upToNextMajor)
}

let PACKAGE_DEPENDENCIES = DEPENDENCIES.map {
  toPackage($0.key)
}

let TARGET_DEPENDENCIES = DEPENDENCIES.map {
  PackageDescription.Target.Dependency.byName(name: $0.key)
}

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
  dependencies: PACKAGE_DEPENDENCIES,
  targets: [
    .target(
      name: "EcoDatumLib", 
      dependencies: TARGET_DEPENDENCIES,
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


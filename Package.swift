// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "JUnitFormatter",
  products: [
    .library(name: "JUnitFormatter", type: .dynamic, targets: ["JUnitFormatter"])
  ],
  targets: [
    .target(name: "JUnitFormatter", dependencies: [])
  ]
)

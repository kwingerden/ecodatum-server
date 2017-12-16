import Foundation
@testable import EcoDatumLib
@testable import Vapor
import XCTest
import Testing

extension Droplet {
  
  static func testable() throws -> Droplet {
    
    let env = ProcessInfo.processInfo.environment["UNIT_TEST_ENV"] ?? "test"
    let config = try Config(arguments: ["vapor", "--env=\(env)"])
    try config.setup()
    
    config.addConfigurable(
      command: CreateRootUserCommand.init,
      name: "create-root-user")
    
    let drop = try Droplet(config)
    try drop.setup()
    drop.log.info("Testable Droplet has been initialized.")
    
    try CreateRootUserCommand(config: config).run(arguments: [])
    
    return drop
  
  }
  
  func serveInBackground() throws {
  
    background {
      try! self.run()
    }
    console.wait(seconds: 0.5)
  
  }
  
}

class TestCase: XCTestCase {
  
  override func setUp() {
  
    Node.fuzzy = [JSON.self, Node.self]
    Testing.onFail = XCTFail
  
  }
  
}


import Foundation
import HTTP
@testable import EcoDatumLib
@testable import Vapor
import XCTest
import Testing

extension Droplet {
  
  static func testable() throws -> Droplet {
    
    let env = ProcessInfo.processInfo.environment["UNIT_TEST_ENV"] ?? "development"
    let config = try Config(arguments: ["vapor", "--env=\(env)"])
    try config.setup()
    
    config.addConfigurable(
      command: InitializeDatabaseCommand.init,
      name: "initialize-database")
    
    let drop = try Droplet(config)
    try drop.setup()
    drop.log.info("Testable Droplet has been initialized.")
    
    try InitializeDatabaseCommand(config: config).run(arguments: [])
    
    return drop
  
  }
  
  func serveInBackground() throws {
  
    background {
      try! self.run()
    }
    console.wait(seconds: 0.5)
  
  }
  
  func readFileFully(_ path: String) throws -> Bytes {
    
    guard let file = fopen(path, "r") else {
      throw Abort(.expectationFailed)
    }
    
    let chunkSize = 2048
    var array: [Bytes] = []
    var buffer = Array(repeating: 0, count: chunkSize)
    var bytesRead: size_t = 0
    repeat {
      bytesRead = fread(&buffer, 1, chunkSize, file)
      if bytesRead > 0 {
        let chunk = Array(UnsafeRawBufferPointer(
          start: buffer,
          count: bytesRead))
        array.append(Bytes(chunk))
      }
    } while bytesRead == chunkSize
    
    let bytes = Bytes(array.joined().array)
    
    fclose(file)
    
    return bytes
  
  }
  
}

class TestCase: XCTestCase {
  
  override func setUp() {
  
    Node.fuzzy = [JSON.self, Node.self]
    Testing.onFail = XCTFail
  
  }
  
}

func createTestUser(_ modelManager: ModelManager) throws -> User {
  
  let randomString = String(randomUpperCaseAlphaNumericLength: 10)
  return try modelManager.createUser(
    name: "TestUser-\(randomString)",
    email: "test.\(randomString)@test.com",
    password: randomString)

}

func createTestOrganization(_ modelManager: ModelManager, _ user: User) throws -> Organization {
  
  let randomString = String(randomUpperCaseAlphaNumericLength: 10)
  return try modelManager.createOrganization(
    user: user,
    name: "Test Organization-\(randomString)")

}

func createTestSite(_ modelManager: ModelManager,
                    _ user: User,
                    _ organization: Organization) throws -> Site {
  
  let randomString = String(randomUpperCaseAlphaNumericLength: 10)
  return try modelManager.createSite(
    name: "Test Site-\(randomString)",
    latitude: 3.455,
    longitude: -234.22,
    altitude: 45.22,
    horizontalAccuracy: 23.5,
    verticalAccuracy: 3.6,
    user: user,
    organization: organization)

}



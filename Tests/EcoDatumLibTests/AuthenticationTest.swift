import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class AuthenticationTest: TestCase {

  let drop = try! Droplet.testable()
  
  func test() throws {
    
    // Create user
    try drop.testResponse(
      to: .post,
      at: "/users",
      hostname: "0.0.0.0",
      headers: [
        "Content-Type": "application/json"
      ],
      body: """
{
  "name": "Test User",
  "email": "test.user@email.com",
  "password": "password"
}
""")
      .assertStatus(is: .ok)
      .assertJSON("id",  passes: { json in json.int != nil })
      .assertJSON("name", equals: "Test User")
      .assertJSON("email", equals: "test.user@email.com")
    
    // Login as user and obtain token
    let tokenResponse = try drop.testResponse(
      to: .post,
      at: "/login",
      hostname: "0.0.0.0",
      headers: [
        "Authorization": "Basic dGVzdC51c2VyQGVtYWlsLmNvbTpwYXNzd29yZA==",
        "Content-Type": "application/json"
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertJSON("token", passes: { json in json.string != nil })
    
    // Get token from response
    guard let json = tokenResponse.json else {
      XCTFail("Error getting JSON from toekn response \(tokenResponse)")
      return
    }
    guard let object = json.object,
    let token = object["token"]?.string else {
      XCTFail("expected response json to be an array")
      return
    }
    
    // User authentication token to access protected resource
    try drop.testResponse(
      to: .get,
      at: "/me",
      hostname: "0.0.0.0",
      headers: [
        "Authorization": "Bearer \(token)"
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertBody(equals: "Hello, Test User")
    
  }
  
}

// MARK: Manifest

extension AuthenticationTest {
  
  // Needed for Linux tests. Make sure to update MainLinux.swift when new tests are added.
  static let allTests = [("test", test)]

}

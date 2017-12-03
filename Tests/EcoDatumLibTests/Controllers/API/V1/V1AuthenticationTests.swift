import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1AuthenticationTests: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let hostname = "0.0.0.0"
    let name = "Test User"
    let email = "test.user@email.com"
    let password = "password"
    
    // Create user
    try drop.testResponse(
      to: .post,
      at: "/api/v1/users",
      hostname: hostname,
      headers: [
        Constants.CONTENT_TYPE_HEADER_KEY : Constants.JSON_CONTENT_TYPE
      ],
      body: JSON(node: [
        User.Keys.name: name,
        User.Keys.email: email,
        User.Keys.password: password]))
      .assertStatus(is: .ok)
      .assertJSON(User.Keys.id,  passes: { json in json.int != nil })
      .assertJSON(User.Keys.name, equals: name)
      .assertJSON(User.Keys.email, equals: email)
    
    // Login as user and obtain token
    let tokenResponse = try drop.testResponse(
      to: .post,
      at: "/api/v1/login",
      hostname: hostname,
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY : email.basicAuthorization(password: password),
        Constants.CONTENT_TYPE_HEADER_KEY : Constants.JSON_CONTENT_TYPE
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertJSON(Token.Keys.token, passes: { json in json.string != nil })
    
    // Get token from response
    guard let json = tokenResponse.json,
      let token: String = try json.get(Token.Keys.token) else {
        XCTFail("Error getting JSON from token response \(tokenResponse)")
        return
    }
    
    // User authentication token to access protected resource
    try drop.testResponse(
      to: .get,
      at: "/api/v1/me",
      hostname: hostname,
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: token.bearerAuthorization()
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertBody(equals: "Hello, Test User")
    
  }
  
}

// MARK: Manifest

extension V1AuthenticationTests {
  
  // Needed for Linux tests. Make sure to update MainLinux.swift when new tests are added.
  static let allTests = [("test", test)]
  
}

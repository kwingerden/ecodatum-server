import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1APIAuthenticationTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let rootUserToken = try drop.loginRootUser()
    let testUser1 = try drop.createTestUser(1, rootUserToken)
    let testUser1Token = try drop.loginTestUser(testUser1.email)
    try drop.assertMe("Hello, \(testUser1.name)", testUser1Token)
    
    /*
    // Use fake authentication token, which should fail
    try drop.testResponse(
      to: .get,
      at: "/api/v1/me",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: "cw8zlApGsLlQYaBJSzsQWw==".bearerAuthorization()
      ],
      body: nil)
      .assertStatus(is: .unauthorized)
    
    // Create user
    try drop.testResponse(
      to: .post,
      at: "/api/v1/users",
      headers: [
        Constants.CONTENT_TYPE_HEADER_KEY : Constants.JSON_CONTENT_TYPE
      ],
      body: testUser1)
      .assertStatus(is: .ok)
      .assertJSON(User.Keys.id,  passes: { json in json.int != nil })
      .assertJSON(User.Keys.name, equals: name)
      .assertJSON(User.Keys.email, equals: email)
    
    // Login as user and obtain token
    let tokenResponse = try drop.testResponse(
      to: .post,
      at: "/api/v1/login",
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
    
    // Use authentication token to access protected resource
    try drop.testResponse(
      to: .get,
      at: "/api/v1/me",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: token.bearerAuthorization()
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertBody(equals: "Hello, Test User")
    
    // Logout user
    try drop.testResponse(
      to: .get,
      at: "/api/v1/logout",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: token.bearerAuthorization()
      ],
      body: nil)
      .assertStatus(is: .ok)
    
    // Make sure cannot access protected page anymore.
    try drop.testResponse(
      to: .get,
      at: "/api/v1/me",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: token.bearerAuthorization()
      ],
      body: nil)
      .assertStatus(is: .unauthorized)
 */
    
  }
  
}


import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

extension Droplet {
  
  func loginRootUser() throws -> String {
    
    guard let rootUser = config.wrapped.object?["app"]?["root-user"],
      let email = rootUser["email"]?.string,
      let password = rootUser["password"]?.string else {
        throw Abort(.badRequest)
    }
    
    let response = try testResponse(
      to: .post,
      at: "/api/v1/login",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY : email.basicAuthorization(password: password)
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertJSON(Token.Keys.token, passes: { json in json.string != nil })
  
    guard let json = response.json,
      let token: String = try json.get(Token.Keys.token) else {
        XCTFail("Error getting JSON from response \(response)")
        throw Abort(.badRequest)
    }
    
    return token
  
  }
  
  func createTestUser(_ index: Int, _ rootUserToken: String, isAdmin: Bool = false)
    throws -> (id: Int, name: String, email: String, isAdmin: Bool) {
    
    let name = "Test User\(index)"
    let email = "test.user\(index)@email.com"
      
    let response = try testResponse(
      to: .post,
      at: "/api/v1/users",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: rootUserToken.bearerAuthorization(),
        Constants.CONTENT_TYPE_HEADER_KEY : Constants.JSON_CONTENT_TYPE
      ],
      body: JSON(node: [
          User.Keys.name: name,
          User.Keys.email: email,
          User.Keys.password: "password",
          User.Keys.isAdmin: isAdmin
        ]))
      .assertStatus(is: .ok)
      .assertJSON(User.Keys.id,  passes: { json in json.int != nil })
      .assertJSON(User.Keys.name, equals: name)
      .assertJSON(User.Keys.email, equals: email)
      .assertJSON(User.Keys.isAdmin, equals: isAdmin ? 1 : 0)
    
    guard let json = response.json else {
        XCTFail("Error getting JSON from response \(response)")
        throw Abort(.badRequest)
    }
    
    return (id: try json.get(User.Keys.id),
            name: try json.get(User.Keys.name),
            email: try json.get(User.Keys.email),
            isAdmin: try json.get(User.Keys.isAdmin))
    
  }
  
  func loginTestUser(_ email: String) throws -> String {
    
    let response = try testResponse(
      to: .post,
      at: "/api/v1/login",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY : email.basicAuthorization(password: "password"),
        Constants.CONTENT_TYPE_HEADER_KEY : Constants.JSON_CONTENT_TYPE
      ],
      body: nil)
      .assertStatus(is: .ok)
      .assertJSON(Token.Keys.token, passes: { json in json.string != nil })
    
    guard let json = response.json,
      let token: String = try json.get(Token.Keys.token) else {
        XCTFail("Error getting JSON from response \(response)")
        throw Abort(.badRequest)
    }
    
    return token
    
  }
  
  func assertMe(_ name: String, _ token: String) throws {
    
    try testResponse(
      to: .get,
      at: "/api/v1/me",
      headers: [
        Constants.AUTHORIZATION_HEADER_KEY: token.bearerAuthorization()
      ])
      .assertStatus(is: .ok)
      .assertBody(equals: name)
    
  }
 
}

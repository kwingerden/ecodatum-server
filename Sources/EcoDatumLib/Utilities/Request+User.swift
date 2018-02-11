import HTTP
import Vapor

extension Request {
  
  func assertJson() throws -> JSON {
    guard let json = json else {
      throw Abort(.badRequest, reason: "Invalid type. Expecting JSON.")
    }
    return json
  }
  
  func user() throws -> User {
    return try auth.assertAuthenticated()
  }
  
}

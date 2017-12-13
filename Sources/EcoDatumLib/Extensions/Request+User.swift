import HTTP

extension Request {
  
  func user() throws -> User {
    return try auth.assertAuthenticated()
  }
  
}

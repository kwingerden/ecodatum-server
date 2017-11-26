import AuthProvider
import Vapor

extension Droplet {
  
  func setupTokenProtectedRoutes() throws {
    let builder = grouped([TokenAuthenticationMiddleware(User.self)])
    builder.get("me", handler: getMe)
  }
  
  private func getMe(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    return "Hello, \(user.name)"
  }
  
}


import AuthProvider
import Vapor

extension Droplet {
  
  func setupPasswordProtectedRoutes() throws {
    let builder = grouped([PasswordAuthenticationMiddleware(User.self)])
    builder.post("login", handler: login)
  }
  
  private func login(_ request: Request) throws -> ResponseRepresentable {
    let user = try request.user()
    let token = try Token.generate(for: user)
    try token.save()
    return token
  }
  
}

import Authentication
import HTTP

final class TokenExpirationMiddleware: Middleware {
  
  let expirationSeconds: Int
  
  init(_ expirationSeconds: Int) {
    self.expirationSeconds = expirationSeconds
  }
  
  func respond(to request: Request,
               chainingTo next: Responder) throws -> Response {
    guard let bearerToken = request.auth.header?.bearer else {
      return try next.respond(to: request)
    }
    
    let databaseTokenOptional = try Token.makeQuery()
      .filter(
        Token.Keys.token,
        .equals,
        bearerToken.string)
      .first()
    guard let databaseToken = databaseTokenOptional,
      let databaseTokenCreatedAt = databaseToken.createdAt else {
        return try next.respond(to: request)
    }
    
    if Int(databaseTokenCreatedAt.timeIntervalSinceNow) < -expirationSeconds {
      try Token.find(databaseToken.id)?.delete()
    }
    
    return try next.respond(to: request)
  }
  
}

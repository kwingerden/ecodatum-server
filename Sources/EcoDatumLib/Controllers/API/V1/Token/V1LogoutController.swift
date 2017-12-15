import Vapor
import HTTP

final class V1LogoutController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /logout
  func index(_ request: Request) throws -> ResponseRepresentable {
    // Remove all tokens associated with the user
    try drop.database?.transaction {
      connection in
      let userId = try request.user().id
      let tokens = try Token.makeQuery(connection)
        .filter(Token.Keys.userId,
                .equals,
                userId)
        .all()
      try tokens.forEach {
        token in
        try Token.makeQuery(connection).delete(token)
      }
    }
    // Remove any cached authorization tokens
    try request.auth.unauthenticate()
    return Response(status: .ok)
  }
  
  func makeResource() -> Resource<String> {
    return Resource(index: index)
  }
  
}



import Vapor
import HTTP

final class APIV1TokenLogoutController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
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



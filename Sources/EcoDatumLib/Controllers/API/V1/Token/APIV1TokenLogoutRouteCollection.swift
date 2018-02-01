import Vapor
import HTTP

final class APIV1TokenLogoutRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    routeBuilder.get(handler: logout)
  }
  
  // GET /logout
  func logout(_ request: Request) throws -> ResponseRepresentable {
    
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
  
}

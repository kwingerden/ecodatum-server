import AuthProvider
import Foundation
import Vapor

final class RootUserToken: JSONRepresentable {
  
  let isRootUser: Bool
  
  let token: Token
  
  struct Json {
    static let isRootUser = "isRootUser"
    static let token = "token"
  }
  
  init(isRootUser: Bool,
       token: Token) throws {
    self.isRootUser = isRootUser
    self.token = token
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Token.Json.id, token.id)
    try json.set(Token.Json.userId, token.userId)
    try json.set(Token.Json.token, token.token)
    try json.set(Json.isRootUser, isRootUser)
    return json
  }
  
}

extension RootUserToken: ResponseRepresentable { }







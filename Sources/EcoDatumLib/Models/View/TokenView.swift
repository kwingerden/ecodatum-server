import AuthProvider
import Crypto
import Foundation
import Vapor

extension Token: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let token = Keys.token
    static let userId = "userId"
  }
  
  convenience init(json: JSON) throws {
    self.init(token: try json.get(Json.token),
              userId: try json.get(Json.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.token, token)
    try json.set(Json.userId, userId)
    return json
  }
  
}

extension Token {
  
  static func generate(for user: User) throws -> Token {
    let random = try Crypto.Random.bytes(count: 16)
    return try Token(
      token: random.base64Encoded.makeString(),
      userId: user.assertExists())
  }
  
}

extension Token: ResponseRepresentable { }

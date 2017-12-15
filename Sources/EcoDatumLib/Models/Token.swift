import Vapor
import AuthProvider
import FluentProvider
import Crypto

final class Token: Model {
  
  let storage = Storage()
  
  /// The actual token
  let token: String
  
  /// The identifier of the user to which the token belongs
  let userId: Identifier
  
  struct Keys {
    static let id = "id"
    static let token = "token"
    static let userId = User.foreignIdKey
  }
  
  init(token: String,
       userId: Identifier) {
    self.token = token
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    token = try row.get(Keys.token)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.token, token)
    try row.set(Keys.userId, userId)
    return row
  }
}

// MARK: Convenience

extension Token {

  static func generate(for user: User) throws -> Token {
    let random = try Crypto.Random.bytes(count: 16)
    return try Token(
      token: random.base64Encoded.makeString(),
      userId: user.assertExists())
  }
  
}

// MARK: Relations

extension Token {
  
  var user: Parent<Token, User> {
    return parent(id: userId)
  }
  
}

// MARK: Preparation

extension Token: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(Token.self) {
      builder in
      builder.id()
      builder.string(Keys.token)
      builder.foreignId(for: User.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(Token.self)
  }
  
}

// MARK: JSON

extension Token: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(token: try json.get(Keys.token),
              userId: try json.get(Keys.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.token, token)
    try json.set(Keys.userId, userId)
    return json
  }
  
}

// MARK: HTTP

extension Token: ResponseRepresentable { }


// MARK: TIMESTAMP

extension Token: Timestampable { }



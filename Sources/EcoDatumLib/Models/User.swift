import Vapor
import FluentProvider
import AuthProvider
import HTTP

final class User: Model {
  
  let storage = Storage()
  
  /// The name of the user
  var name: String
  
  /// The user's email
  var email: String
  
  /// The user's _hashed_ password
  var password: String?
  
  var isAdmin: Bool
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let email = "email"
    static let password = "password"
    static let isAdmin = "is_admin"
  }
  
  init(name: String,
       email: String,
       password: String? = nil,
       isAdmin: Bool = false) {
    self.name = name
    self.email = email
    self.password = password
    self.isAdmin = isAdmin
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    email = try row.get(Keys.email)
    password = try row.get(Keys.password)
    isAdmin = try row.get(Keys.isAdmin)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.email, email)
    try row.set(Keys.password, password)
    try row.set(Keys.isAdmin, isAdmin)
    return row
  }
  
}

// MARK: Preparation

extension User: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Keys.name)
      builder.string(Keys.email)
      builder.string(Keys.password)
      builder.bool(Keys.isAdmin)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: JSON

extension User: JSONRepresentable {
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name)
    try json.set(Keys.email, email)
    try json.set(Keys.isAdmin, isAdmin)
    return json
  }
  
}

// MARK: HTTP

extension User: ResponseRepresentable { }

// MARK: Password

extension User: PasswordAuthenticatable {

  var hashedPassword: String? {
    return password
  }
  
  public static var passwordVerifier: PasswordVerifier? {
    get { return _userPasswordVerifier }
    set { _userPasswordVerifier = newValue }
  }
  
}

private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: TIMESTAMP

extension User: Timestampable { }

// MARK: DELETE

extension User: SoftDeletable { }

// MARK: Token

extension User: TokenAuthenticatable {

  typealias TokenType = Token

}


import FluentProvider
import AuthProvider
import Vapor

final class User: EquatableModel {
  
  let storage = Storage()
  
  /// The name of the user
  var name: String
  
  /// The user's email
  var email: String
  
  /// The user's _hashed_ password
  var password: String
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let email = "email"
    static let password = "password"
  }
  
  init(name: String,
       email: String,
       password: String) {
    self.name = name
    self.email = email
    self.password = password
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    email = try row.get(Keys.email)
    password = try row.get(Keys.password)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.email, email)
    try row.set(Keys.password, password)
    return row
  }
  
}

// MARK: Preparation

extension User: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        length: 30,
        optional: false,
        unique: false)
      builder.string(
        Keys.email,
        length: 255,
        optional: false,
        unique: true)
      builder.string(
        Keys.password,
        length: 255,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension User {
  
  var userOrganizationRoles: Children<User, UserOrganizationRole> {
    return children()
  }
  
  var sites: Children<User, Site> {
    return children()
  }
  
  var surveys: Children<User, Survey> {
    return children()
  }

}

// MARK: TIMESTAMP

extension User: Timestampable { }



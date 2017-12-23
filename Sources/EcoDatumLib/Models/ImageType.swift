import Vapor
import FluentProvider
import HTTP

final class ImageType: Model {
  
  enum Name: String {
    case GIF
    case JPEG
    case PNG
    static let all: [Name] = [
      .GIF,
      .JPEG,
      .PNG
    ]
  }
  
  let storage = Storage()
  
  let name: Name
  
  struct Keys {
    static let id = "id"
    static let name = "name"
  }
  
  init(name: Name) {
    self.name = name
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    guard let name = Name(rawValue: try row.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.name = name
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name.rawValue)
    return row
  }
}

// MARK: Preparation

extension ImageType: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        optional: false,
        unique: true)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: JSON

extension ImageType: JSONConvertible {
  
  convenience init(json: JSON) throws {
    guard let name = Name(rawValue: try json.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.init(name: name)
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.name, name.rawValue)
    return json
  }
  
}

// MARK: HTTP

extension ImageType: ResponseRepresentable { }






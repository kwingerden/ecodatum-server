import FluentProvider
import Foundation
import Vapor

final class QualitativeObservationType: EquatableModel {

  enum Name: String {

    case Image
    case AudioClip
    case Note

    static let all: [Name] = [
      .Image,
      .AudioClip,
      .Note
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

extension QualitativeObservationType: Preparation {

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





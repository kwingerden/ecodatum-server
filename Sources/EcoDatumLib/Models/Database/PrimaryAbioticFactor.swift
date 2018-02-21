import FluentProvider
import Vapor

final class PrimaryAbioticFactor: EquatableModel {

  enum Name: String {
    case Air
    case Soil
    case Water
    static let all: [
    (
      name: Name,
      description: String
    )] = [
      (
        name: .Air,
        description: """
        Air is the invisible mixture of gases (such as nitrogen and oxygen) 
        that surrounds the Earth and that people and animals breathe.
        """
      ),
      (
        name: .Soil,
        description: """
        Soil is a mixture of organic matter, minerals, gases, liquids, 
        and organisms that together support life.
        """
      ),
      (
        name: .Water,
        description: """
        Water is a clear liquid that has no color, taste, or smell, that 
        falls from clouds as rain, that forms streams, lakes, and seas, 
        and that is used for drinking, washing, etc.
        """
      )
    ]
  }

  let storage = Storage()

  let name: Name

  let description: String

  struct Keys {
    static let id = "id"
    static let name = "name"
    static let description = "description"
  }

  init(name: Name,
       description: String) {
    self.name = name
    self.description = description
  }

  // MARK: Row

  init(row: Row) throws {
    guard let name = Name(rawValue: try row.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.name = name
    description = try row.get(Keys.description)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name.rawValue)
    try row.set(Keys.description, description)
    return row
  }
}

// MARK: Preparation

extension PrimaryAbioticFactor: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        optional: false,
        unique: true)
      builder.string(
        Keys.description,
        length: 500,
        optional: false,
        unique: false)
    }
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}





import Foundation
import Vapor

extension SecondaryAbioticFactor: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let name = Keys.name
    static let label = Keys.label
    static let description = Keys.description
  }
  
  convenience init(json: JSON) throws {
    guard let name = Name(rawValue: try json.get(Json.name)) else {
      throw Abort(.internalServerError)
    }
    self.init(
      name: name,
      label: try json.get(Json.label),
      description: try json.get(Json.description))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.name, name.rawValue)
    try json.set(Json.label, label)
    try json.set(Json.description, description)
    return json
  }
  
}

extension SecondaryAbioticFactor: ResponseRepresentable { }


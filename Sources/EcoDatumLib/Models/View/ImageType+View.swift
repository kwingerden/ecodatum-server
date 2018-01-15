import Foundation
import Vapor

extension ImageType: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let name = Keys.name
  }
  
  convenience init(json: JSON) throws {
    guard let name = Name(rawValue: try json.get(Json.name)) else {
      throw Abort(.internalServerError)
    }
    self.init(name: name)
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.name, name.rawValue)
    return json
  }
  
}

extension ImageType: ResponseRepresentable { }

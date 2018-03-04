import Foundation
import Vapor

extension Organization: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let name = Keys.name
    static let description = Keys.description
    static let code = Keys.code
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
  }
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Json.name),
              description: try json.get(Json.description),
              code: try json.get(Json.code))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.name, name)
    try json.set(Json.description, description)
    try json.set(Json.code, code)
    try json.set(Json.createdAt, createdAt)
    try json.set(Json.updatedAt, updatedAt)
    return json
  }
  
}

extension Organization: ResponseRepresentable { }

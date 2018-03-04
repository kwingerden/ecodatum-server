import Foundation
import Vapor

extension Image: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let image = Keys.image
    static let code = Keys.code
    static let description = Keys.description
    static let imageTypeId = "imageTypeId"
    static let surveyId = "surveyId"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
  }
  
  convenience init(json: JSON) throws {
    self.init(code: try json.get(Json.code),
              description: try json.get(Json.description),
              imageTypeId: try json.get(Json.imageTypeId),
              surveyId: try json.get(Json.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.code, code)
    try json.set(Json.description, description)
    try json.set(Json.imageTypeId, imageTypeId)
    try json.set(Json.surveyId, surveyId)
    try json.set(Json.createdAt, createdAt)
    try json.set(Json.updatedAt, updatedAt)
    return json
  }
  
}

extension Image: ResponseRepresentable { }

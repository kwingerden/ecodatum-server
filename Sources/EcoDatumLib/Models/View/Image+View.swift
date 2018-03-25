import Bits
import FluentProvider
import Foundation
import Vapor

extension Image: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let base64Encoded = "base64Encoded"
    static let description = Keys.description
    static let imageTypeId = "imageTypeId"
    static let surveyId = "surveyId"
    static let userId = "userId"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
  }
  
  convenience init(json: JSON) throws {
    let base64Encoded: String = try json.get(Json.base64Encoded)
    let imageBytes = base64Encoded.makeBytes().base64Decoded
    let image = Blob(bytes: imageBytes)
    self.init(
      image: image,
      description: try json.get(Json.description),
      imageTypeId: try json.get(Json.imageTypeId),
      surveyId: try json.get(Json.surveyId),
      userId: try json.get(Json.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.description, description)
    try json.set(Json.imageTypeId, imageTypeId)
    try json.set(Json.surveyId, surveyId)
    try json.set(Json.createdAt, createdAt)
    try json.set(Json.updatedAt, updatedAt)
    return json
  }
  
}

extension Image: ResponseRepresentable { }

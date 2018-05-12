import Foundation
import Vapor

extension EcoDatum: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let json = Keys.json
    static let siteId = "siteId"
    static let userId = "userId"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
  }
  
  convenience init(json: JSON) throws {
    self.init(json: try json.get(Json.json),
    siteId: try json.get(Json.siteId),
    userId: try json.get(Json.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.json, self.json)
    try json.set(Json.siteId, siteId)
    try json.set(Json.userId, userId)
    try json.set(Json.createdAt, createdAt)
    try json.set(Json.updatedAt, updatedAt)
    return json
  }
  
}

extension EcoDatum: ResponseRepresentable { }


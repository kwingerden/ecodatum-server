import Foundation
import Vapor

extension Site: JSONConvertible {

  struct Json {
    static let id = Keys.id
    static let name = Keys.name
    static let description = Keys.description
    static let latitude = Keys.latitude
    static let longitude = Keys.longitude
    static let altitude = Keys.altitude
    static let horizontalAccuracy = "horizontalAccuracy"
    static let verticalAccuracy = "verticalAccuracy"
    static let organizationId = "organizationId"
    static let userId = "userId"
    static let createdAt = "createdAt"
    static let updatedAt = "updatedAt"
  }
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Json.name),
              description: try json.get(Json.description),
              latitude: try json.get(Json.latitude),
              longitude: try json.get(Json.longitude),
              altitude: try json.get(Json.altitude),
              horizontalAccuracy: try json.get(Json.horizontalAccuracy),
              verticalAccuracy: try json.get(Json.verticalAccuracy),
              organizationId: try json.get(Json.organizationId),
              userId: try json.get(Json.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.name, name)
    try json.set(Json.description, description)
    try json.set(Json.latitude, latitude)
    try json.set(Json.longitude, longitude)
    try json.set(Json.altitude, altitude)
    try json.set(Json.horizontalAccuracy, horizontalAccuracy)
    try json.set(Json.verticalAccuracy, verticalAccuracy)
    try json.set(Json.organizationId, organizationId)
    try json.set(Json.userId, userId)
    try json.set(Json.createdAt, createdAt)
    try json.set(Json.updatedAt, updatedAt)
    return json
  }
  
}

extension Site: ResponseRepresentable { }

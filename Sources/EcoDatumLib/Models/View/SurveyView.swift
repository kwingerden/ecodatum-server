import Foundation
import Vapor

extension Survey: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let date = Keys.date
    static let siteId = "siteId"
    static let userId = "userId"
  }
  
  convenience init(json: JSON) throws {
    self.init(date: try json.get(Json.date),
              siteId: try json.get(Json.siteId),
              userId: try json.get(Json.userId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.date, date)
    try json.set(Json.siteId, siteId)
    try json.set(Json.userId, userId)
    return json
  }
  
}

extension Survey: ResponseRepresentable { }

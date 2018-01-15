import Foundation
import Vapor

extension Note: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let text = Keys.text
    static let surveyId = "surveyId"
  }
  
  convenience init(json: JSON) throws {
    self.init(text: try json.get(Json.text),
              surveyId: try json.get(Json.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.text, text)
    try json.set(Json.surveyId, surveyId)
    return json
  }
  
}

extension Note: ResponseRepresentable { }

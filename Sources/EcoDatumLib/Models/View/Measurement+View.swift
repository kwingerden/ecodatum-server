import Foundation
import Vapor

extension Measurement: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let value = Keys.value
    static let abioticFactorId = "abioticFactorId"
    static let measurementUnitId = "measurementUnitId"
    static let surveyId = "surveyId"
  }
  
  convenience init(json: JSON) throws {
    self.init(value: try json.get(Json.value),
              abioticFactorId: try json.get(Json.abioticFactorId),
              measurementUnitId: try json.get(Json.measurementUnitId),
              surveyId: try json.get(Json.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.value, value)
    try json.set(Json.abioticFactorId, abioticFactorId)
    try json.set(Json.measurementUnitId, measurementUnitId)
    try json.set(Json.surveyId, surveyId)
    return json
  }
  
}

extension Measurement: ResponseRepresentable { }

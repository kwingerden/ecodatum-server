import Foundation
import Vapor

extension Measurement: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let value = Keys.value
    static let primaryAbioticFactorId = "primaryAbioticFactorId"
    static let secondaryAbioticFactorId = "secondaryAbioticFactorId"
    static let measurementUnitId = "measurementUnitId"
    static let surveyId = "surveyId"
  }
  
  convenience init(json: JSON) throws {
    self.init(
      value: try json.get(Json.value),
      primaryAbioticFactorId: try json.get(Json.primaryAbioticFactorId),
      secondaryAbioticFactorId: try json.get(Json.secondaryAbioticFactorId),
      measurementUnitId: try json.get(Json.measurementUnitId),
      surveyId: try json.get(Json.surveyId))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.value, value)
    try json.set(Json.primaryAbioticFactorId, primaryAbioticFactorId)
    try json.set(Json.secondaryAbioticFactorId, secondaryAbioticFactorId)
    try json.set(Json.measurementUnitId, measurementUnitId)
    try json.set(Json.surveyId, surveyId)
    return json
  }
  
}

extension Measurement: ResponseRepresentable { }

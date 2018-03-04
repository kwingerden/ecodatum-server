import Foundation
import Vapor

extension MeasurementUnit: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let dimension = Keys.dimension
    static let unit = Keys.unit
    static let label = Keys.label
    static let description = Keys.description
  }
  
  convenience init(json: JSON) throws {
    guard let dimension = Dimension(rawValue: try json.get(Json.dimension)) else {
      throw Abort(.internalServerError)
    }
    guard let unit = Unit(rawValue: try json.get(Json.unit)) else {
      throw Abort(.internalServerError)
    }
    self.init(
      dimension: dimension,
      unit: unit,
      label: try json.get(Json.label),
      description: try json.get(Json.description))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.dimension, dimension.rawValue)
    try json.set(Json.unit, unit.rawValue)
    try json.set(Json.label, label)
    try json.set(Json.description, description)
    return json
  }
  
}

extension MeasurementUnit: ResponseRepresentable { }


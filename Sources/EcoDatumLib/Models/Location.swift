import FluentProvider
import Foundation
import Vapor

final class Location: Model {
  
  let storage = Storage()
  
  let latitude: Double
  
  let longitude: Double
  
  let altitude: Double?
  
  let horizontalAccuracy: Double
  
  let verticalAccuracy: Double
  
  struct Keys {
    static let id = "id"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let altitude = "altitude"
    static let horizontalAccuracy = "horizontal_accuracy"
    static let verticalAccuracy = "vertical_accuracy"
  }
  
  init(latitude: Double,
       longitude: Double,
       altitude: Double? = nil,
       horizontalAccuracy: Double,
       verticalAccuracy: Double) {
    self.latitude = latitude
    self.longitude = longitude
    self.altitude = altitude
    self.horizontalAccuracy = horizontalAccuracy
    self.verticalAccuracy = verticalAccuracy
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    latitude = try row.get(Keys.latitude)
    longitude = try row.get(Keys.longitude)
    altitude = try row.get(Keys.altitude)
    horizontalAccuracy = try row.get(Keys.horizontalAccuracy)
    verticalAccuracy = try row.get(Keys.verticalAccuracy)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.latitude, latitude)
    try row.set(Keys.longitude, longitude)
    try row.set(Keys.altitude, altitude)
    try row.set(Keys.horizontalAccuracy, horizontalAccuracy)
    try row.set(Keys.verticalAccuracy, verticalAccuracy)
    return row
  }
  
}

// MARK: Preparation

extension Location: Preparation {
  
  static func prepare(_ database: FluentProvider.Database) throws {
    
    try database.create(self) {
      builder in
      builder.id()
      builder.double(Keys.latitude)
      builder.double(Keys.longitude)
      builder.double(Keys.altitude)
      builder.double(Keys.horizontalAccuracy)
      builder.double(Keys.verticalAccuracy)
    }
    
  }
  
  static func revert(_ database: FluentProvider.Database) throws {
    try database.delete(self)
  }
  
}

// MARK: JSON

extension Location: JSONConvertible {
  
  convenience init(json: JSON) throws {
    self.init(latitude: try json.get(Keys.latitude),
              longitude: try json.get(Keys.longitude),
              altitude: try json.get(Keys.altitude),
              horizontalAccuracy: try json.get(Keys.horizontalAccuracy),
              verticalAccuracy: try json.get(Keys.verticalAccuracy))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Keys.id, id)
    try json.set(Keys.latitude, latitude)
    try json.set(Keys.longitude, longitude)
    try json.set(Keys.altitude, altitude)
    try json.set(Keys.horizontalAccuracy, horizontalAccuracy)
    try json.set(Keys.verticalAccuracy, verticalAccuracy)
    return json
  }
  
}

// MARK: HTTP

extension Location: ResponseRepresentable { }

// MARK: TIMESTAMP

extension Location: Timestampable { }

// MARK: DELETE

extension Location: SoftDeletable { }

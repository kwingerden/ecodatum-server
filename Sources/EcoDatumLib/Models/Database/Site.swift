import FluentProvider
import Foundation
import Vapor

final class Site: EquatableModel {
  
  let storage = Storage()
  
  var name: String
  
  var description: String?
  
  var latitude: Double
  
  var longitude: Double
  
  var altitude: Double?
  
  var horizontalAccuracy: Double?
  
  var verticalAccuracy: Double?
  
  var organizationId: Identifier?

  var userId: Identifier?
  
  struct Keys {
    static let id = "id"
    static let name = "name"
    static let description = "description"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let altitude = "altitude"
    static let horizontalAccuracy = "horizontal_accuracy"
    static let verticalAccuracy = "vertical_accuracy"
    static let organizationId = Organization.foreignIdKey
    static let userId = User.foreignIdKey
  }
  
  init(name: String,
       description: String? = nil,
       latitude: Double,
       longitude: Double,
       altitude: Double? = nil,
       horizontalAccuracy: Double? = nil,
       verticalAccuracy: Double? = nil,
       organizationId: Identifier? = nil,
       userId: Identifier? = nil) {
    self.name = name
    self.description = description
    self.latitude = latitude
    self.longitude = longitude
    self.altitude = altitude
    self.horizontalAccuracy = horizontalAccuracy
    self.verticalAccuracy = verticalAccuracy
    self.organizationId = organizationId
    self.userId = userId
  }
  
  // MARK: Row
  
  init(row: Row) throws {
    name = try row.get(Keys.name)
    description = try row.get(Keys.description)
    latitude = try row.get(Keys.latitude)
    longitude = try row.get(Keys.longitude)
    altitude = try row.get(Keys.altitude)
    horizontalAccuracy = try row.get(Keys.horizontalAccuracy)
    verticalAccuracy = try row.get(Keys.verticalAccuracy)
    organizationId = try row.get(Keys.organizationId)
    userId = try row.get(Keys.userId)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name)
    try row.set(Keys.description, description)
    try row.set(Keys.latitude, latitude)
    try row.set(Keys.longitude, longitude)
    try row.set(Keys.altitude, altitude)
    try row.set(Keys.horizontalAccuracy, horizontalAccuracy)
    try row.set(Keys.verticalAccuracy, verticalAccuracy)
    try row.set(Keys.organizationId, organizationId)
    try row.set(Keys.userId, userId)
    return row
  }

}

// MARK: Preparation

extension Site: Preparation {
  
  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        length: 250,
        optional: false,
        unique: false)
      builder.string(
        Keys.description,
        length: 500,
        optional: true,
        unique: false)
      builder.double(
        Keys.latitude,
        optional: false,
        unique: false)
      builder.double(
        Keys.longitude,
        optional: false,
        unique: false)
      builder.double(
        Keys.altitude,
        optional: true,
        unique: false)
      builder.double(
        Keys.horizontalAccuracy,
        optional: true,
        unique: false)
      builder.double(
        Keys.verticalAccuracy,
        optional: true,
        unique: false)
      builder.foreignId(
        for: Organization.self,
        optional: false,
        unique: false)
      builder.foreignId(
        for: User.self,
        optional: false,
        unique: false)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
  
}

// MARK: Relations

extension Site {
  
  var user: Parent<Site, User> {
    return parent(id: userId)
  }

  var organization: Parent<Site, Organization> {
    return parent(id: organizationId)
  }

  var qualitativeObservationFactors: Children<Site, QualitativeObservationFactor> {
    return children()
  }

  var quantitativeObservationFactors: Children<Site, QuantitativeObservationFactor> {
    return children()
  }

  var ecoData: Children<Site, EcoDatum> {
    return children()
  }

}

// MARK: Timestampable

extension Site: Timestampable { }



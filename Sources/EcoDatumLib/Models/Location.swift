import FluentProvider
import Foundation
import Vapor

/*
 Reference:
 https://www.percona.com/blog/2013/10/21/using-the-new-mysql-spatial-functions-5-6-for-geo-enabled-applications/
 
 USE ecodatum;
 
 SET @lat= 37.615223;
 SET @lon = -122.389979;
 SET @dist = 10;
 --  degree of latitude ~= 69 miles
 -- 1 degree of longitude ~= cos(latitude)*69 miles
 SET @rlon1 = @lon-@dist/abs(cos(radians(@lat))*69);
 SET @rlon2 = @lon+@dist/abs(cos(radians(@lat))*69);
 SET @rlat1 = @lat-(@dist/69);
 SET @rlat2 = @lat+(@dist/69);
 
 DROP TABLE points;
 CREATE TABLE points (
 id INT PRIMARY KEY AUTO_INCREMENT,
 point POINT NOT NULL);
 CREATE SPATIAL INDEX `idx_points_point_spatial`  ON `ecodatum`.`points` (point);
 INSERT INTO points (point) VALUES (ST_GeomFromText('POINT(1 1)'));
 INSERT INTO points (point) VALUES (POINT(-122.3890954, -100));
 INSERT INTO points (point) VALUES (POINT(@lon, @lat));
 
 SELECT ST_AsText(ST_Envelope(LineString(Point(@rlon1, @rlat1), Point(@rlon2, @rlat2))));
 
 SELECT
 ST_X(point) as latitude,
 ST_Y(point) as longitude
 FROM points
 WHERE
 ST_Within(point, ST_Envelope(LineString(Point(@rlon1, @rlat1), Point(@rlon2, @rlat2))));
 
*/
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
  
  static func prepare(_ database: Database) throws {
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
  
  static func revert(_ database: Database) throws {
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


  /*
  private struct SQL {
    static let CREATE_TABLE = """
      CREATE TABLE points (
        id INT PRIMARY KEY AUTO_INCREMENT,
        point POINT NOT NULL)
      """
    static let CREATE_POINT_INDEX = """
      CREATE SPATIAL INDEX
        idx_points_point_spatial ON
          ecodatum.points (point)
      """
    static func INSERT_POINT(_ latitude: Double, _ longitude: Double) -> String {
      return """
      INSERT INTO points (point)
      VALUES (POINT(\(latitude), \(longitude)))
      """
    }
    static let DROP_TABLE = "DROP TABLE points"
    static let LAST_INSERT_ID = "SELECT LAST_INSERT_ID() as id"
    static func SELECT_POINT_BY_ID(_ id: Int) -> String {
      return """
      SELECT
        id,
        ST_X(point) as latitude,
        ST_Y(point) as longitude
      FROM points
      WHERE id = \(id)
      """
    }
  }
  
  let id: Int
  
  let latitude: Double
  
  let longitude: Double
  
  static func createTable(_ connection: Connection) throws {
    try connection.raw(SQL.CREATE_TABLE)
  }
  
  static func createIndices(_ connection: Connection) throws {
    try connection.raw(SQL.CREATE_POINT_INDEX)
  }
  
  static func dropTable(_ connection: Connection) throws {
    try connection.raw(SQL.DROP_TABLE)
  }
  
  static func insertPoint(_ connection: Connection,
                          latitude: Double,
                          longitude: Double) throws -> Point {
    try connection.raw(SQL.INSERT_POINT(latitude, longitude))
    let result = try connection.raw(SQL.LAST_INSERT_ID)
    return Point(id: 1, latitude: latitude, longitude: longitude)
  }
  
  static func selectPoint(_ connection: Connection, byId: Int) throws -> Point {
    let result = try connection.raw(SQL.SELECT_POINT_BY_ID(byId))
    return Point(id: 1, latitude: 1.0, longitude: 1.0)
  }
  */


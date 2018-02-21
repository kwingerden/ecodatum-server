import Foundation
import FluentProvider
import HTTP
import Vapor

final class MeasurementUnit: EquatableModel {

  enum Unit: String {
    case pH
    case parts_per_million = "ppm"
    case seconds = "s"
    case lx
    case celsius = "°C"
  }

  enum Dimension: String {
    case Acidity
    case Dispersion
    case Duration
    case Illuminance
    case Temperature
    static let all: [
    (
      dimension: Dimension,
      unit: Unit,
      description: String
    )] = [
      (
        dimension: .Acidity,
        unit: .pH,
        description: """
        pH (potential of hydrogen) is a scale of acidity from 0 to 14. It 
        tells how acidic or alkaline a substance is. More acidic solutions 
        have lower pH. More alkaline solutions have higher pH.
        """
      ),
      (
        dimension: .Dispersion,
        unit: .parts_per_million,
        description: """
        Usually describes the concentration of something in water or soil. 
        One ppm is equivalent to 1 milligram of something per liter of water 
        (mg/l) or 1 milligram of something per kilogram soil (mg/kg).
        """
      ),
      (
        dimension: .Duration,
        unit: .seconds,
        description: """
        A unit of time or time unit is any particular time interval, used as 
        a standard way of measuring or expressing duration. 
        """
      ),
      (
        dimension: .Illuminance,
        unit: .lx,
        description: """
        In photometry, illuminance is the total luminous flux incident on a 
        surface, per unit area. It is a measure of how much the incident light 
        illuminates the surface, wavelength-weighted by the luminosity function
        to correlate with human brightness perception.
        """
      ),
      (
        dimension: .Temperature,
        unit: .celsius,
        description: """
        Temperature is a proportional measure of the average translational 
        kinetic energy of the random motions of the constituent microscopic 
        particles in a system (such as electrons, atoms, and molecules).
        """
      )
    ]
  }

  let storage = Storage()

  let dimension: Dimension

  let unit: Unit

  let description: String

  struct Keys {
    static let id = "id"
    static let dimension = "dimension"
    static let unit = "unit"
    static let description = "description"
  }

  init(dimension: Dimension,
       unit: Unit,
       description: String) {
    self.dimension = dimension
    self.unit = unit
    self.description = description
  }

  // MARK: Row

  init(row: Row) throws {
    guard let dimension = Dimension(rawValue: try row.get(Keys.dimension)) else {
      throw Abort(.internalServerError)
    }
    self.dimension = dimension
    guard let unit = Unit(rawValue: try row.get(Keys.unit)) else {
      throw Abort(.internalServerError)
    }
    self.unit = unit
    description = try row.get(Keys.description)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.dimension, dimension.rawValue)
    try row.set(Keys.unit, unit.rawValue)
    try row.set(Keys.description, description)
    return row
  }
}

// MARK: Preparation

extension MeasurementUnit: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.dimension,
        length: 20,
        optional: false,
        unique: false)
      builder.string(
        Keys.unit,
        length: 20,
        optional: false,
        unique: false)
      builder.string(
        Keys.description,
        length: 500,
        optional: false,
        unique: false)
    }
    try database.index(
      [
        Keys.dimension,
        Keys.unit
      ],
      for: self)
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}




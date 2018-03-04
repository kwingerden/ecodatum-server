import Foundation
import FluentProvider
import HTTP
import Vapor

final class MeasurementUnit: EquatableModel {

  enum Unit: String {
    case degree_centigrade = "°C"
    case degree_fahrenheit = "°F"
    case kelvin = "K"
    case parts_per_million = "ppm"
    case potential_of_hydrogen = "pH"
    case second = "s"
    case minute = "min"
    case hour = "h"
    case day = "d"
    case lux = "lx"
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
      label: String,
      description: String
    )] = [
      
      // ACIDITY
      
      (
        dimension: .Acidity,
        unit: .potential_of_hydrogen,
        label: "Potential of Hydrogen",
        description: """
        pH is a measure of the acidity or alkalinity of a solution. The pH value
        states the relative quantity of hydrogen ions (H+) contained in a solution.
        The greater the concentration of H+ the more acidic the solution and the
        lower the pH.
        """
      ),
      
      // DISPERSION
      
      (
        dimension: .Dispersion,
        unit: .parts_per_million,
        label: "Parts Per Million",
        description: """
        A way of expressing very dilute concentrations of substances. One ppm is
        equivalent to 1 milligram of something per liter of water (mg/l) or 1
        milligram of something per kilogram soil (mg/kg).
        """
      ),
      
      // DURATION
      
      (
        dimension: .Duration,
        unit: .second,
        label: "Second",
        description: """
        The second is the duration of 9,192,631,770 periods of the radiation
        corresponding to the transition between the two hyperfine levels of the
        ground state of the cesium 133 atom.
        """
      ),
      (
        dimension: .Duration,
        unit: .minute,
        label: "Minute",
        description: """
        A period of time equal to 60 seconds or a 60th of an hour.
        """
      ),
      (
        dimension: .Duration,
        unit: .hour,
        label: "Hour",
        description: """
        A period of time equal to 3600 seconds or a 24th part of a day and night.
        """
      ),
      (
        dimension: .Duration,
        unit: .day,
        label: "Day",
        description: """
        A period of 24 hours as a unit of time, reckoned from one midnight to the
        next, corresponding to a rotation of the earth on its axis.
        """
      ),
      
      // ILLUMINANCE
      
      (
        dimension: .Illuminance,
        unit: .lux,
        label: "lux",
        description: """
        A unit of illuminance, equal to one lumen per square meter.
        """
      ),
      
      // TEMPERATURE
      
      (
        dimension: .Temperature,
        unit: .degree_centigrade,
        label: "Degree Centigrade",
        description: """
        A scale of temperature in which water freezes at 0° and boils at 100°
        under standard conditions.
        """
      ),
      (
        dimension: .Temperature,
        unit: .degree_fahrenheit,
        label: "Degree Fahrenheit",
        description: """
        A scale of temperature on which water freezes at 32° and boils at 212°
        under standard conditions.
        """
      ),
      (
        dimension: .Temperature,
        unit: .kelvin,
        label: "Kelvin",
        description: """
        A base unit of thermodynamic temperature, equal in magnitude to the
        degree Celsius.
        """
      )
      
    ]
  }

  let storage = Storage()

  let dimension: Dimension

  let unit: Unit

  let label: String

  let description: String

  struct Keys {
    static let id = "id"
    static let dimension = "dimension"
    static let unit = "unit"
    static let label = "label"
    static let description = "description"
  }

  init(dimension: Dimension,
       unit: Unit,
       label: String,
       description: String) {
    self.dimension = dimension
    self.unit = unit
    self.label = label
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
    label = try row.get(Keys.label)
    description = try row.get(Keys.description)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.dimension, dimension.rawValue)
    try row.set(Keys.unit, unit.rawValue)
    try row.set(Keys.label, label)
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
        Keys.label,
        length: 50,
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




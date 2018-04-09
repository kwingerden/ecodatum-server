import FluentProvider
import Foundation
import Vapor

final class MeasurementUnit: EquatableModel {

  enum Name: String {

    case blackish_or_brownish

    case celsius
    case crystal_clear

    case devastating

    case eight
    case eleven

    case fahrenheit
    case five
    case four
    case fourteen

    case high

    case jackson_turbidity_units

    case low

    case medium
    case megawatts_per_meter_squared
    case meters_per_second
    case micromoles_per_meter_squared_per_second
    case microsiemens_per_centimeter
    case miles_per_hour
    case milligrams_per_liter
    case moderately_cloudy

    case one

    case nephelometric_turbidity_units
    case no_odor

    case one_lumen_per_square_meter

    case parts_per_million
    case percent
    case percent_clay
    case percent_sand
    case percent_silt
    case pH
    case pounds_per_acre

    case nine

    case seven
    case six
    case slight_odor
    case slightly_cloudy
    case smelly

    case ten
    case thirteen
    case three
    case twelve
    case two

    case very_cloudy
    case very_smelly

    static let all: [Name] = [

      .blackish_or_brownish,

      .celsius,

      .crystal_clear,

      .devastating,

      .eight,
      .eleven,

      .fahrenheit,
      .five,
      .four,
      .fourteen,

      .high,

      .jackson_turbidity_units,

      .low,

      .medium,
      .megawatts_per_meter_squared,
      .meters_per_second,
      .micromoles_per_meter_squared_per_second,
      .microsiemens_per_centimeter,
      .miles_per_hour,
      .milligrams_per_liter,
      .moderately_cloudy,

      .one,

      .nephelometric_turbidity_units,
      .no_odor,

      .one_lumen_per_square_meter,

      .parts_per_million,
      .percent,
      .percent_clay,
      .percent_sand,
      .percent_silt,
      .pH,
      .pounds_per_acre,

      .nine,

      .seven,
      .six,
      .slight_odor,
      .slightly_cloudy,
      .smelly,

      .ten,
      .thirteen,
      .three,
      .twelve,
      .two,

      .very_cloudy,
      .very_smelly

    ]

  }

  let storage = Storage()

  let name: Name

  struct Keys {
    static let id = "id"
    static let name = "name"
  }

  init(name: Name) {
    self.name = name
  }

  // MARK: Row

  init(row: Row) throws {
    guard let name = Name(rawValue: try row.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.name = name
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name.rawValue)
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
        Keys.name,
        optional: false,
        unique: true)
    }
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}





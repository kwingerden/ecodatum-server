import FluentProvider
import Vapor

final class SecondaryAbioticFactor: EquatableModel {

  enum Name: String {
    case CARBON_DIOXIDE
    case HYDROGEN_ION
    case LUMINOUS_INTENSITY
    case TEMPERATURE
    static let all: [
    (
      name: Name,
      label: String,
      description: String
    )] = [
      (
        name: .CARBON_DIOXIDE,
        label: "Carbon Dioxide (CO2)",
        description: """
        A colorless, odorless gas produced by burning carbon and organic 
        compounds and by respiration. It is naturally present in air 
        (about 0.03 percent) and is absorbed by plants in photosynthesis.
        """
      ),
      (
        name: .HYDROGEN_ION,
        label: "Hydrogen Ion (H+)",
        description: """
        A hydrogen ion is created when a hydrogen atom loses or gains an 
        electron and becomes a negatively or positively charged, respectively.
        """
      ),
      (
        name: .LUMINOUS_INTENSITY,
        label: "Luminous Intensity",
        description: """
        Luminous intensity is a measure of the wavelength-weighted power 
        emitted by a light source in a particular direction per unit solid 
        angle, based on the luminosity function, a standardized model of 
        the sensitivity of the human eye. 
        """
      ),
      (
        name: .TEMPERATURE,
        label: "Temperature",
        description: """
        Temperature is a proportional measure of the average translational 
        kinetic energy of the random motions of the constituent microscopic 
        particles in a system (such as electrons, atoms, and molecules).
        """
      )
    ]
  }

  let storage = Storage()

  let name: Name

  let label: String

  let description: String

  struct Keys {
    static let id = "id"
    static let name = "name"
    static let label = "label"
    static let description = "description"
  }

  init(name: Name,
       label: String,
       description: String) {
    self.name = name
    self.label = label
    self.description = description
  }

  // MARK: Row

  init(row: Row) throws {
    guard let name = Name(rawValue: try row.get(Keys.name)) else {
      throw Abort(.internalServerError)
    }
    self.name = name
    label = try row.get(Keys.label)
    description = try row.get(Keys.description)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Keys.name, name.rawValue)
    try row.set(Keys.label, label)
    try row.set(Keys.description, description)
    return row
  }
}

// MARK: Preparation

extension SecondaryAbioticFactor: Preparation {

  static func prepare(_ database: Database) throws {
    try database.create(self) {
      builder in
      builder.id()
      builder.string(
        Keys.name,
        optional: false,
        unique: true)
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
  }

  static func revert(_ database: Database) throws {
    try database.delete(self)
  }

}





import HTTP
import Fluent
import Vapor

final class APIV1PublicMeasurementUnitsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /measurementUnits
    routeBuilder.get(handler: getAllMeasurementUnits)
    
  }
  
  private func getAllMeasurementUnits(_ request: Request) throws -> ResponseRepresentable {

    var fullMeasurementUnits: [FullMeasurementUnit] = []
    try AbioticFactorMeasurementUnit.makeQuery().all().forEach {

      guard let primaryAbioticFactor = try $0.primaryAbioticFactor.get(),
            let secondaryAbioticFactor = try $0.secondaryAbioticFactor.get(),
            let measurementUnit = try $0.measurementUnit.get() else {
        throw Abort(.internalServerError)
      }

      fullMeasurementUnits.append(
        FullMeasurementUnit(
          primaryAbioticFactor: primaryAbioticFactor,
          secondaryAbioticFactor: secondaryAbioticFactor,
          measurementUnit: measurementUnit))

    }

    return try fullMeasurementUnits.makeJSON()

  }

  private struct FullMeasurementUnit: JSONRepresentable {

    let primaryAbioticFactor: PrimaryAbioticFactor
    let secondaryAbioticFactor: SecondaryAbioticFactor
    let measurementUnit: MeasurementUnit

    func makeJSON() throws -> JSON {

      let j1 =  try primaryAbioticFactor.makeJSON()
      let j2 =  try secondaryAbioticFactor.makeJSON()
      let j3 =  try measurementUnit.makeJSON()

      return try JSON(node: [
        "primaryAbioticFactor": j1,
        "secondaryAbioticFactor": j2,
        "measurementUnit": j3
      ])

    }

  }
  
}


import HTTP
import Fluent
import Vapor

final class APIV1PublicAbioticFactorsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /abioticFactors
    routeBuilder.get(handler: getAllAbioticFactors)
    
    // GET /abioticFactors/:id
    routeBuilder.get(
      Int.parameter,
      handler: getAbioticFactorById)
    
    // GET /abioticFactors/:id/measurementUnits
    routeBuilder.get(
      Int.parameter,
      "measurementUnits",
      handler: getMeasurementUnitsByAbioticFactorId)
    
  }
  
  private func getAllAbioticFactors(_ request: Request) throws -> ResponseRepresentable {
    return try AbioticFactor.makeQuery().all().makeJSON()
  }
  
  private func getAbioticFactorById(_ request: Request) throws -> ResponseRepresentable {
    
    guard let id = try? request.parameters.next(Int.self) else {
      throw Abort(.badRequest)
    }
    
    guard let abioticFactor = try AbioticFactor.makeQuery().find(id) else {
      throw Abort(.notFound)
    }
    
    return try abioticFactor.makeJSON()
    
  }
  
  private func getMeasurementUnitsByAbioticFactorId(_ request: Request) throws -> ResponseRepresentable {
    
    guard let id = try? request.parameters.next(Int.self) else {
      throw Abort(.badRequest)
    }
    
    guard let abioticFactor = try AbioticFactor.makeQuery().find(id) else {
      throw Abort(.notFound)
    }
    
    let measurementUnits = try MeasurementUnit.makeQuery().all()
    
    switch abioticFactor.name {
      
    case .AIR:
      return try measurementUnits.filter {
        measurementUnit in
        switch measurementUnit.name {
        case .ACIDITY_PH: return false
        case .CARBON_DIOXIDE_PPM: return true
        case .LIGHT_INTENSITY_LUX: return true
        case .TEMPERATURE_CELCIUS: return true
        }
        }.makeJSON()
      
    case .SOIL:
      return try measurementUnits.filter {
        measurementUnit in
        switch measurementUnit.name {
        case .ACIDITY_PH: return false
        case .CARBON_DIOXIDE_PPM: return false
        case .LIGHT_INTENSITY_LUX: return false
        case .TEMPERATURE_CELCIUS: return true
        }
        }.makeJSON()
      
    case .WATER:
      return try measurementUnits.filter {
        measurementUnit in
        switch measurementUnit.name {
        case .ACIDITY_PH: return true
        case .CARBON_DIOXIDE_PPM: return false
        case .LIGHT_INTENSITY_LUX: return true
        case .TEMPERATURE_CELCIUS: return true
        }
        }.makeJSON()
      
    }
    
  }
  
}



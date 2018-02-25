import HTTP
import Vapor

final class APIV1TokenMeasurementsRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /measurements/:id
    routeBuilder.get(
      Measurement.parameter,
      handler: getMeasurementById)
    
    // POST /measurements
    routeBuilder.post(
      handler: createNewMeasurement)
    
  }
  
  private func getMeasurementById(_ request: Request) throws -> ResponseRepresentable {

    let (measurement, isRootUser, doesUserBelongToOrganization) =
      try isRootOrMeasurementUser(request)

    if isRootUser || doesUserBelongToOrganization {

      return measurement

    } else {

      throw Abort(.notFound)

    }
    
  }
  
  private func createNewMeasurement(_ request: Request) throws -> ResponseRepresentable {
      
    let json = try request.assertJson()
    
    guard let surveyId: Identifier = try json.get(Measurement.Json.surveyId),
      let survey = try modelManager.findSurvey(byId: Identifier(surveyId)) else {
        throw Abort(.notFound, reason: "Survey not found")
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request, survey)
    
    if isRootUser || doesUserBelongToOrganization {
      
      guard let primaryAbioticFactorId: Identifier = try json.get(Measurement.Json.primaryAbioticFactorId),
            let secondaryAbioticFactorId: Identifier = try json.get(Measurement.Json.secondaryAbioticFactorId),
            let measurementUnitId: Identifier = try json.get(Measurement.Json.measurementUnitId),
            let abioticFactorMeasurementUnit = try modelManager.findAbioticFactorMeasurementUnit(
              primaryAbioticFactorId: primaryAbioticFactorId,
              secondaryAbioticFactorId: secondaryAbioticFactorId,
              measurementUnitId: measurementUnitId) else {
          throw Abort(.notFound, reason: "Abiotic Factors and/or measurement unit not found")
      }
      
      guard let value: Double = try json.get(Measurement.Json.value) else {
          throw Abort(.notFound, reason: "Measurement Value not found")
      }
      
      return try modelManager.createMeasurement(
        value: value,
        abioticFactorMeasurementUnit: abioticFactorMeasurementUnit,
        surveyId: surveyId,
        userId: try request.user().assertExists())
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }

  private func isRootOrSurveyUser(_ request: Request,
                                  _ survey: Survey) throws -> (Bool, Bool) {
    
    guard let organization = try survey.site.get()?.organization.get() else {
      throw Abort(.internalServerError, reason: "No survey site organization")
    }
    
    let user = try request.user()
    let isRootUser = try modelManager.isRootUser(user)
    let doesUserBelongToOrganization = try modelManager.doesUserBelongToOrganization(
      user: user,
      organization: organization)
    
    return (isRootUser, doesUserBelongToOrganization)
      
  }
  
  private func isRootOrMeasurementUser(_ request: Request) throws -> (Measurement, Bool, Bool) {

    let measurement = try request.parameters.next(Measurement.self)
    guard let survey = try measurement.survey.get() else {
      throw Abort(.internalServerError)
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request, survey)

    return (measurement, isRootUser, doesUserBelongToOrganization)

  }
  
}


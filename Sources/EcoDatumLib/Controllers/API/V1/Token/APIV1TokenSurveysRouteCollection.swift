import Crypto
import Vapor

final class APIV1TokenSurveysRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /surveys
    routeBuilder.get(
      handler: getSurveysByUser)
    
    // GET /surveys/:id
    routeBuilder.get(
      Survey.parameter,
      handler: getSurveyById)
    
    // GET /surveys/:id/measurements
    routeBuilder.get(
      Survey.parameter,
      "measurements",
      handler: getMeasurementsBySurvey)
    
    // POST /surveys
    routeBuilder.post(
      handler: createNewSurvey)
    
  }
  
  private func getSurveysByUser(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      
      return try modelManager.getAllSurveys().makeJSON()
      
    } else {
      
      return try modelManager.findSurveys(
        byUser: request.user()).makeJSON()
      
    }
    
  }
  
  private func getSurveyById(_ request: Request) throws -> ResponseRepresentable {
    
    let survey = try request.parameters.next(Survey.self)
    
    if try modelManager.isRootUser(request.user()) {
      
      return survey
    
    } else if let organization = try survey.site.get()?.organization.get(),
      try modelManager.doesUserBelongToOrganization(
        user: request.user(),
        organization: organization) {
      
      return survey
    
    } else {
    
      throw Abort(.notFound)
    
    }
    
  }
  
  private func getMeasurementsBySurvey(_ request: Request) throws -> ResponseRepresentable {
    
    let survey = try request.parameters.next(Survey.self)
    
    if try modelManager.isRootUser(request.user()) {
      
      return try survey.measurements.all().makeJSON()
      
    } else if let organization = try survey.site.get()?.organization.get(),
      try modelManager.doesUserBelongToOrganization(
        user: request.user(),
        organization: organization) {
      
      return try survey.measurements.all().makeJSON()
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func createNewSurvey(_ request: Request) throws -> ResponseRepresentable {
    
    let json = try request.assertJson()
    
    guard let siteId: Identifier = try json.get(Survey.Json.siteId),
      let site = try modelManager.findSite(byId: Identifier(siteId)) else {
        throw Abort(.notFound, reason: "Site not found")
    }
    
    return try modelManager.createSurvey(
      date: Date(),
      site: site,
      user: try request.user())
    
  }
  
}




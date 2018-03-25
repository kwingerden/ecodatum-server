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
      handler: getSurvey)
    
    // GET /surveys/:id/measurements
    routeBuilder.get(
      Survey.parameter,
      "measurements",
      handler: getMeasurementsBySurvey)
    
    // POST /surveys
    routeBuilder.post(
      handler: newSurvey)

    // PUT /surveys/:id
    routeBuilder.put(
      Survey.parameter,
      handler: updateSurvey)

    // DELETE /surveys/:id
    routeBuilder.delete(
      Survey.parameter,
      handler: deleteSurvey)

  }
  
  private func getSurveysByUser(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {
      
      return try modelManager.getAllSurveys().makeJSON()
      
    } else {
      
      return try modelManager.findSurveys(
        byUser: request.user()).makeJSON()
      
    }
    
  }
  
  private func getSurvey(_ request: Request) throws -> ResponseRepresentable {

    let (survey, isRootUser, isSurveyUser) = try isRootOrSurveyUser(request)
    
    if isRootUser || isSurveyUser {
      
      return survey

    } else {
    
      throw Abort(.notFound)
    
    }
    
  }
  
  private func getMeasurementsBySurvey(_ request: Request) throws -> ResponseRepresentable {

    let (survey, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request)
    
    if isRootUser || doesUserBelongToOrganization {
      
      return try survey.measurements.all().makeJSON()
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func newSurvey(_ request: Request) throws -> ResponseRepresentable {
    
    let json = try request.assertJson()
    
    guard let siteId: Identifier = try json.get(Survey.Json.siteId),
      let site = try modelManager.findSite(byId: Identifier(siteId)) else {
        throw Abort(.notFound, reason: "Site not found")
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrSiteUser(request, site)

    let (date, description) = try toSurveyAttributes(json)

    if isRootUser || doesUserBelongToOrganization {
      
      return try modelManager.createSurvey(
        date: date,
        description: description,
        site: site,
        user: try request.user())
    
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }

  private func updateSurvey(_ request: Request) throws -> ResponseRepresentable {

    let (survey, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request)

    if isRootUser || doesUserBelongToOrganization {

      let json = try request.assertJson()

      let (date, description) = try toSurveyAttributes(json)

      survey.date = date
      survey.description = description

      return try modelManager.updateSurvey(survey: survey)

    } else {

      throw Abort(.notFound)

    }

  }

  private func deleteSurvey(_ request: Request) throws -> ResponseRepresentable {

    let (survey, isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request)

    if isRootUser || doesUserBelongToOrganization {

      try modelManager.transaction {
        connection in
        try self.modelManager.deleteSurvey(connection, survey: survey)
      }

      return Response(status: .ok)

    } else {

      throw Abort(.notFound)

    }

  }

  private func toSurveyAttributes(_ json: JSON) throws -> (date: Date, description: String?) {

    guard let date: Date = try json.get(Survey.Json.date) else {
      throw Abort(.badRequest, reason: "Survey must have a date.")
    }

    var description: String? = nil
    if let _description: String = try json.get(Survey.Json.description),
       !_description.isEmpty {
      description = _description
    }

    return (date: date, description: description)

  }

  private func isRootOrSiteUser(_ request: Request,
                                _ site: Site) throws -> (Bool, Bool) {
    
    guard let organization = try site.organization.get() else {
      throw Abort(.internalServerError, reason: "No site organization")
    }
      
    let user = try request.user()
    let isRootUser = try modelManager.isRootUser(user)
    let doesUserBelongToOrganization = try modelManager.doesUserBelongToOrganization(
      user: user,
      organization: organization)
    
    return (isRootUser, doesUserBelongToOrganization)
    
  }
  
  private func isRootOrSurveyUser(_ request: Request) throws -> (Survey, Bool, Bool) {

    let survey = try request.parameters.next(Survey.self)
    guard let site = try survey.site.get() else {
      throw Abort(.internalServerError)
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrSiteUser(request, site)
    
    return (survey, isRootUser, doesUserBelongToOrganization)

  }
  
}




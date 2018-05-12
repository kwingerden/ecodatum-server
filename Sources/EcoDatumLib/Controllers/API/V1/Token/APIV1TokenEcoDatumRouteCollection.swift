import Vapor

final class APIV1TokenEcoDatumRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /ecodatum
    routeBuilder.get(
      handler: getEcoDatumByUser)
    
    // GET /ecodatum/:id
    routeBuilder.get(
      Site.parameter,
      handler: getEcoDatum)
    
    // POST /ecodatum
    routeBuilder.post(
      handler: newEcoDatum)
    
    // PUT /ecodatum/:id
    routeBuilder.put(
      Site.parameter,
      handler: updateEcoDatum)
    
    // DELETE /ecodatum/:id
    routeBuilder.delete(
      Site.parameter,
      handler: deleteEcoDatum)
    
  }
  
  private func getEcoDatumByUser(_ request: Request) throws -> ResponseRepresentable {
    
    if try modelManager.isRootUser(request.user()) {

      return try modelManager.getAllEcoDatum()
        .makeJSON()

    } else {

      return try modelManager.findEcoDatum(
        byUser: request.user())
        .makeJSON()

    }
    
  }
  
  private func getEcoDatum(_ request: Request) throws -> ResponseRepresentable {

    let (ecoDatum, isRootUser, doesUserBelongToOrganization) =
      try isRootOrEcoDatumUser(request)

    if isRootUser || doesUserBelongToOrganization {

      return ecoDatum

    } else {

      throw Abort(.notFound)

    }
    
  }
  
  private func newEcoDatum(_ request: Request) throws -> ResponseRepresentable {
    
    let json = try request.assertJson()
    
    guard let siteId: Identifier = try json.get(EcoDatum.Json.siteId),
          let site = try modelManager.findSite(byId: siteId),
          let organization = try site.organization.get() else {
        throw Abort(.badRequest, reason: "EcoDatum must have associated organization and site.")
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrOrganizationUser(request, organization)
    
    guard isRootUser || doesUserBelongToOrganization else {
      throw Abort(.notFound)
    }

    guard let _json: String = try json.get(EcoDatum.Json.json) else {
      throw Abort(.badRequest, reason: "EcoDatum must have JSON.")
    }

    return try modelManager.createEcoDatum(
      json: _json,
      site: site,
      user: try request.user())

  }

  private func updateEcoDatum(_ request: Request) throws -> ResponseRepresentable {
    
    let (ecoDatum, isRootUser, doesUserBelongToOrganization) =
      try isRootOrEcoDatumUser(request)
    
    if isRootUser || doesUserBelongToOrganization {
      
      let json = try request.assertJson()

      guard let _json: String = try json.get(EcoDatum.Json.json) else {
        throw Abort(.badRequest, reason: "Site must have a latitude.")
      }

      ecoDatum.json = _json
      
      return try modelManager.updateEcoDatum(ecoDatum: ecoDatum)
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func deleteEcoDatum(_ request: Request) throws -> ResponseRepresentable {
    
    let (ecoDatum, isRootUser, doesUserBelongToOrganization) =
      try isRootOrEcoDatumUser(request)
    
    if isRootUser || doesUserBelongToOrganization {
      
      try modelManager.transaction {
        connection in
        try self.modelManager.deleteEcoDatum(connection, ecoDatum: ecoDatum)
      }
      
      return Response(status: .ok)
      
    } else {
      
      throw Abort(.notFound)
      
    }
    
  }
  
  private func isRootOrOrganizationUser(
    _ request: Request,
    _ organization: Organization)
    throws -> (Bool, Bool) {
    
    let user = try request.user()
    let isRootUser = try modelManager.isRootUser(user)
    let doesUserBelongToOrganization = try modelManager.doesUserBelongToOrganization(
      user: user,
      organization: organization)
    
    return (isRootUser, doesUserBelongToOrganization)
    
  }
  
  private func isRootOrEcoDatumUser(_ request: Request) throws -> (EcoDatum, Bool, Bool) {

    let ecoDatum = try request.parameters.next(EcoDatum.self)
    guard let organization = try ecoDatum.site.get()?.organization.get() else {
      throw Abort(.internalServerError)
    }
    
    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrOrganizationUser(request, organization)

    return (ecoDatum, isRootUser, doesUserBelongToOrganization)

  }
  
}

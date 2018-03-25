import Bits
import Foundation
import HTTP
import Vapor

final class APIV1TokenImagesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    // GET /images
    routeBuilder.get(
      handler: getImagesByUser)
    
    // GET /images/:id
    routeBuilder.get(
      Image.parameter,
      handler: getImageById)
    
    // POST /images
    routeBuilder.post(
      handler: newImage)
    
  }
  
  private func getImagesByUser(_ request: Request) throws -> ResponseRepresentable {

    if try modelManager.isRootUser(request.user()) {

      return try modelManager.getAllImages()
        .makeJSON()

    } else {

      return try modelManager.findImages(
          byUser: request.user())
        .makeJSON()

    }

  }
  
  private func getImageById(_ request: Request) throws -> ResponseRepresentable {

    let (image, isRootUser, isImageUser) = try isRootOrImageUser(request)
    if isRootUser || isImageUser {
      return image
    } else {
      throw Abort(.notFound)
    }
    
  }

  private func newImage(_ request: Request) throws -> ResponseRepresentable {

    let json = try request.assertJson()

    guard let surveyId: Identifier = try json.get(Image.Json.surveyId),
          let survey = try modelManager.findSurvey(byId: Identifier(surveyId)) else {
      throw Abort(.notFound, reason: "Survey not found")
    }

    let (isRootUser, isSurveyUser) = try isRootOrSurveyUser(request, survey)
    if isRootUser || isSurveyUser {

      let (imageBytes, description) = try toImageAttributes(json)
      return try modelManager.createImage(
        bytes: imageBytes,
        description: description,
        imageType: try modelManager.getImageType(name: .JPEG),
        survey: survey,
        user: try request.user())

    } else {

      throw Abort(.notFound)

    }

  }

  private func toImageAttributes(_ json: JSON) throws ->
    (imageBytes: Bytes, description: String?) {

    let base64Encoded: String = try json.get(Image.Json.base64Encoded)
    let imageData = Data(base64Encoded: base64Encoded)
    guard let imageBytes = imageData?.makeBytes() else {
      throw Abort(.internalServerError)
    }

    var description: String? = nil
    if let _description: String = try json.get(Site.Json.description),
       !_description.isEmpty {
      description = _description
    }

    return (imageBytes: imageBytes, description: description)

  }

  private func isRootOrSurveyUser(_ request: Request,
                                  _ survey: Survey) throws -> (Bool, Bool) {

    guard let organization = try survey.site.get()?.organization.get() else {
      throw Abort(.internalServerError, reason: "No survey organization")
    }

    let user = try request.user()
    let isRootUser = try modelManager.isRootUser(user)
    let doesUserBelongToOrganization = try modelManager.doesUserBelongToOrganization(
      user: user,
      organization: organization)

    return (isRootUser, doesUserBelongToOrganization)

  }

  private func isRootOrImageUser(_ request: Request) throws -> (Image, Bool, Bool) {

    let image = try request.parameters.next(Image.self)
    guard let survey = try image.survey.get() else {
      throw Abort(.internalServerError)
    }

    let (isRootUser, doesUserBelongToOrganization) =
      try isRootOrSurveyUser(request, survey)

    return (image, isRootUser, doesUserBelongToOrganization)

  }


}

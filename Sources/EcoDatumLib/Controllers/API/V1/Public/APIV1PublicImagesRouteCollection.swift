import Bits
import Crypto
import Foundation
import HTTP
import Vapor

final class APIV1PublicImagesRouteCollection: RouteCollection {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {

    // GET /public/images/:id
    routeBuilder.get(
      Image.parameter,
      handler: getImageById)
    
  }

  private func getImageById(_ request: Request) throws -> ResponseRepresentable {

    let image = try request.parameters.next(Image.self)
    guard let imageType = try image.imageType.get(),
    let imageBytes = image.image?.bytes else {
      throw Abort(.internalServerError)
    }

    var contentType = ""
    switch imageType.name {
    case .GIF:
      contentType = "image/gif"
    case .JPEG:
      contentType = "image/jpeg"
    case .PNG:
      contentType = "image/png"
    }

    return Response(
      status: .ok,
      headers: [
        HeaderKey("Content-Type") : contentType
      ],
      body: .data(imageBytes))
  
  }
  
}





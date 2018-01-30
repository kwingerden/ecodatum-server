import Bits
import Crypto
import Foundation
import HTTP
import Vapor

final class APIV1PublicImagesRoutes {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  func build(_ routeBuilder: RouteBuilder) {
    
    routeBuilder.get(
      ":code",
      handler: getImageByCodeRouteHandler)
    
  }
  
  // GET /public/images/:code
  private func getImageByCodeRouteHandler(
    _ request: Request)
    throws -> ResponseRepresentable {
      
      guard let code = try? request.parameters.next(String.self),
        let image = try self.modelManager.findImage(byCode: code),
        let imageBytes = image.image?.bytes,
        let imageType = try image.imageType.get() else {
          throw Abort(.notFound)
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





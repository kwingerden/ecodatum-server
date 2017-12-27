import Bits
import Crypto
import Foundation
import HTTP
import Vapor

final class APIV1PublicImagesController: ResourceRepresentable {
  
  let drop: Droplet
  
  let modelManager: ModelManager
  
  init(drop: Droplet,
       modelManager: ModelManager) {
    self.drop = drop
    self.modelManager = modelManager
  }
  
  // GET /api/v1/public/images/:code
  func show(_ request: Request,
            _ code: String) throws -> ResponseRepresentable {
    
    guard let image = try modelManager.findImage(byCode: code),
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
  
  func makeResource() -> Resource<String> {
    return Resource(show: show)
  }
  
}





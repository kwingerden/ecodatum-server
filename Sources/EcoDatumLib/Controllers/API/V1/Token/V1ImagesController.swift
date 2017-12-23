import Foundation
import Vapor

final class V1ImagesController: ResourceRepresentable {
  
  let drop: Droplet
  
  private let IMAGES_DIRECTORY_NAME = ".images"
  
  init(_ drop: Droplet) {
    self.drop = drop
  }
  
  // GET /images
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    if try request.checkRootUser() {
      return try Image.all().makeJSON()
    } else {
      return try Image
        .makeQuery()
        .filter(Image.Keys.userId, .equals, request.user().id)
        .all()
        .makeJSON()
    }
    
  }
  
  // GET /images/:id
  func show(_ request: Request,
            _ image: Image) throws -> ResponseRepresentable {
    
    try assertUserOwnsImageOrIsAdmin(request, image)
    let base64Encoded = try loadImage(image.uuid, image.imageType)
    var json = try image.makeJSON()
    try json.set(Image.Keys.base64Encoded, base64Encoded)
    return json
    
  }
  
  // POST /images
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    let json = try request.assertJson()
    guard let base64Encoded: String = try json.get(Image.Keys.base64Encoded),
      let imageTypeInt: Int = try json.get(Image.Keys.imageType),
      let imageType = Image.ImageType(rawValue: imageTypeInt) else {
      throw Abort(.badRequest, reason: "Invalid data")
    }
    
    let uuid = try saveImage(base64Encoded, imageType)
    let userId = try request.user().assertExists()
    let image = Image(uuid: uuid, imageType: imageType, userId: userId)
    try image.save()
    
    return image
    
  }
  
  func makeResource() -> Resource<Image> {
    return Resource(
      index: index,
      store: store,
      show: show)
  }
  
  private func assertUserOwnsImageOrIsAdmin(_ request: Request, _ image: Image) throws {
    
    let userOwnsImage = try request.checkUserOwnsImage(image)
    let isRootUser = try request.checkRootUser()
    if userOwnsImage || isRootUser {
      // Do nothing
    } else {
      throw Abort(.unauthorized)
    }
    
  }
  
  private func saveImage(_ base64Encoded: String,
                         _ imageType: Image.ImageType) throws -> String {
    
    let uuid = UUID().uuidString
    let fileName = "\(uuid).\(imageType)"
    let fileURL = URL(fileURLWithPath: drop.config.workDir)
      .appendingPathComponent(IMAGES_DIRECTORY_NAME, isDirectory: true)
      .appendingPathComponent(fileName, isDirectory: false)
    do {
      let data = Data(base64Encoded: Data(bytes: base64Encoded.bytes))
      try data!.write(to: fileURL)
    } catch {
      throw Abort(.internalServerError, reason: "Failure")
    }
    
    return uuid
    
  }
  
  private func loadImage(_ uuid: String,
                         _ imageType: Image.ImageType) throws -> String {
    
    let fileName = "\(uuid).\(imageType)"
    let fileURL = URL(fileURLWithPath: drop.config.workDir)
      .appendingPathComponent(IMAGES_DIRECTORY_NAME, isDirectory: true)
      .appendingPathComponent(fileName, isDirectory: false)
    do {
      let data = try Data(contentsOf: fileURL)
      return data.base64EncodedString()
    } catch {
      throw Abort(.internalServerError, reason: "Failure")
    }
  
  }
  
}




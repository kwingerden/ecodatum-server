import Vapor

final class V1PhotosController: ResourceRepresentable {
  
  let drop: Droplet
  
  init(_ drop: Droplet) throws {
    self.drop = drop
  }
  
  // GET /photos
  func index(_ request: Request) throws -> ResponseRepresentable {
    
    if try request.checkUserIsAdmin() {
      return try Photo.all().makeJSON()
    } else {
      return try Photo
        .makeQuery()
        .filter(Photo.Keys.userId, .equals, request.user().id)
        .all()
        .makeJSON()
    }
    
  }
  
  // GET /photos/:id
  func show(_ request: Request,
            _ photo: Photo) throws -> ResponseRepresentable {
    
    try assertUserOwnsPhotoOrIsAdmin(request, photo)
    return photo
    
  }
  
  // POST /photos
  func store(_ request: Request) throws -> ResponseRepresentable {
    
    guard let base64: String = try request.assertJson().get(Photo.Keys.base64) else {
      throw Abort(.badRequest, reason: "No photo data.")
    }
    
    let userId = try request.user().assertExists()
    let photo = Photo(base64: base64, userId: userId)
    try photo.save()
    
    guard let id = photo.id?.int else {
      throw Abort(.badRequest, reason: "Bad photo id.")
    }
    
    return try JSON(node: [
      Photo.Keys.id : id,
      Photo.Keys.userId : photo.userId])
    
  }
  
  func makeResource() -> Resource<Photo> {
    return Resource(
      index: index,
      store: store,
      show: show)
  }
  
  private func assertUserOwnsPhotoOrIsAdmin(_ request: Request, _ photo: Photo) throws {
    
    let userOwnsPhoto = try request.checkUserOwnsPhoto(photo)
    let userIsAdmin = try request.checkUserIsAdmin()
    if userOwnsPhoto || userIsAdmin {
      // Do nothing
    } else {
      throw Abort(.unauthorized)
    }
    
  }
  
}




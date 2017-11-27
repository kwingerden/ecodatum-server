import AuthProvider
import Vapor

extension Droplet {
  
  public func setup() throws {
    try setupPasswordVerifier()
    try setupControllers()
  }
  
  private func setupPasswordVerifier() throws {
    guard let verifier = hash as? PasswordVerifier else {
      throw Abort(
        .internalServerError,
        reason: "\(type(of: hash)) must conform to PasswordVerifier.")
    }
    User.passwordVerifier = verifier
  }
  
  private func setupControllers() throws {
    let controllers = ControllerCollection(hash, view)
    try collection(controllers)
  }
  
}

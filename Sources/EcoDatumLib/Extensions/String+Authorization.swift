import Foundation

struct Base64EncodingError: Error {}

extension String {
  
  func bearerAuthorization() -> String {
    return "\(Constants.BEARER_AUTHORIZATION_PREFIX) \(self)"
  }
  
  func basicAuthorization(password: String) throws -> String {
    guard let base64Encoded = "\(self):\(password)".data(using: .utf8)?.base64EncodedString() else {
      throw Base64EncodingError()
    }
    return "\(Constants.BASIC_AUTHORIZATION_PREFIX) \(base64Encoded)"
  }
  
}

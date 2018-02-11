import HTTP

struct Constants {
    
  static let MIN_PASSWORD_COUNT = 6
  
  static let AUTHORIZATION_HEADER_KEY: HeaderKey = HeaderKey("Authorization")
  static let CONTENT_TYPE_HEADER_KEY: HeaderKey = HeaderKey("Content-Type")
  
  static let BASIC_AUTHORIZATION_PREFIX = "Basic"
  static let BEARER_AUTHORIZATION_PREFIX = "Bearer"
  
  static let JSON_CONTENT_TYPE = "application/json"
   
}

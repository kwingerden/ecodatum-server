import HTTP

struct Constants {
  
  static let AUTHORIZATION_HEADER_KEY: HeaderKey = HeaderKey("Authorization")
  static let CONTENT_TYPE_HEADER_KEY: HeaderKey = HeaderKey("Content-Type")
  
  static let BASIC_AUTHORIZATION_PREFIX = "Basic"
  static let BEARER_AUTHORIZATION_PREFIX = "Bearer"
  
  static let JSON_CONTENT_TYPE = "application/json"
  
  static let HELLO_RESOURCE = "hello"
  static let LOGIN_RESOURCE = "login"
  static let ME_RESOURCE = "me"
  static let ORGANIZATIONS_RESOURCE = "organizations"
  static let USERS_RESOURCE = "users"
  
}

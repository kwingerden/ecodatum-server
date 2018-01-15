import AuthProvider
import Foundation
import Vapor

extension User: JSONConvertible {
  
  struct Json {
    static let id = Keys.id
    static let name = Keys.name
    static let email = Keys.email
    static let password = Keys.password
  }
  
  convenience init(json: JSON) throws {
    self.init(name: try json.get(Json.name),
              email: try json.get(Json.email),
              password: try json.get(Json.password))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Json.id, id)
    try json.set(Json.name, name)
    try json.set(Json.email, email)
    return json
  }
  
}

extension User: ResponseRepresentable { }

extension User: PasswordAuthenticatable {
  
  var hashedPassword: String? {
    return password
  }
  
  public static var passwordVerifier: PasswordVerifier? {
    get {
      return _userPasswordVerifier
    }
    set {
      _userPasswordVerifier = newValue
    }
  }
  
}
private var _userPasswordVerifier: PasswordVerifier? = nil

extension User: TokenAuthenticatable {
  
  typealias TokenType = Token
  
}



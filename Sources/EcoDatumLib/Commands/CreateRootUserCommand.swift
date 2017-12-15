import Console
import FluentProvider
import Vapor

public final class CreateRootUserCommand: Command {
  
  public let id = "create-root-user"
  
  public let console: ConsoleProtocol
  
  let name: String
  
  let email: String
  
  let password: String

  public init(console: ConsoleProtocol,
              name: String,
              email: String,
              password: String) {
    self.console = console
    self.name = name
    self.email = email
    self.password = password
  }
  
  public func run(arguments: [String]) throws {
    
    if let _ = try User.makeQuery().filter("name", .equals, "root").first() {
      console.print("Root user already exists. No need to do anything.")
      return
    }
    
    let user = User(name: name,
                    email: email,
                    password: password,
                    isAdmin: true)
    try user.save()
    console.print("Successfully create the root user.")
    
  }
  
}

extension CreateRootUserCommand: ConfigInitializable {
  
  public convenience init(config: Config) throws {
    
    guard let rootUser = config.wrapped.object?["app"]?["root-user"],
      let name = rootUser["name"]?.string,
      let email = rootUser["email"]?.string,
      let password = rootUser["password"]?.string else {
      throw Abort(.badRequest)
    }
    
    let console = try config.resolveConsole()
    self.init(console: console,
              name: name,
              email: email,
              password: password)
    
  }
  
}

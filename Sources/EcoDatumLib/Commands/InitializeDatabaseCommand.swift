import Console
import FluentProvider
import Vapor

public final class InitializeDatabaseCommand: Command {
  
  public let id = "initialize-database"
  
  public let console: ConsoleProtocol
  
  let rootUserName: String
  
  let rootUserEmail: String
  
  let rootUserPassword: String

  public init(console: ConsoleProtocol,
              rootUserName: String,
              rootUserEmail: String,
              rootUserPassword: String) {
    self.console = console
    self.rootUserName = rootUserName
    self.rootUserEmail = rootUserEmail
    self.rootUserPassword = rootUserPassword
  }
  
  public func run(arguments: [String]) throws {
  
    // Create "root" user
    if let user = try User.find(Constants.ROOT_USER_ID) {
      
      if user.name == rootUserName && user.email == rootUserEmail {
        console.print("Root user '\(rootUserName)' already exists.")
      } else {
        throw Abort(.internalServerError,
                    reason: "Root user name and email address do not match.")
      }

    } else {

      let user = User(name: rootUserName, 
                      email: rootUserEmail, 
                      password: rootUserPassword)
      try user.save()
      if let userId = user.id?.int,
        userId == Constants.ROOT_USER_ID {
        console.print("Successfully created the root user.")
      } else {
        throw Abort(.internalServerError,
                    reason: "Root user id is not \(Constants.ROOT_USER_ID).")
      }

    }

    // Abiotic Factors
    try AbioticFactor.Name.all.forEach {
        let abioticFactor = AbioticFactor(name: $0)
        try abioticFactor.save()
        console.print("Successfully created abiotic factor \($0).")
    }

    // Measurement Units
    try MeasurementUnit.Name.all.forEach {
        let measurementUnit = MeasurementUnit(name: $0)
        try measurementUnit.save()
        console.print("Successfully created measurement unit \($0).")
    }
    
    // Image Types
    try ImageType.Name.all.forEach {
      let imageType = ImageType(name: $0)
      try imageType.save()
      console.print("Successfully created image type \($0).")
    }

    // Roles
    try Role.Name.all.forEach {
        let role = Role(name: $0)
        try role.save()
        console.print("Successfully created role \($0).")
    }
    
  }
  
}

extension InitializeDatabaseCommand: ConfigInitializable {
  
  public convenience init(config: Config) throws {
    
    guard let rootUser = config.wrapped.object?["app"]?["root-user"],
      let rootUserName = rootUser["name"]?.string,
      let rootUserEmail = rootUser["email"]?.string,
      var rootUserPassword = rootUser["password"]?.string else {
      throw Abort(.badRequest)
    }
    
    let hash = try config.resolveHash()
    rootUserPassword = try hash.make(rootUserPassword.makeBytes()).makeString()
    
    let console = try config.resolveConsole()
    self.init(console: console,
              rootUserName: rootUserName,
              rootUserEmail: rootUserEmail,
              rootUserPassword: rootUserPassword)

  }
  
}


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
    var id = 1
    try AbioticFactor.Name.all.forEach {
      if let abioticFactor = try AbioticFactor.makeQuery()
        .filter(AbioticFactor.Keys.name, .equals, $0.rawValue)
        .first() {
        if id == abioticFactor.id?.int {
          console.print("Abiotic Factor \($0) already exists.")
        } else {
          console.print("WARNING: unexpected id \(id) for Abiotic Factor \($0)")
        }
      } else {
        let abioticFactor = AbioticFactor(name: $0)
        try abioticFactor.save()
        console.print("Successfully created Abiotic Factor \($0).")
      }
      id = id + 1
    }
    
    // Measurement Units
    id = 1
    try MeasurementUnit.Name.all.forEach {
      if let measurementUnit = try MeasurementUnit.makeQuery()
        .filter(MeasurementUnit.Keys.name, .equals, $0.rawValue)
        .first() {
        if id == measurementUnit.id?.int {
          console.print("Measurement Unit \($0) already exists.")
        } else {
          console.print("WARNING: unexpected id \(id) for Measurement Unit \($0)")
        }
      } else {
        let measurementUnit = MeasurementUnit(name: $0)
        try measurementUnit.save()
        console.print("Successfully created Measurement Unit \($0).")
      }
      id = id + 1
    }
    
    // Image Types
    id = 1
    try ImageType.Name.all.forEach {
      if let imageType = try ImageType.makeQuery()
        .filter(ImageType.Keys.name, .equals, $0.rawValue)
        .first() {
        if id == imageType.id?.int {
          console.print("Image Type \($0) already exists.")
        } else {
          console.print("WARNING: unexpected id \(id) for Image Type \($0)")
        }
      } else {
        let imageType = ImageType(name: $0)
        try imageType.save()
        console.print("Successfully created Image Type \($0).")
      }
      id = id + 1
    }
    
    // Roles
    id = 1
    try Role.Name.all.forEach {
      if let role = try Role.makeQuery()
        .filter(Role.Keys.name, .equals, $0.rawValue)
        .first() {
        if id == role.id?.int {
          console.print("Role \($0) already exists.")
        } else {
          console.print("WARNING: unexpected id \(id) for Role \($0)")
        }
      } else {
        let role = Role(name: $0)
        try role.save()
        console.print("Successfully created Role \($0).")
      }
      id = id + 1
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


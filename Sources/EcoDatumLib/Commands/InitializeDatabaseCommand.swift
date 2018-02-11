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
    if let rootUser = try User.makeQuery()
      .filter(User.Keys.fullName, .equals, rootUserName)
      .first() {
      
      console.print("Root user '\(rootUser.fullName)' already exists.")
      
    } else {
      
      let rootUser = User(
        fullName: rootUserName,
        email: rootUserEmail,
        password: rootUserPassword)
      try rootUser.save()
      
      console.print("Successfully created the root user with name \(rootUser.fullName).")
      
    }
    
    // Abiotic Factors
    try AbioticFactor.Name.all.forEach {
      
      if let abioticFactor = try AbioticFactor.makeQuery()
        .filter(AbioticFactor.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Abiotic Factor \(abioticFactor.name.rawValue) already exists.")
      
      } else {
      
        let abioticFactor = AbioticFactor(name: $0)
        try abioticFactor.save()
        
        console.print("Successfully created Abiotic Factor \(abioticFactor.name.rawValue).")
      
      }
      
    }
    
    // Measurement Units
    try MeasurementUnit.Name.all.forEach {
      
      if let measurementUnit = try MeasurementUnit.makeQuery()
        .filter(MeasurementUnit.Keys.name, .equals, $0.rawValue)
        .first() {
      
        console.print("Measurement Unit \(measurementUnit.name.rawValue) already exists.")

      } else {
        
        let measurementUnit = MeasurementUnit(name: $0)
        try measurementUnit.save()
       
        console.print("Successfully created Measurement Unit \(measurementUnit.name.rawValue).")
      
      }
      
    }
    
    // Image Types
    try ImageType.Name.all.forEach {
      
      if let imageType = try ImageType.makeQuery()
        .filter(ImageType.Keys.name, .equals, $0.rawValue)
        .first() {
      
        console.print("Image Type \(imageType.name.rawValue) already exists.")
        
      } else {
        
        let imageType = ImageType(name: $0)
        try imageType.save()
        
        console.print("Successfully created Image Type \(imageType.name.rawValue).")
        
      }
      
    }
    
    // Roles
    try Role.Name.all.forEach {
      
      if let role = try Role.makeQuery()
        .filter(Role.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Role \(role.name.rawValue) already exists.")
        
      } else {
        
        let role = Role(name: $0)
        try role.save()
        
        console.print("Successfully created Role \(role.name.rawValue).")
      
      }
      
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


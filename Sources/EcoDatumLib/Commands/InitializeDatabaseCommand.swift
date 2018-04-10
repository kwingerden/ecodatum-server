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
    
    // Ecosystem Factors
    
    try EcosystemFactor.Name.all.forEach {
      
      if let ecosystemFactor = try EcosystemFactor.makeQuery()
        .filter(EcosystemFactor.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Ecosystem Factor \(ecosystemFactor.name.rawValue) already exists.")
        
      } else {
        
        let ecosystemFactor = EcosystemFactor(name: $0)
        try ecosystemFactor.save()
        
        console.print("Successfully created Ecosystem Factor \(ecosystemFactor.name.rawValue).")
        
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
    
    // Media Type
    
    try MediaType.Name.all.forEach {
      
      if let mediaType = try MediaType.makeQuery()
        .filter(MediaType.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Media Type \(mediaType.name.rawValue) already exists.")
        
      } else {
        
        let mediaType = MediaType(name: $0)
        try mediaType.save()
        
        console.print("Successfully created Media Type \(mediaType.name.rawValue).")
        
      }
      
    }
    
    // Qualitative Observation Types
    
    try QualitativeObservationType.Name.all.forEach {
      
      if let qualitativeObservationType = try QualitativeObservationType.makeQuery()
        .filter(QualitativeObservationType.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Qualitative Observation Type \(qualitativeObservationType.name.rawValue) already exists.")
        
      } else {
        
        let qualitativeObservationType = QualitativeObservationType(name: $0)
        try qualitativeObservationType.save()
        
        console.print("Successfully created Qualitative Observation Type \(qualitativeObservationType.name.rawValue).")
        
      }
      
    }
    
    // Quantitative Observation Types
    
    try QuantitativeObservationType.Name.all.forEach {
      
      if let quantitativeObservationType = try QuantitativeObservationType.makeQuery()
        .filter(QuantitativeObservationType.Keys.name, .equals, $0.rawValue)
        .first() {
        
        console.print("Quantitative Observation Type \(quantitativeObservationType.name.rawValue) already exists.")
        
      } else {
        
        let quantitativeObservationType = QuantitativeObservationType(name: $0)
        try quantitativeObservationType.save()
        
        console.print("Successfully created Quantitative Observation Type \(quantitativeObservationType.name.rawValue).")
        
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


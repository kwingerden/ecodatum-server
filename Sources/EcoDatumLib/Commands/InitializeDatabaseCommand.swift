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

    // Primary Abiotic Factors
    try PrimaryAbioticFactor.Name.all.forEach {

      if let primaryAbioticFactor = try PrimaryAbioticFactor.makeQuery()
        .filter(PrimaryAbioticFactor.Keys.name, .equals, $0.name.rawValue)
        .first() {

        console.print("Primary Abiotic Factor \(primaryAbioticFactor.name.rawValue) already exists.")

      } else {

        let primaryAbioticFactor = PrimaryAbioticFactor(
          name: $0.name,
          description: $0.description)
        try primaryAbioticFactor.save()

        console.print("Successfully created Primary Abiotic Factor \(primaryAbioticFactor.name.rawValue).")

      }

    }
    
    // Secondary Abiotic Factors
    try SecondaryAbioticFactor.Name.all.forEach {
      
      if let secondaryAbioticFactor = try SecondaryAbioticFactor.makeQuery()
        .filter(SecondaryAbioticFactor.Keys.name, .equals, $0.name.rawValue)
        .first() {
        
        console.print("Secondary Abiotic Factor \(secondaryAbioticFactor.name.rawValue) already exists.")
        
      } else {
        
        let secondaryAbioticFactor = SecondaryAbioticFactor(
          name: $0.name,
          label: $0.label,
          description: $0.description)
        try secondaryAbioticFactor.save()
        
        console.print("Successfully created Secondary Abiotic Factor \(secondaryAbioticFactor.name.rawValue).")
        
      }
      
    }

    // Measurement Units
    try MeasurementUnit.Dimension.all.forEach {

      if let measurementUnit = try MeasurementUnit.makeQuery()
        .filter(MeasurementUnit.Keys.dimension, .equals, $0.dimension.rawValue)
        .filter(MeasurementUnit.Keys.unit, .equals, $0.unit.rawValue)
        .first() {

        console.print("Measurement Unit \(measurementUnit.dimension.rawValue), \(measurementUnit.unit.rawValue) already exists.")

      } else {

        let measurementUnit = MeasurementUnit(
          dimension: $0.dimension,
          unit: $0.unit,
          description: $0.description)
        try measurementUnit.save()

        console.print("Successfully created Measurement Unit \(measurementUnit.dimension.rawValue), \(measurementUnit.unit.rawValue).")

      }

    }

    // Abiotic Factors X Measurement Units

    try AbioticFactorMeasurementUnit.all.forEach {
      primaryAbioticFactor in
      
      try primaryAbioticFactor.value.forEach {
        secondaryAbioticFactor in
        
        if let paf = try PrimaryAbioticFactor.makeQuery().filter(
            PrimaryAbioticFactor.Keys.name, .equals, primaryAbioticFactor.key.rawValue)
            .first(),
          let saf = try SecondaryAbioticFactor.makeQuery().filter(
            SecondaryAbioticFactor.Keys.name, .equals, secondaryAbioticFactor.key.rawValue)
            .first(),
          let mu = try MeasurementUnit.makeQuery().filter(
            MeasurementUnit.Keys.dimension, .equals, secondaryAbioticFactor.value.rawValue)
            .first() {
          
          if let _ = try AbioticFactorMeasurementUnit.makeQuery()
            .filter(AbioticFactorMeasurementUnit.Keys.primaryAbioticFactorId, .equals, paf.id)
            .filter(AbioticFactorMeasurementUnit.Keys.secondaryAbioticFactorId, .equals, saf.id)
            .filter(AbioticFactorMeasurementUnit.Keys.measurementUnitId, .equals, mu.id)
            .first() {
            
            console.print("Abiotic Factor Measurement Unit \(paf.name.rawValue), \(saf.name.rawValue), \(mu.dimension.rawValue) already exists.")
            
          } else {
            
            if let pafId = paf.id, let safId = saf.id, let muId = mu.id {
              
              let amu = AbioticFactorMeasurementUnit(
                primaryAbioticFactorId: pafId,
                secondaryAbioticFactorId: safId,
                measurementUnitId: muId)
              try AbioticFactorMeasurementUnit.makeQuery().save(amu)
              
              console.print("Successfully create Abiotic Factor Measurement Unit \(paf.name.rawValue), \(saf.name.rawValue), \(mu.dimension.rawValue) already exists.")
              
            } else {
              
              console.print("Failed to create Primary, Secondary, or Measurement Unit!!!")
              
            }
            
          }
          
        } else {
          
          console.print("Failed to create Primary, Secondary, or Measurement Unit!!!")
          
        }
        
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


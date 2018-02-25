import Console
import FluentProvider
import Random
import Vapor

public final class AddTestDataCommand: Command {
  
  public let id = "add-test-data"
  
  public let console: ConsoleProtocol
  
  private let hash: HashProtocol
  
  private enum CommandError: Error {
    case invalidCount(String)
  }
  
  private let rootUserName: String
  
  private let rootUserEmail: String
  
  private let rootUserPassword: String
  
  public init(console: ConsoleProtocol,
              hash: HashProtocol,
              rootUserName: String,
              rootUserEmail: String,
              rootUserPassword: String) {
    self.console = console
    self.hash = hash
    self.rootUserName = rootUserName
    self.rootUserEmail = rootUserEmail
    self.rootUserPassword = rootUserPassword
  }
  
  public func run(arguments: [String]) throws {
    
    let count = 5
    let users = try createOrGetUsers(count)
    let organizations = try createOrGetOrganizations(count)
    try associate(
      users: users,
      with: organizations)
    let sites = try createOrGetSites(
      for: organizations,
      with: users)
    let surveys = try createSurveys(
      for: sites,
      with: users)
    try createMeasurements(
      count,
      for: surveys,
      with: users)
    
  }
  
  private func createOrGetUsers(
    _ count: Int = 5) throws -> [User] {
    
    guard 1...9 ~= count else {
      throw CommandError.invalidCount("Invalid User count: \(count)")
    }
    
    let password = try hash.make(
      "password".makeBytes())
      .makeString()
    
    var users: [User] = []
    for index in 0...count - 1 {
      
      let fullName = "Test User\(index)"
      let email = "test.user\(index)@ecodatum.org"
      
      var user: User
      if let existingUser = try User.makeQuery()
        .filter(User.Keys.email,
                .equals,
                email)
        .first() {
        
        user = existingUser
        
      } else {
        
        let newUser = User(
          fullName: fullName,
          email: email,
          password: password)
        try newUser.save()
        
        user = newUser
        
      }
      
      users.insert(user, at: index)
      
    }
    
    return users
    
  }
  
  private func createOrGetOrganizations(
    _ count: Int = 5) throws -> [Organization] {
    
    guard 1...9 ~= count else {
      throw CommandError.invalidCount("Invalid Organization count: \(count)")
    }
    
    var organizations: [Organization] = []
    for index in 0...count - 1 {
    
      let name = "Test Organization\(index)"
      let description = "The description for Test Organization\(index)"
      let code = "AAAAA\(index)"
      
      var organization: Organization
      if let existingOrganization = try Organization.makeQuery()
        .filter(Organization.Keys.name,
                .equals,
                name)
        .first() {
        
        organization = existingOrganization
        
      } else {
        
        let newOrganization = Organization(
          name: name,
          description: description,
          code: code)
        try newOrganization.save()
        
        organization = newOrganization
        
      }
      
      organizations.insert(organization, at: index)
      
    }
    
    return organizations
    
  }
  
  private func associate(
    users: [User],
    with organizations: [Organization]) throws {
    
    let administratorRole = try Role.makeQuery()
      .filter(Role.Keys.name,
              .equals,
              Role.Name.ADMINISTRATOR.rawValue)
      .first()!
    let memberRole = try Role.makeQuery()
      .filter(Role.Keys.name,
              .equals,
              Role.Name.MEMBER.rawValue)
      .first()!
    
    for organization in organizations {
      
      var firstUser = true
      for user in users {
        
        var role = memberRole
        if firstUser {
          
          role = administratorRole
          firstUser = false
        
        }
        
        if try UserOrganizationRole.makeQuery()
          .filter(UserOrganizationRole.Keys.organizationId,
                  .equals,
                  organization.id!)
          .filter(UserOrganizationRole.Keys.roleId,
                  .equals,
                  memberRole.id!)
          .filter(UserOrganizationRole.Keys.userId,
                  .equals,
                  user.id!)
          .first() == nil {
          
          try UserOrganizationRole(
            userId: user.id!,
            organizationId: organization.id!,
            roleId: role.id!)
            .save()
          
        }
        
      }
    }
    
  }
  
  private func createOrGetSites(
    for organizations: [Organization],
    with users: [User]) throws -> [Site] {
    
    var sites: [Site] = []
    
    let administratorRole = try Role.makeQuery()
      .filter(Role.Keys.name,
              .equals,
              Role.Name.ADMINISTRATOR.rawValue)
      .first()!
    
    var firstOrganization = true
    for organization in organizations {
      
      var user = users.random!
      if firstOrganization {
        
        let organizationAdministrator = try UserOrganizationRole.makeQuery()
          .filter(UserOrganizationRole.Keys.organizationId,
                  .equals,
                  organization.id!)
          .filter(UserOrganizationRole.Keys.roleId,
                  .equals,
                  administratorRole.id!)
          .first()!
        
        user = try User.find(organizationAdministrator.userId)!
        
        firstOrganization = false
        
      }
      
      let name = "Site for \(organization.name)"
      let description = "This is the description for Site for \(organization.name)"
      let latitude = randomSignedDouble()
      let longitude = randomSignedDouble()
    
      var site: Site
      if let existingSite = try Site.makeQuery()
        .filter(Site.Keys.name,
                .equals,
                name)
        .first() {
        
        site = existingSite
        
      } else {
        
        let newSite = Site(
          name: name,
          description: description,
          latitude: latitude,
          longitude: longitude,
          organizationId: organization.id!,
          userId: user.id!)
        try newSite.save()
        
        site = newSite
        
      }

      sites.append(site)
    
    }
    
    return sites
    
  }
  
  private func createSurveys(
    for sites: [Site],
    with users: [User]) throws -> [Survey] {
    
    var surveys: [Survey] = []
    
    for site in sites {
     
      let survey = Survey(
        date: Date(),
        siteId: site.id!,
        userId: users.random!.id!)
      try survey.save()
      
      surveys.append(survey)
      
    }

    return surveys
    
  }
  
  private func createMeasurements(
    _ count: Int = 5,
    for surveys: [Survey],
    with users: [User]) throws {
  
    let afmus = try AbioticFactorMeasurementUnit.all()

    for survey in surveys {
      
      for _ in 0...count - 1 {
        
        let amfu = afmus.random!
        let measurement = Measurement(
          value: randomSignedDouble(),
          primaryAbioticFactorId: amfu.primaryAbioticFactorId,
          secondaryAbioticFactorId: amfu.secondaryAbioticFactorId,
          measurementUnitId: amfu.measurementUnitId,
          surveyId: survey.id!,
          userId: users.random!.id!)
        try measurement.save()
      
      }
      
    }
    
  }
  
  private func randomSignedDouble() -> Double {
    
    let sign = makeRandom(min: 0, max: 1) == 0 ? 1.0 : -1.0
    let number = Double(makeRandom(min: 1, max: 500))
    let fraction = Double(makeRandom(min: 1, max: 500)) / 100.0
    return sign * (number + fraction)
  
  }
  
}

extension AddTestDataCommand: ConfigInitializable {
  
  public convenience init(config: Config) throws {
    
    guard let rootUser = config.wrapped.object?["app"]?["root-user"],
      let rootUserName = rootUser["name"]?.string,
      let rootUserEmail = rootUser["email"]?.string,
      let rootUserPassword = rootUser["password"]?.string else {
        throw Abort(.badRequest)
    }
    
    let console = try config.resolveConsole()
    let hash = try config.resolveHash()
    self.init(console: console,
              hash: hash,
              rootUserName: rootUserName,
              rootUserEmail: rootUserEmail,
              rootUserPassword: rootUserPassword)
    
  }
  
}



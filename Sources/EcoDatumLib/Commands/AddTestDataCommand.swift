import Console
import FluentProvider
import Foundation
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
    
    let count = 10
    let users = try createOrGetUsers(count)
    let organizations = try createOrGetOrganizations(count)
    try associate(
      users: users,
      with: organizations)
    let sites = try createOrGetSites(
      for: organizations,
      with: users)

  }
  
  private func createOrGetUsers(
    _ count: Int = 5) throws -> [User] {
    
    let password = try hash.make(
      "password".makeBytes())
      .makeString()
    
    var users: [User] = []
    for index in 1...count {
      
      let fullName = "Test User \(index)"
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
      
      users.append(user)
      
    }
    
    return users
    
  }
  
  private func createOrGetOrganizations(
    _ count: Int = 5) throws -> [Organization] {
    
    var organizations: [Organization] = []
    for index in 1...count {
    
      let name = "Test Organization \(index)"
      let description = "The description for \(name)"
      let code: String = {
        if index < 10 {
          return "AAAAA\(index)"
        } else {
          return "AAAA\(index)"
        }
      }()
      
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
      
      organizations.append(organization)
      
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
    with users: [User],
    _ count: Int = 5) throws -> [Site] {
    
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
      
      for index in 1...count {
        
        let name = "Site \(index) for \(organization.name)"
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
    
    }
    
    return sites
    
  }
  
  private func randomSignedDouble() -> Double {
    
    let sign = makeRandom(min: 0, max: 1) == 0 ? 1.0 : -1.0
    let number = Double(makeRandom(min: 1, max: 500))
    let fraction = Double(makeRandom(min: 1, max: 500)) / 100.0
    return sign * (number + fraction)
  
  }
  
  private func generateRandomDate(daysBack: Int) -> Date? {
    
    let day = makeRandom(min: 0, max: daysBack) + 1
    let hour = makeRandom(min: 0, max: 23)
    let minute = makeRandom(min: 0, max: 59)
    
    let today = Date(timeIntervalSinceNow: 0)
    let gregorian = Calendar(identifier: .gregorian)
    var offsetComponents = DateComponents()
    offsetComponents.day = -Int(day - 1)
    offsetComponents.hour = -Int(hour)
    offsetComponents.minute = -Int(minute)
    
    return gregorian.date(
      byAdding: offsetComponents,
      to: today)
    
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



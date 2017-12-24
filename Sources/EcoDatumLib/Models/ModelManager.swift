import Foundation
import Fluent
import Vapor

class ModelManager {
  
  let drop: Droplet
  
  init(_ drop: Droplet) throws {
    self.drop = drop
  }
  
  func getRootUser() throws -> User {
    
    guard let rootUserConfig = drop.config.wrapped.object?["app"]?["root-user"],
      let rootUserName = rootUserConfig["name"]?.string,
      let rootUserEmail = rootUserConfig["email"]?.string else {
        throw Abort(.expectationFailed)
    }
    guard let rootUser = try User.find(Constants.ROOT_USER_ID),
      rootUser.name == rootUserName,
      rootUser.email == rootUserEmail else {
        throw Abort(.expectationFailed)
    }
    
    return rootUser
    
  }
  
  func getRole(_ connection: Connection? = nil,
               name: Role.Name) throws -> Role {
    
    guard let role = try Role.makeQuery(connection)
      .filter(Role.Keys.name, .equals, name.rawValue)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    return role
    
  }
  
  func getAbioticFactor(_ connection: Connection? = nil,
                        name: AbioticFactor.Name) throws -> AbioticFactor {
    
    guard let abioticFactor = try AbioticFactor.makeQuery(connection)
      .filter(AbioticFactor.Keys.name, .equals, name.rawValue)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    return abioticFactor
    
  }
  
  func getMeasurementUnit(_ connection: Connection? = nil,
                          name: MeasurementUnit.Name) throws -> MeasurementUnit {
    
    guard let measurementUnit = try MeasurementUnit.makeQuery(connection)
      .filter(MeasurementUnit.Keys.name, .equals, name.rawValue)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    return measurementUnit
    
  }
  
  func createUser(_ connection: Connection? = nil,
                  name: String,
                  email: String,
                  password: String) throws -> User {
    
    let hashedPassword = try drop.hash.make(password.makeBytes()).makeString()
    let user = User(name: name, email: email, password: hashedPassword)
    try User.makeQuery(connection).save(user)
    
    return user
    
  }
  
  func createOrganization(_ connection: Connection? = nil,
                          user: User,
                          name: String,
                          code: String) throws -> Organization {
    
    let organization = Organization(name: name, code: code)
    try Organization.makeQuery(connection).save(organization)
    
    try _ = addUserToOrganization(connection,
                                  user: user,
                                  organization: organization,
                                  role: .ADMINISTRATOR)
    
    return organization
    
  }
  
  func addUserToOrganization(_ connection: Connection? = nil,
                             user: User,
                             organization: Organization,
                             role: Role.Name) throws -> UserOrganizationRole {
    
    guard let userId = user.id,
      let organizationId = organization.id,
      let roleId = try getRole(connection, name: role).id else {
        throw Abort(.expectationFailed)
    }
    
    let userOrganizationRole = UserOrganizationRole(
      userId: userId,
      organizationId: organizationId,
      roleId: roleId)
    try UserOrganizationRole.makeQuery(connection).save(userOrganizationRole)
    
    return userOrganizationRole
    
  }
  
  func createSite(_ connection: Connection? = nil,
                  name: String,
                  latitude: Double,
                  longitude: Double,
                  altitude: Double?,
                  horizontalAccuracy: Double?,
                  verticalAccuracy: Double?,
                  user: User,
                  organization: Organization) throws -> Site {
    
    guard let userId = user.id,
      let organizationId = organization.id,
      let administratorRoleId = try getRole(connection, name: .ADMINISTRATOR).id else {
        throw Abort(.expectationFailed)
    }
    
    guard let _ = try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, organizationId)
      .filter(UserOrganizationRole.Keys.roleId, .equals, administratorRoleId)
      .filter(UserOrganizationRole.Keys.userId, .equals, userId)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    let site = Site(name: name,
                    latitude: latitude,
                    longitude: longitude,
                    altitude: altitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: verticalAccuracy,
                    organizationId: organizationId,
                    userId: userId)
    try Site.makeQuery(connection).save(site)
    
    return site
    
  }
  
  func createSurvey(_ connection: Connection? = nil,
                    date: Date,
                    site: Site,
                    user: User) throws -> Survey {
    
    guard let userId = user.id,
      let siteId = site.id else {
        throw Abort(.expectationFailed)
    }
    
    guard let _ = try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, site.organizationId)
      .filter(UserOrganizationRole.Keys.userId, .equals, userId)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    let survey = Survey(date: date, siteId: siteId, userId: userId)
    try Survey.makeQuery(connection).save(survey)
    
    return survey
    
  }
  
  func createMeaurement(_ connection: Connection? = nil,
                        value: Double,
                        abioticFactor: AbioticFactor.Name,
                        measurementUnit: MeasurementUnit.Name,
                        survey: Survey) throws -> Measurement {
    
    guard let abioticFactorId = try getAbioticFactor(name: abioticFactor).id,
      let measurementUnitId = try getMeasurementUnit(name: measurementUnit).id,
      let surveyId = survey.id,
      let userId = try survey.user.get()?.id,
      let organizationId = try survey.site.get()?.organization.get()?.id else {
        throw Abort(.expectationFailed)
    }
    
    guard let _ = try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, organizationId)
      .filter(UserOrganizationRole.Keys.userId, .equals, userId)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    let measurement = Measurement(
      value: value,
      abioticFactorId: abioticFactorId,
      measurementUnitId: measurementUnitId,
      surveyId: surveyId)
    try Measurement.makeQuery(connection).save(measurement)
    
    return measurement
    
  }
  
}


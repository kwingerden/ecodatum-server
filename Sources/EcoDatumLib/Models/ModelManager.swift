import Bits
import Foundation
import Fluent
import FluentProvider
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
    
    guard let rootUser = try User.makeQuery()
      .filter(User.Keys.fullName, .equals, rootUserName)
      .first(),
      rootUser.fullName == rootUserName,
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
  
  func generateToken(_ connection: Connection? = nil,
                     for: User) throws -> Token {
  
    let userId = try `for`.assertExists()
    if let token = try Token.makeQuery(connection)
      .filter(Token.Keys.userId, .equals, userId)
      .first() {
  
      return token
    
    } else {
    
      let token = try Token.generate(for: `for`)
      try token.save()
    
      return token
    
    }
    
  }
  
  func isRootUser(_ user: User) throws -> Bool {
    return user == (try getRootUser())
  }
  
  func assertRootUser(_ user: User) throws {
    if !(try isRootUser(user)) {
      throw Abort(.forbidden)
    }
  }
  
  func isRequestUser(_ userId: String, _ user: User) throws -> Bool {
    return user == (try findUser(byId: Identifier(userId)))
  }
  
  func assertRequestUser(_ userId: String, _ user: User) throws {
    if !(try isRequestUser(userId, user)) {
      throw Abort(.forbidden)
    }
  }
  
  func isRootOrRequestUser(_ userId: String, _ user: User) throws -> Bool {
    return try isRootUser(user) || (try isRequestUser(userId, user))
  }
  
  func assertRootOrRequestUser(_ userId: String, _ user: User) throws {
    if !(try isRootOrRequestUser(userId, user)) {
      throw Abort(.forbidden)
    }
  }
 
  func transaction(_ closure: (Connection) throws -> Void) throws {
    let database = try drop.assertDatabase()
    return try database.transaction {
      connection in
      try closure(connection)
    }
  }
  
  private func hashPassword(_ password: String) throws -> String {
    return try drop.hash.make(password.makeBytes()).makeString()
  }
  
}

// MARK: User Extension

extension ModelManager {
  
  func createUser(_ connection: Connection? = nil,
                  name: String,
                  email: String,
                  password: String) throws -> User {
    
    let user = User(
      fullName: name,
      email: email.lowercased(),
      password: try hashPassword(password))
    try User.makeQuery(connection).save(user)
    
    return user
    
  }
  
  func createUser(_ connection: Connection? = nil,
                  json: JSON) throws -> User {
    
    let user = try User(json: json)
    user.password = try hashPassword(user.password)
    try user.save()
  
    return user
    
  }
  
  func findUser(_ connection: Connection? = nil,
                byId: Identifier) throws -> User? {
    return try User.makeQuery(connection).find(byId)
  }
  
  func getUser(_ connection: Connection? = nil,
               byId: Identifier) throws -> User {
    guard let user = try findUser(byId: byId) else {
      throw Abort(.notFound)
    }
    return user
  }
  
  func findUser(_ connection: Connection? = nil,
                byEmail: String) throws -> User? {
    return try User.makeQuery(connection)
      .filter(User.Keys.email, .equals, byEmail.lowercased())
      .first()
  }
  
  func getAllUsers(_ connection: Connection? = nil) throws -> [User] {
    return try User.makeQuery(connection).all()
  }
  
  func updateUser(_ connection: Connection? = nil,
                  user: User,
                  newName: String? = nil,
                  newEmail: String? = nil,
                  newPassword: String? = nil) throws -> User {
    
    try user.assertExists()
    
    if let name = newName {
      user.fullName = name
    }
    
    if let email = newEmail {
      user.email = email
    }
    
    if let password = newPassword {
      user.password = try hashPassword(password)
    }
    
    try User.makeQuery(connection).save(user)
    
    return user
    
  }
  
  func deleteUser(_ connection: Connection? = nil,
                  user: User) throws {
    try user.assertExists()
    try User.makeQuery(connection).delete(user)
  }
  
}

// MARK: Organization Extension

extension ModelManager {
  
  func createOrganization(_ connection: Connection? = nil,
                          user: User,
                          name: String,
                          description: String? = nil) throws -> Organization {
    
    let code = String(randomUpperCaseAlphaNumericLength: Organization.CODE_LENGTH)
    let organization = Organization(
      name: name,
      description: description,
      code: code)
    try Organization.makeQuery(connection).save(organization)
    
    try _ = addUserToOrganization(connection,
                                  user: user,
                                  organization: organization,
                                  role: try getRole(name: .ADMINISTRATOR))
    
    return organization
    
  }
  
  func addUserToOrganization(_ connection: Connection? = nil,
                             user: User,
                             organization: Organization,
                             role: Role) throws -> UserOrganizationRole {
    
    let userId = try user.assertExists()
    let organizationId = try organization.assertExists()
    let roleId = try role.assertExists()
    
    let userOrganizationRole = UserOrganizationRole(
      userId: userId,
      organizationId: organizationId,
      roleId: roleId)
    try UserOrganizationRole.makeQuery(connection)
      .save(userOrganizationRole)
    
    return userOrganizationRole
    
  }
  
  func addUserToOrganization(_ connection: Connection? = nil,
                             user: User,
                             organization: Organization,
                             role: Role.Name) throws -> UserOrganizationRole {
    return try addUserToOrganization(
      connection,
      user: user,
      organization: organization,
      role: getRole(name: role))
  }
  
  func findOrganization(_ connection: Connection? = nil,
                        byId: Identifier) throws -> Organization? {
    return try Organization.makeQuery(connection).find(byId)
  }
  
  func findOrganization(_ connection: Connection? = nil,
                        byCode: String) throws -> Organization? {
    return try Organization.makeQuery(connection)
      .filter(Organization.Keys.code, .equals, byCode.uppercased())
      .first()
  }
  
  func findOrganization(_ connection: Connection? = nil,
                        bySite: Site) throws -> Organization? {
    try bySite.assertExists()
    return try findOrganization(connection, byId: bySite.organizationId)
  }
  
  func findOrganization(_ connection: Connection? = nil,
                        bySurvey: Survey) throws -> Organization? {
    try bySurvey.assertExists()
    guard let site = try bySurvey.site.get() else {
      throw Abort(.expectationFailed)
    }
    return try findOrganization(connection, bySite: site)
  }
  
  func findOrganizations(_ connection: Connection? = nil,
                         byUser: User) throws -> [Organization] {
    return try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.userId, .equals, byUser.id)
      .all()
      .map {
        userOrganizationRole in
        try self.findOrganization(byId: userOrganizationRole.organizationId)!
    }
  }
  
  func getAllOrganizations(_ connection: Connection? = nil) throws -> [Organization] {
    return try Organization.makeQuery(connection).all()
  }
  
  func updateOrganization(_ connection: Connection? = nil,
                          organization: Organization,
                          newName: String? = nil,
                          newDescription: String? = nil) throws -> Organization {
    
    try organization.assertExists()
    
    if let name = newName {
      organization.name = name
    }
    
    if let description = newDescription {
      organization.description = description
    }
    
    try Organization.makeQuery(connection).save(organization)
    
    return organization
    
  }
  
  func deleteOrganization(_ connection: Connection? = nil,
                          organization: Organization) throws {
    try organization.assertExists()
    try Organization.makeQuery(connection).delete(organization)
  }
  
  func deleteAllOrganizations(_ connection: Connection? = nil) throws {
    try UserOrganizationRole.makeQuery(connection).delete()
    try Organization.makeQuery(connection).delete()
  }
  
  func doesUserBelongToOrganization(_ connection: Connection? = nil,
                                    user: User,
                                    organization: Organization) throws -> Bool {
    let first = try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.userId, .equals, user.id)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, organization.id)
      .first()
    return first != nil
  }
  
  func isUserOrganizationAdministrator(_ connection: Connection? = nil,
                                       user: User,
                                       organization: Organization) throws -> Bool {
    let role = try getRole(connection, name: .ADMINISTRATOR)
    let first = try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.userId, .equals, user.id)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, organization.id)
      .filter(UserOrganizationRole.Keys.roleId, .equals, role.id)
      .first()
    return first != nil
  }
  
  func getOrganizationUsers(_ connection: Connection? = nil,
                            organization: Organization,
                            byRole: Role.Name) throws -> [User] {
    let role = try getRole(connection, name: byRole)
    return try UserOrganizationRole.makeQuery(connection)
      .filter(UserOrganizationRole.Keys.organizationId, .equals, organization.id)
      .filter(UserOrganizationRole.Keys.roleId, .equals, role.id)
      .all()
      .flatMap {
        userOrganizationRole in
        return try self.findUser(byId: userOrganizationRole.userId)
      }
  }

}

// MARK: Site Extension

extension ModelManager {
  
  func createSite(_ connection: Connection? = nil,
                  name: String,
                  description: String? = nil,
                  latitude: Double,
                  longitude: Double,
                  altitude: Double? = nil,
                  horizontalAccuracy: Double? = nil,
                  verticalAccuracy: Double? = nil,
                  user: User,
                  organization: Organization) throws -> Site {
    
    let site = Site(name: name,
                    description: description,
                    latitude: latitude,
                    longitude: longitude,
                    altitude: altitude,
                    horizontalAccuracy: horizontalAccuracy,
                    verticalAccuracy: verticalAccuracy,
                    organizationId: try organization.assertExists(),
                    userId: try user.assertExists())
    try Site.makeQuery(connection).save(site)
    
    return site
    
  }
  
  func findSite(_ connection: Connection? = nil,
                byId: Identifier) throws -> Site? {
    return try Site.makeQuery(connection).find(byId)
  }
  
  func findSite(_ connection: Connection? = nil,
                byName: String) throws -> Site? {
    return try Site.makeQuery(connection)
      .filter(Site.Keys.name, .equals, byName)
      .first()
  }
  
  func findSite(_ connection: Connection? = nil,
                bySurvey: Survey) throws -> Site? {
    try bySurvey.assertExists()
    return try findSite(connection, byId: bySurvey.siteId)
  }
  
  func findSites(_ connection: Connection? = nil,
                 byUser: User) throws -> [Site] {
    return try Site.makeQuery(connection)
      .filter(Site.Keys.userId, .equals, byUser.id)
      .all()
  }
  
  func getAllSites(_ connection: Connection? = nil) throws -> [Site] {
    return try Site.makeQuery(connection).all()
  }
  
  func updateSite(_ connection: Connection? = nil,
                  site: Site) throws -> Site {

    try Site.makeQuery(connection).save(site)
    
    return site
    
  }
  
  func deleteSite(_ connection: Connection? = nil,
                  site: Site) throws {
    
    for survey in try site.surveys.all() {
      
      try deleteSurvey(
        connection,
        survey: survey)
      
    }
    
    try Site.makeQuery(connection).delete(site)
    
  }
  
}

// MARK: Survey Extension

extension ModelManager {
  
  func createSurvey(_ connection: Connection? = nil,
                    date: Date,
                    description: String? = nil,
                    site: Site,
                    user: User) throws -> Survey {
    
    let siteId = try site.assertExists()
    let userId = try user.assertExists()
    
    let survey = Survey(
      date: date,
      description: description,
      siteId: siteId,
      userId: userId)
    try Survey.makeQuery(connection).save(survey)
    
    return survey
    
  }
  
  func findSurvey(_ connection: Connection? = nil,
                  byId: Identifier) throws -> Survey? {
    return try Survey.makeQuery(connection).find(byId)
  }
  
  func findSurveys(_ connection: Connection? = nil,
                   byUser: User) throws -> [Survey] {
    return try Survey.makeQuery(connection)
      .filter(Survey.Keys.userId, .equals, byUser.id)
      .all()
  }
  
  func getAllSurveys(_ connection: Connection? = nil) throws -> [Survey] {
    return try Survey.makeQuery(connection).all()
  }

  func updateSurvey(_ connection: Connection? = nil,
                    survey: Survey) throws -> Survey {

    try Survey.makeQuery(connection).save(survey)

    return survey

  }

  func deleteSurvey(_ connection: Connection? = nil,
                    survey: Survey) throws {

    for image in try survey.images.all() {
      try deleteImage(
        connection,
        image: image)
    }

    for measurement in try survey.measurements.all() {
      try deleteMeasurement(
        connection,
        measurement: measurement)
    }

    for note in try survey.notes.all() {
      try deleteNote(
        connection,
        note: note)
    }

    try Survey.makeQuery(connection).delete(survey)

  }
  
}

// MARK: Measurement Extension

extension ModelManager {

  func findAbioticFactorMeasurementUnit(
    _ connection: Connection? = nil,
    primaryAbioticFactorId: Identifier,
    secondaryAbioticFactorId: Identifier,
    measurementUnitId: Identifier)
  throws -> AbioticFactorMeasurementUnit? {
    
    return try AbioticFactorMeasurementUnit.makeQuery(connection)
      .filter(
        AbioticFactorMeasurementUnit.Keys.primaryAbioticFactorId,
        .equals,
        primaryAbioticFactorId)
      .filter(
        AbioticFactorMeasurementUnit.Keys.secondaryAbioticFactorId,
        .equals,
        secondaryAbioticFactorId)
      .filter(
        AbioticFactorMeasurementUnit.Keys.measurementUnitId,
        .equals,
        measurementUnitId)
    .first()
    
  }
  
  func createMeasurement(_ connection: Connection? = nil,
                         value: Double,
                         abioticFactorMeasurementUnit: AbioticFactorMeasurementUnit,
                         surveyId: Identifier) throws -> Measurement {

    let measurement = Measurement(
      value: value,
      primaryAbioticFactorId: abioticFactorMeasurementUnit.primaryAbioticFactorId,
      secondaryAbioticFactorId: abioticFactorMeasurementUnit.secondaryAbioticFactorId,
      measurementUnitId: abioticFactorMeasurementUnit.measurementUnitId,
      surveyId: surveyId)
    try Measurement.makeQuery(connection).save(measurement)
    
    return measurement
    
  }
  
  func getAllMeasurements(_ connection: Connection? = nil) throws -> [Measurement] {
    return try Measurement.makeQuery(connection).all()
  }
  
  func findMeasurement(_ connection: Connection? = nil,
                       byId: Identifier) throws -> Measurement? {
    return try Measurement.makeQuery(connection).find(byId)
  }
  
  func deleteMeasurement(_ connection: Connection? = nil,
                         measurement: Measurement) throws {
    try Measurement.makeQuery(connection).delete(measurement)
  }
  
}

// MARK: Note Extension

extension ModelManager {
  
  func createNote(_ connection: Connection? = nil,
                  text: String,
                  survey: Survey) throws -> Note {
    
    let surveyId = try survey.assertExists()
    
    guard let organizationId = try findOrganization(connection, bySurvey: survey)?.id,
      let _ = try UserOrganizationRole.makeQuery(connection)
        .filter(UserOrganizationRole.Keys.organizationId, .equals, organizationId)
        .filter(UserOrganizationRole.Keys.userId, .equals, survey.userId)
        .first() else {
          throw Abort(.expectationFailed)
    }
    
    let note = Note(text: text, surveyId: surveyId)
    try Note.makeQuery(connection).save(note)
    
    return note
    
  }
  
  func findNote(_ connection: Connection? = nil,
                byId: Identifier) throws -> Note? {
    return try Note.makeQuery(connection).find(byId)
  }
  
  func updateNote(_ connection: Connection? = nil,
                  note: Note,
                  newText: String) throws -> Note {
    
    try note.assertExists()
    
    note.text = newText
    try Note.makeQuery(connection).save(note)
    
    return note
    
  }
  
  func deleteNote(_ connection: Connection? = nil,
                  note: Note) throws {
    try note.assertExists()
    try Note.makeQuery(connection).delete(note)
  }
  
}

// MARK: Image Extension

extension ModelManager {
  
  func createImage(_ connection: Connection? = nil,
                   bytes: Bytes,
                   description: String? = nil,
                   imageType: ImageType,
                   survey: Survey) throws -> Image {

    let imageTypeId = try imageType.assertExists()
    let surveyId = try survey.assertExists()
    
    guard let organizationId = try findOrganization(connection, bySurvey: survey)?.id,
      let _ = try UserOrganizationRole.makeQuery(connection)
        .filter(UserOrganizationRole.Keys.organizationId, .equals, organizationId)
        .filter(UserOrganizationRole.Keys.userId, .equals, survey.userId)
        .first() else {
          throw Abort(.expectationFailed)
    }
    
    let code = String(randomUpperCaseAlphaNumericLength: Image.CODE_LENGTH)
    let image = Image(
      image: Blob(bytes: bytes),
      code: code,
      description: description,
      imageTypeId: imageTypeId,
      surveyId: surveyId)
    try Image.makeQuery(connection).save(image)
    
    return image
    
  }
  
  func getImageType(_ connection: Connection? = nil,
                    name: ImageType.Name) throws -> ImageType {
    
    guard let imageType = try ImageType.makeQuery(connection)
      .filter(ImageType.Keys.name, .equals, name.rawValue)
      .first() else {
        throw Abort(.expectationFailed)
    }
    
    return imageType
    
  }
  
  func createImage(_ connection: Connection? = nil,
                   bytes: Bytes,
                   description: String? = nil,
                   imageType imageTypeName: ImageType.Name,
                   survey: Survey) throws -> Image {
  
    return try createImage(
      connection,
      bytes: bytes,
      description: description,
      imageType: try getImageType(name: imageTypeName),
      survey: survey)
    
  }
  
  func findImage(_ connection: Connection? = nil,
                 byId: Int) throws -> Image? {
    return try Image.makeQuery(connection).find(byId)
  }
  
  func findImage(_ connection: Connection? = nil,
                 byCode: String) throws -> Image? {
    return try Image.makeQuery(connection)
      .filter(Image.Keys.code, .equals, byCode.uppercased())
      .first()
  }
  
  func updateImage(_ connection: Connection? = nil,
                   image: Image,
                   newBytes: Bytes? = nil,
                   newDescription: String? = nil,
                   newImageType: ImageType? = nil) throws -> Image? {
    
    try image.assertExists()
    
    if let bytes = newBytes {
      image.image = Blob(bytes: bytes)
    }
  
    if let description = newDescription {
      image.description = description
    }
    
    if let imageTypeId = try newImageType?.assertExists() {
      image.imageTypeId = imageTypeId
    }
    
    try Image.makeQuery(connection).save(image)
    
    return image
    
  }
  
  func deleteImage(_ connection: Connection? = nil,
                   image: Image) throws {
    try image.assertExists()
    try Image.makeQuery(connection).delete(image)
  }
  
}

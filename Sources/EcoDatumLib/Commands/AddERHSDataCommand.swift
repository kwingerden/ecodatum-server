import Console
import FluentProvider
import Foundation
import Random
import Vapor

public final class AddERHSDataCommand: Command {

  public let id = "add-erhs-data"

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

    let laura = try createOrGetUser(
      User(
        fullName: "Laura Branch",
        email: "lbranch@smjuhsd.org"))

    let rebecca = try createOrGetUser(
      User(
        fullName: "Rebecca Wingerden",
        email: "rwingerden@smjuhsd.org"))

    let apBio = try createOrGetOrganization(
      Organization(name: "AP Biology"))
    let honBio = try createOrGetOrganization(
      Organization(name: "Honors Biology"))

    let apes = try createOrGetOrganization(
      Organization(name: "APES"))

    try associateOrganizationUser(
      user: rebecca,
      organization: apBio,
      role: Role.Name.ADMINISTRATOR.rawValue)
    try associateOrganizationUser(
      user: rebecca,
      organization: honBio,
      role: Role.Name.ADMINISTRATOR.rawValue)
    try associateOrganizationUser(
      user: laura,
      organization: apes,
      role: Role.Name.ADMINISTRATOR.rawValue)

    let erhsSite1 = Site(
      name: "ERHS Site #1",
      latitude: 34.883979,
      longitude: -120.422244)
    let erhsSite2 = Site(
      name: "ERHS Site #2",
      latitude: 34.883953,
      longitude: -120.421738)
    let erhsSite3 = Site(
      name: "ERHS Site #3",
      latitude: 34.883889,
      longitude: -120.421591)
    let erhsSite4 = Site(
      name: "ERHS Site #4",
      latitude: 34.883803,
      longitude: -120.420495)
    let erhsSite5 = Site(
      name: "ERHS Site #5",
      latitude: 34.883765,
      longitude: -120.420140)
    let erhsSite6 = Site(
      name: "ERHS Site #6",
      latitude: 34.884050,
      longitude: -120.420145)

    let _ = try createOrGetSite(erhsSite1, rebecca, apBio)
    let _ = try createOrGetSite(erhsSite2, rebecca, apBio)
    let _ = try createOrGetSite(erhsSite3, rebecca, apBio)
    let _ = try createOrGetSite(erhsSite4, rebecca, apBio)
    let _ = try createOrGetSite(erhsSite5, rebecca, apBio)
    let _ = try createOrGetSite(erhsSite6, rebecca, apBio)

    let _ = try createOrGetSite(erhsSite1, rebecca, honBio)
    let _ = try createOrGetSite(erhsSite2, rebecca, honBio)
    let _ = try createOrGetSite(erhsSite3, rebecca, honBio)
    let _ = try createOrGetSite(erhsSite4, rebecca, honBio)
    let _ = try createOrGetSite(erhsSite5, rebecca, honBio)
    let _ = try createOrGetSite(erhsSite6, rebecca, honBio)

    let _ = try createOrGetSite(erhsSite1, laura, apes)
    let _ = try createOrGetSite(erhsSite2, laura, apes)
    let _ = try createOrGetSite(erhsSite3, laura, apes)
    let _ = try createOrGetSite(erhsSite4, laura, apes)
    let _ = try createOrGetSite(erhsSite5, laura, apes)
    let _ = try createOrGetSite(erhsSite6, laura, apes)

  }

  private func createOrGetUser(_ user: User) throws -> User {

    let existingUser = try User.makeQuery()
      .filter(User.Keys.email, .equals, user.email)
      .first()
    if let existingUser = existingUser {

      console.output(
        "Existing User => id: \(user.id!), email: \(existingUser.email)",
        style: .warning,
        newLine: true)

      return existingUser

    } else {

      let (password, hash) = try randomHashedPassword(8)
      user.id = nil
      user.password = hash
      try user.save()

      console.output(
        "New User => id: \(user.id!), email: \(user.email), password: \(password)",
        style: .error,
        newLine: true)

      return user

    }

  }

  private func createOrGetOrganization(_ organization: Organization) throws -> Organization {

    let existingOrganization = try Organization.makeQuery()
      .filter(Organization.Keys.name, .equals, organization.name)
      .first()
    if let existingOrganization = existingOrganization {

      console.output(
        "Existing Organization => " +
          "id: \(existingOrganization.id!), " +
          "code: \(existingOrganization.code!), " +
          "name: \(existingOrganization.name)",
        style: .warning,
        newLine: true)

      return existingOrganization

    } else {

      let organizationCode = randomOrganizationCode(Organization.CODE_LENGTH)
      organization.id = nil
      organization.code = organizationCode
      try organization.save()

      console.output(
        "New Organization => " +
          "id: \(organization.id!), " +
          "code: \(organization.code!), " +
          "name: \(organization.name)",
        style: .error,
        newLine: true)

      return organization

    }

  }

  private func associateOrganizationUser(
    user: User,
    organization: Organization,
    role: String) throws {

    let role = try Role.makeQuery()
      .filter(Role.Keys.name,
        .equals,
        role)
      .first()!

    let userOrganizationRole = try UserOrganizationRole.makeQuery()
      .filter(UserOrganizationRole.Keys.organizationId,
        .equals,
        organization.id!)
      .filter(UserOrganizationRole.Keys.roleId,
        .equals,
        role.id!)
      .filter(UserOrganizationRole.Keys.userId,
        .equals,
        user.id!)
      .first()
    if let _ = userOrganizationRole {

      console.output(
        "Existing User Organization Role => " +
          "email: \(user.email), " +
          "organization name: \(organization.name), " +
          "organization role: \(role.name)",
        style: .warning,
        newLine: true)

    } else {

      try UserOrganizationRole(
        userId: user.id!,
        organizationId: organization.id!,
        roleId: role.id!)
        .save()

      console.output(
        "New User Organization Role => " +
          "email: \(user.email), " +
          "organization name: \(organization.name), " +
          "organization role: \(role.name)",
        style: .error,
        newLine: true)

    }

  }


  private func createOrGetSite(_ site: Site, _ user: User, _ organization: Organization) throws -> Site {

    let existingSite = try Site.makeQuery()
      .filter(Site.Keys.name, .equals, site.name)
      .filter(Site.Keys.userId, .equals, user.id!)
      .filter(Site.Keys.organizationId, .equals, organization.id!)
      .first()
    if let existingSite = existingSite {

      console.output(
        "Existing Site => " +
          "id: \(existingSite.id!), " +
          "name: \(existingSite.name), " +
          "organization: \(organization.name), " +
          "user: \(user.email)",
        style: .warning,
        newLine: true)

      return existingSite

    } else {

      site.id = nil
      site.userId = user.id
      site.organizationId = organization.id
      try site.save()

      console.output(
        "New Site => " +
          "id: \(site.id!), " +
          "name: \(site.name), " +
          "organization: \(organization.name), " +
          "user: \(user.email)",
        style: .error,
        newLine: true)

      return site

    }

  }

  func randomString(_ length: Int) -> String {
    let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
    var string = ""
    for _ in 0..<length {
      let random: Int = Int(arc4random_uniform(UInt32(characters.count)))
      string += String(characters[characters.index(characters.startIndex, offsetBy: random)])
    }
    return string
  }

  func randomHashedPassword(_ length: Int) throws -> (password: String, hash: String) {
    let passwordString = randomString(length)
    let passwordHash = try hash.make(passwordString.makeBytes()).makeString()
    return (password: passwordString, hash: passwordHash)
  }

  func randomOrganizationCode(_ length: Int) -> String {
    let organizationCode = randomString(length)
    return organizationCode.uppercased()
  }

}

extension AddERHSDataCommand: ConfigInitializable {

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



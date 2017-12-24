import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class FullModelTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let modelManager = try ModelManager(drop)
    
    let rootUser = try modelManager.getRootUser()
    
    let user1 = try createTestUser(modelManager)
    let user2 = try createTestUser(modelManager)
    let user3 = try createTestUser(modelManager)
    let user4 = try createTestUser(modelManager)
  
    let organization1 = try createTestOrganization(modelManager, user1)
    let organization2 = try createTestOrganization(modelManager, user2)
    
    let user3Organization1Member = try modelManager.addUserToOrganization(
      user: user3,
      organization: organization1,
      role: .MEMBER)
    
    let user4Organization2Member = try modelManager.addUserToOrganization(
      user: user4,
      organization: organization2,
      role: .MEMBER)

    let site1Organization1 = try createTestSite(modelManager, user1, organization1)
    let site2Organization2 = try createTestSite(modelManager, user2, organization2)
    
    let site1User1Survey1 = try modelManager.createSurvey(
      date: Date(),
      site: site1Organization1,
      user: user1)
    
    do {
      try modelManager.createSurvey(
        date: Date(),
        site: site2Organization2,
        user: user1)
      XCTFail()
    } catch {
      // success
    }
    
    let site1User3Survey2 = try modelManager.createSurvey(
      date: Date(),
      site: site1Organization1,
      user: user3)
    
    do {
      try modelManager.createSurvey(
        date: Date(),
        site: site1Organization1,
        user: user4)
      XCTFail()
    } catch {
      // success
    }
    
    let site1User1Survey1Measurement1 = try modelManager.createMeaurement(
      value: 4.5,
      abioticFactor: .AIR,
      measurementUnit: .TEMPERATURE_CELCIUS,
      survey: site1User1Survey1)
    
    let testUser1OrganizationRoles = try user1.userOrganizationRoles.makeQuery().all()
    XCTAssert(testUser1OrganizationRoles.count == 1)
    XCTAssert(try testUser1OrganizationRoles[0].organization.get()?.id == organization1.id)
    XCTAssert(try testUser1OrganizationRoles[0].role.get()?.name == .ADMINISTRATOR)
    
  }
  
}

// MARK: Manifest

extension FullModelTest {
  
  static let allTests = [("test", test)]
  
}






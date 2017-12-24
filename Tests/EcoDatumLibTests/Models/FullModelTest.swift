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
    
    let testUser1 = try createTestUser(modelManager)
    let testUser2 = try createTestUser(modelManager)
    let testUser3 = try createTestUser(modelManager)
    let testUser4 = try createTestUser(modelManager)
  
    let organization1 = try createTestOrganization(modelManager, testUser1)
    let organization2 = try createTestOrganization(modelManager, testUser2)
    
    let _ = try modelManager.addUserToOrganization(
      user: testUser3,
      organization: organization1,
      role: .MEMBER)
    
    let _ = try modelManager.addUserToOrganization(
      user: testUser4,
      organization: organization2,
      role: .MEMBER)

    let site1 = try createTestSite(modelManager, testUser1, organization1)
    let site2 = try createTestSite(modelManager, testUser2, organization2)
    
    let testUser1OrganizationRoles = try testUser1.userOrganizationRoles.makeQuery().all()
    XCTAssert(testUser1OrganizationRoles.count == 1)
    XCTAssert(try testUser1OrganizationRoles[0].organization.get()?.id == organization1.id)
    XCTAssert(try testUser1OrganizationRoles[0].role.get()?.name == .ADMINISTRATOR)
    
  }
  
}

// MARK: Manifest

extension FullModelTest {
  
  static let allTests = [("test", test)]
  
}






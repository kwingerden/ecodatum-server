import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1APIOrganizationTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let rootUserToken = try drop.loginRootUser()
    let rootUserOrganization1 = try drop.createOrganization(rootUserToken)
    
    let testUser1 = try drop.createTestUser(rootUserToken)
    let testUser1Token = try drop.loginTestUser(testUser1.email)
    let testUser1Organization2 = try drop.createOrganization(testUser1Token)
    
    var allOrganizations = try drop.getAllOrganizations(rootUserToken).filter {
      org in
      org.id == rootUserOrganization1.id || org.id == testUser1Organization2.id
    }
    XCTAssertTrue(allOrganizations.count == 2)
    XCTAssertTrue(allOrganizations[0] == rootUserOrganization1)
    XCTAssertTrue(allOrganizations[1] == testUser1Organization2)
    
    allOrganizations = try drop.getAllOrganizations(testUser1Token).filter {
      org in
      org.id == testUser1Organization2.id
    }
    XCTAssertTrue(allOrganizations.count == 1)
    XCTAssertTrue(allOrganizations[0] == testUser1Organization2)
    
  }
  
}



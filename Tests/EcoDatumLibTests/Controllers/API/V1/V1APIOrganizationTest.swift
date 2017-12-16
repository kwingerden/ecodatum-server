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
    let organization1 = try drop.createOrganization(1, rootUserToken)
    print(organization1)
    
  }
  
}



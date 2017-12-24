import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1APIAuthenticationTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    /*
    let rootUserToken = try drop.loginRootUser()
    
    let testUser1 = try drop.createTestUser(rootUserToken)
    let testUser1Token = try drop.loginTestUser(testUser1.email)
    try drop.assertMe(testUser1.name, testUser1Token)
    try drop.logout(testUser1Token)
    try drop.assertTokenValidity(testUser1Token, false)
    
    try drop.logout(rootUserToken)
    try drop.assertTokenValidity(rootUserToken, false)
    */
    
  }
  
}

// MARK: Manifest

extension V1APIAuthenticationTest {
  
  static let allTests = [("test", test)]
  
}


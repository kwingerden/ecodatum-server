import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1APIImageTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let rootUserToken = try drop.loginRootUser()
    let rootUserImage1 = try drop.uploadImage(rootUserToken, TEST_BASE64_ENCODED_IMAGE_1, .jpg)
    let image = try drop.getImage(rootUserToken, rootUserImage1.id)
    XCTAssertTrue(image.base64Encoded == TEST_BASE64_ENCODED_IMAGE_1)
    
  }
  
}

// MARK: Manifest

extension V1APIImageTest {
  
  static let allTests = [("test", test)]
  
}





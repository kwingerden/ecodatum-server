import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class V1APIPhotoTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    let rootUserToken = try drop.loginRootUser()
    let rootUserPhoto1 = try drop.uploadPhoto(rootUserToken, TEST_BASE64_PHOTO_1)
    let getPhoto = try drop.getPhoto(rootUserToken, rootUserPhoto1.id)
    XCTAssertTrue(getPhoto.base64 == TEST_BASE64_PHOTO_1)
    
  }
  
}




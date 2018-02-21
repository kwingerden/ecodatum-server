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
  
    try modelManager.updateUser(
      user: user2,
      newName: "new name")
    
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
    
    let site1User1Organization1Survey1 = try modelManager.createSurvey(
      date: Date(),
      site: site1Organization1,
      user: user1)
    
    do {
      let _ = try modelManager.createSurvey(
        date: Date(),
        site: site2Organization2,
        user: user1)
      XCTFail()
    } catch {
      // success
    }
    
    let site1User3Organization1Survey2 = try modelManager.createSurvey(
      date: Date(),
      site: site1Organization1,
      user: user3)
    
    do {
      let _ = try modelManager.createSurvey(
        date: Date(),
        site: site1Organization1,
        user: user4)
      XCTFail()
    } catch {
      // success
    }
    
    let site2User4Organization2Survey3 = try modelManager.createSurvey(
      date: Date(),
      site: site2Organization2,
      user: user4)
    
    let site1User1Survey1Measurement1 = try modelManager.createMeasurement(
      value: 4.5,
      abioticFactor: .AIR,
      measurementUnit: .TEMPERATURE_CELSIUS,
      survey: site1User1Organization1Survey1)
    
    let site1User1Survey1Note1 = try modelManager.createNote(
      text: LOREM_IPSUM_NOTE_1,
      survey: site1User1Organization1Survey1)
    
    let site1User1Survey1Image1 = try modelManager.createImage(
      bytes: try drop.readFileFully("\(drop.config.workDir)/Tests/EcoDatumLibTests/image1.jpg"),
      imageType: .JPEG,
      survey: site1User1Organization1Survey1)
    
    let site2User4Organization2Survey3Measurement1 = try modelManager.createMeasurement(
      value: 324.5,
      abioticFactor: .WATER,
      measurementUnit: .PH,
      survey: site2User4Organization2Survey3)
    
    let site2User4Organization2Survey3Note1 = try modelManager.createNote(
      text: LOREM_IPSUM_NOTE_1,
      survey: site2User4Organization2Survey3)
    
    let site2User4Organization2Survey3Image1 = try modelManager.createImage(
      bytes: try drop.readFileFully("\(drop.config.workDir)/Tests/EcoDatumLibTests/image2.png"),
      imageType: .PNG,
      survey: site2User4Organization2Survey3)
    
    guard let findImage = try modelManager.findImage(byCode: site2User4Organization2Survey3Image1.code) else {
      XCTFail()
      return
    }
    XCTAssert(findImage == site2User4Organization2Survey3Image1)
    XCTAssert(findImage != site1User1Survey1Image1)
    
    let testUser1OrganizationRoles = try user1.userOrganizationRoles.makeQuery().all()
    XCTAssert(testUser1OrganizationRoles.count == 1)
    XCTAssert(try testUser1OrganizationRoles[0].organization.get()?.id == organization1.id)
    XCTAssert(try testUser1OrganizationRoles[0].role.get()?.name == .ADMINISTRATOR)
    
    /*
    try modelManager.deleteImage(image: site2User4Organization2Survey3Image1)
    try modelManager.deleteMeasurement(measurement: site2User4Organization2Survey3Measurement1)
    try modelManager.deleteNote(note: site2User4Organization2Survey3Note1)
    try modelManager.deleteSurvey(survey: site2User4Organization2Survey3)
    try modelManager.deleteUser(user: user4)
    */
    
  }
  
}

// MARK: Manifest

extension FullModelTest {
  
  static let allTests = [("test", test)]
  
}






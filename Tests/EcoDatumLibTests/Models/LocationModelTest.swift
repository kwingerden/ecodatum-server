import XCTest
import Foundation
import Testing
import HTTP
@testable import Vapor
@testable import EcoDatumLib

class LocationModelTest: TestCase {
  
  let drop = try! Droplet.testable()
  
  func test() throws {
    
    /*
    let location = Location(latitude: 1.2,
                            longitude: 4.5,
                            altitude: 100.4,
                            horizontalAccuracy: 3.0,
                            verticalAccuracy: 5.0)
    try location.save()
    */
 
  }
  
}

// MARK: Manifest

extension LocationModelTest {
  
  static let allTests = [("test", test)]
  
}






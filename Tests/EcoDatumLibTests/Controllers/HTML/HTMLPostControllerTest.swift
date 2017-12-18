import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import EcoDatumLib

class HTMLPostControllerTest: TestCase {

  let drop = try! Droplet.testable()
  
  func testIndex() throws {
    let controller = HTMLHelloController(drop)
    let request = Request.makeTest(method: .get)
    try controller.index(request).makeResponse()
      .assertBody(contains: "Hello")
      .assertBody(contains: "World")
  }
  
  func testShow() throws {
    let controller = HTMLHelloController(drop)
    let request = Request.makeTest(method: .get)
    try controller.show(request, "Foo").makeResponse()
      .assertBody(contains: "Hello") 
      .assertBody(contains: "Foo")
  }
  
}

// MARK: Manifest

extension HTMLPostControllerTest {
  
  static let allTests = [
    ("testIndex", testIndex),
    ("testShow", testShow)]
  
}

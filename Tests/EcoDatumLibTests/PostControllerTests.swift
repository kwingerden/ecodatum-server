import XCTest
import Testing
import HTTP
import Sockets
@testable import Vapor
@testable import EcoDatumLib

class PostControllerTests: TestCase {

  let controller = HelloController(TestViewRenderer())
  
  func testIndex() throws {
    let req = Request.makeTest(method: .get)
    try controller.index(req).makeResponse()
      .assertBody(contains: "hello")
      .assertBody(contains: "World")
  }
  
  func testShow() throws {
    let req = Request.makeTest(method: .get)
    try controller.show(req, "Foo").makeResponse()
      .assertBody(contains: "hello") // path
      .assertBody(contains: "Foo") // custom name
  }
}

// MARK: Manifest

extension PostControllerTests {
  
  // Needed for Linux tests. Make sure to update MainLinux.swift when new tests are added.
  static let allTests = [
    ("testIndex", testIndex),
    ("testShow", testShow),
    ]
  
}

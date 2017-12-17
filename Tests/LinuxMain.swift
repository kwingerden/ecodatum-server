#if os(Linux)

import XCTest
@testable import EcoDatumLibTests

XCTMain([
  testCase(HTMLPostControllerTests.allTests)
])

#endif
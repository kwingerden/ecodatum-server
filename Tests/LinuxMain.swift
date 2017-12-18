#if os(Linux)

import XCTest
@testable import EcoDatumLibTests

XCTMain([
  testCase(V1APIAuthenticationTest.allTests),
  testCase(V1APIOrganizationTest.allTests),
  testCase(V1APIPhotoTest.allTests),
  testCase(HTMLPostControllerTest.allTests)
])

#endif
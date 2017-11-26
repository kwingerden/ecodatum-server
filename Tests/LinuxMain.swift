#if os(Linux)

import XCTest
@testable import EcoDatumLibTests

XCTMain([
    testCase(PostControllerTests.allTests),
    testCase(AuthenticationTest.allTests)
])

#endif

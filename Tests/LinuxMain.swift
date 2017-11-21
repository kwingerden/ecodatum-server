#if os(Linux)

import XCTest
@testable import EcoDatumLibTests

XCTMain([
    // AppTests
    testCase(PostControllerTests.allTests),
    testCase(RouteTests.allTests)
])

#endif

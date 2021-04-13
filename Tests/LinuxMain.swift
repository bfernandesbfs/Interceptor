import XCTest

import InterceptorTests

var tests = [XCTestCaseEntry]()
tests += InterceptorChainTest.allTests()
tests += InterceptorRequestTests.allTests()
tests += InterceptorResponseTests.allTests()
XCTMain(tests)

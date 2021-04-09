import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(InterceptorChainTest.allTests),
        testCase(InterceptorRequestTests.allTests),
        testCase(InterceptorResponseTests.allTests),
    ]
}
#endif

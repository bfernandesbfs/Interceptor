import XCTest
@testable import Interceptor

final class InterceptorRequestTests: XCTestCase {
    typealias RequestObject = InterceptorObject<RequestInterceptor>

    var sut: Interceptor!

    override func setUp() {
        sut = Interceptor()
        sut.add(AgentInterceptor()).add(TokenInterceptor()).add(DeviceInterceptor())
    }

    override func tearDown() {
        sut = nil
    }

    func testApply() throws {
        let url = try XCTUnwrap(URL(string: "http://test.com"))
        var request = URLRequest(url: url)
        try sut.applyRequest(&request)

        let header = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(header.count, 3)
        XCTAssertEqual(header["UserAgent"], "version:0.0.1,test:Agent,device:iPhone")
        XCTAssertEqual(header["Authorization"], "Bearer HASH-test-1234")
        XCTAssertEqual(header["Device"], "id-1234")
    }

    func testApplyWhenEmpty() throws {
        sut.clean()
        let url = try XCTUnwrap(URL(string: "http://test.com"))
        var request = URLRequest(url: url)
        try sut.applyRequest(&request)
        XCTAssertNil(request.allHTTPHeaderFields)
    }

    static var allTests = [
        ("testApply", testApply),
        ("testApplyWhenEmpty", testApplyWhenEmpty),
    ]
}

struct AgentInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws {
        request.addValue("version:0.0.1,test:Agent,device:iPhone", forHTTPHeaderField: "UserAgent")
    }
}

struct TokenInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws {
        request.addValue("Bearer HASH-test-1234", forHTTPHeaderField: "Authorization")
    }
}

struct DeviceInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws {
        request.addValue("id-1234", forHTTPHeaderField: "Device")
    }
}

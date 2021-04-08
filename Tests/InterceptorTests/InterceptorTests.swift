import XCTest
@testable import Interceptor

final class InterceptorTests: XCTestCase {

    var sut: Interceptor!

    override func setUp() {
        sut = Interceptor()
        sut.add(AgentInterceptor()).add(TokenInterceptor()).add(DeviceInterceptor())
    }

    override func tearDown() {
        sut = nil
    }

    func testAdd() throws {
        XCTAssertNotNil(sut.current)
    }

    func testClean() throws {
        sut.clean()
        XCTAssertNil(sut.current)

        let url = try XCTUnwrap(URL(string: "http://test.com"))
        var request = URLRequest(url: url)
        try sut.apply(&request)

        XCTAssertNil(request.allHTTPHeaderFields)
    }

    func testChainCheck() throws {
        sut.clean()
        XCTAssertNil(sut.current)

        let agent = AgentInterceptor()
        sut.add(agent)
        XCTAssertNotNil(sut.current)

        let outAgent = try XCTUnwrap(sut.current as? InterceptorObject)
        XCTAssertNil(outAgent.nextResponder)
        XCTAssertTrue(outAgent.wrapperValue is AgentInterceptor)

        let token = TokenInterceptor()
        sut.add(token)
        XCTAssertNotNil(sut.current?.nextResponder)

        let outToken = try XCTUnwrap(sut.current as? InterceptorObject)
        XCTAssertNotNil(outToken.nextResponder)
        XCTAssertTrue(outToken.wrapperValue is TokenInterceptor)

        let outNext = try XCTUnwrap(sut.current?.nextResponder as? InterceptorObject)
        XCTAssertNil(outNext.nextResponder)
        XCTAssertTrue(outNext.wrapperValue is AgentInterceptor)
    }

    func testApply() throws {
        let url = try XCTUnwrap(URL(string: "http://test.com"))
        var request = URLRequest(url: url)
        try sut.apply(&request)

        let header = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(header.count, 3)
        XCTAssertEqual(header["UserAgent"], "version:0.0.1,test:Agent,device:iPhone")
        XCTAssertEqual(header["Authorization"], "Bearer HASH-test-1234")
        XCTAssertEqual(header["Device"], "id-1234")
    }

    static var allTests = [
        ("testAdd", testAdd),
        ("testChainCheck", testChainCheck),
        ("testApply", testApply),
        ("testClean", testClean),
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

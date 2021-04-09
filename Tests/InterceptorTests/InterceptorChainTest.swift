import XCTest
@testable import Interceptor

final class InterceptorChainTest: XCTestCase {
    typealias RequestObject = InterceptorObject<RequestInterceptor>

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
    }

    func testChainCheck() throws {
        sut.clean()
        XCTAssertNil(sut.current)

        let agent = AgentInterceptor()
        sut.add(agent)
        XCTAssertNotNil(sut.current)

        let outAgent = try XCTUnwrap(sut.current as? RequestObject)
        XCTAssertNil(outAgent.nextResponder)
        XCTAssertTrue(outAgent.wrapperValue is AgentInterceptor)

        let token = TokenInterceptor()
        sut.add(token)
        XCTAssertNotNil(sut.current?.nextResponder)

        let outToken = try XCTUnwrap(sut.current as? RequestObject)
        XCTAssertNotNil(outToken.nextResponder)
        XCTAssertTrue(outToken.wrapperValue is TokenInterceptor)

        let outNext = try XCTUnwrap(sut.current?.nextResponder as? RequestObject)
        XCTAssertNil(outNext.nextResponder)
        XCTAssertTrue(outNext.wrapperValue is AgentInterceptor)
    }

    static var allTests = [
        ("testAdd", testAdd),
        ("testClean", testClean),
        ("testChainCheck", testChainCheck),
    ]
}

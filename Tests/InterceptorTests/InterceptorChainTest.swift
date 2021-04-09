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

    func testChainMixCheck() throws {
        let expectation = XCTestExpectation(description: #function)
        let outBlock = BlockInterceptorSpy()
        sut.add(outBlock)

        let session = URLSessionStub()
        let url = try XCTUnwrap(URL(string: "http://test.com"))
        var request = URLRequest(url: url)
        try sut.applyRequest(&request)

        var blockCount = 0
        let task = session.dataTask(with: url, completionHandler: sut.applyResponse { _, _, _ in
            blockCount += 1
            expectation.fulfill()
        })
        task.resume()

        wait(for: [expectation], timeout: 1.0)

        let header = try XCTUnwrap(request.allHTTPHeaderFields)
        XCTAssertEqual(header.count, 3)
        XCTAssertEqual(header["UserAgent"], "version:0.0.1,test:Agent,device:iPhone")
        XCTAssertEqual(header["Authorization"], "Bearer HASH-test-1234")
        XCTAssertEqual(header["Device"], "id-1234")
        XCTAssertEqual(blockCount, 1)
        XCTAssertEqual(outBlock.interceptCount, 1)
    }

    static var allTests = [
        ("testAdd", testAdd),
        ("testClean", testClean),
        ("testChainCheck", testChainCheck),
        ("testChainMixCheck", testChainMixCheck)
    ]
}

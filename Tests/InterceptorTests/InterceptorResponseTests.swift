import XCTest
@testable import Interceptor

final class InterceptorResponseTests: XCTestCase {
    typealias ReaponseObject = InterceptorObject<ResponseInterceptor>

    var sut: Interceptor!

    override func setUp() {
        sut = Interceptor()
    }

    override func tearDown() {
        sut = nil
    }

    func testApply() throws {
        let expectation = XCTestExpectation(description: #function)
        let outBlock = BlockInterceptorSpy()
        sut.add(outBlock).add(outBlock)

        let session = URLSessionStub()
        let url = try XCTUnwrap(URL(string: "http://test.com"))

        var blockCount = 0
        let task = session.dataTask(with: url, completionHandler: sut.applyResponse { _, _, _ in
            blockCount += 1
            expectation.fulfill()
        })
        task.resume()

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(blockCount, 1)
        XCTAssertEqual(outBlock.interceptCount, 2)
    }

    func testEmptyChain() throws {
        let expectation = XCTestExpectation(description: #function)
        sut.clean()

        let session = URLSessionStub()
        let url = try XCTUnwrap(URL(string: "http://test.com"))

        var blockCount = 0
        let task = session.dataTask(with: url, completionHandler: sut.applyResponse { _, _, _ in
            blockCount += 1
            expectation.fulfill()
        })
        task.resume()

        wait(for: [expectation], timeout: 1.0)

        XCTAssertEqual(blockCount, 1)
    }

    func testChainCheck() throws {
        sut.clean()
        XCTAssertNil(sut.current)

        let block = BlockInterceptorSpy()
        sut.add(block)
        XCTAssertNotNil(sut.current)

        let outBlock = try XCTUnwrap(sut.current as? ReaponseObject)
        XCTAssertNil(outBlock.nextResponder)
        XCTAssertTrue(outBlock.wrapperValue is BlockInterceptorSpy)

        let dummy = DummyInterceptor()
        sut.add(dummy)
        XCTAssertNotNil(sut.current?.nextResponder)

        let outDummy = try XCTUnwrap(sut.current as? ReaponseObject)
        XCTAssertNotNil(outDummy.nextResponder)
        XCTAssertTrue(outDummy.wrapperValue is DummyInterceptor)

        let outNext = try XCTUnwrap(sut.current?.nextResponder as? ReaponseObject)
        XCTAssertNil(outNext.nextResponder)
        XCTAssertTrue(outNext.wrapperValue is BlockInterceptorSpy)
    }

    static var allTests = [
        ("testApply", testApply),
        ("testEmptyChain", testEmptyChain),
        ("testChainCheck", testChainCheck)
    ]
}

class BlockInterceptorSpy: ResponseInterceptor {

    var interceptCount: Int = 0
    func intercept(_ data: Data?, response: URLResponse?, error: Error?) {
        interceptCount += 1
    }

}

struct DummyInterceptor: ResponseInterceptor {

    func intercept(_ data: Data?, response: URLResponse?, error: Error?) {}
}

final class URLSessionStub: URLSession {

    var shouldReturnError: Bool = false
    var dataResponse: Data = Data()
    var urlResponse: HTTPURLResponse = HTTPURLResponse()
    var statusCode: Int = 200
    var error: Error = NSError(domain: String(), code: 404, userInfo: nil)

    override init() {}

    override func dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        if !shouldReturnError {
            urlResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            completionHandler(dataResponse, urlResponse, nil)
            let task = URLSessionDataTaskFake(data: dataResponse, urlResponse: urlResponse, error: error)

            task.completionHandler = completionHandler
            return task
        }

        let task = URLSessionDataTaskFake(data: nil, urlResponse: nil, error: error)
        task.completionHandler = completionHandler
        return task
    }

}

final class URLSessionDataTaskFake: URLSessionDataTask {
    private let data: Data?
    private let urlResponse: URLResponse?
    private let _error: Error?

    override var error: Error? {
        return _error
    }

    var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?

    init(data: Data?, urlResponse: URLResponse?, error: Error?) {
        self.data = data
        self.urlResponse = urlResponse
        self._error = error
    }

    override func resume() {
        DispatchQueue.main.async {
            self.completionHandler?(self.data, self.urlResponse, self.error)
        }
    }

}

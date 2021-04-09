import XCTest
@testable import Interceptor

final class InterceptorResponseTests: XCTestCase {
    typealias RequestObject = InterceptorObject<ResponseInterceptor>

    var sut: Interceptor!

    override func setUp() {
        sut = Interceptor()
    }

    override func tearDown() {
        sut = nil
    }

    func testApply() throws {
        let expectation = XCTestExpectation(description: #function)
        sut.add(AuthenticationInterceptor()).add(BlockInterceptor())

        let session = URLSessionStub()
        let url = try XCTUnwrap(URL(string: "http://test.com"))

        let task = session.dataTask(with: url, completionHandler: sut.applyResponse { data, response, error in
            expectation.fulfill()
        })
        task.resume()

        wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testApply", testApply),
    ]
}

struct AuthenticationInterceptor: ResponseInterceptor {

    func intercept(_ data: Data?, response: URLResponse?, error: Error?) {

    }

}

struct BlockInterceptor: ResponseInterceptor {

    func intercept(_ data: Data?, response: URLResponse?, error: Error?) {

    }

}

final class URLSessionStub: URLSession {

    var shouldReturnError: Bool = false
    var dataResponse: Data = Data()
    var urlResponse: HTTPURLResponse = HTTPURLResponse()
    var statusCode: Int = 200
    var error: Error = NSError(domain: String(), code: 404, userInfo: nil)

    override init() {}

    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        if !shouldReturnError {
            urlResponse = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
            completionHandler(dataResponse, urlResponse , nil)
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

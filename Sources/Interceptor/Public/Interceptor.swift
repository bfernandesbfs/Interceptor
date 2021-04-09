import Foundation
import Responder

public typealias SessionComppletion = (Data?, URLResponse?, Error?) -> Void

public class Interceptor {

    private(set) internal var current: Responder?

    public init() {
        current = nil
    }

    // MARK: - Public Methods

    @discardableResult
    public func add(_ interceptor: RequestInterceptor) -> Self {
        current = InterceptorObject(nextResponder: current, wrapperValue: interceptor)
        return self
    }

    @discardableResult
    public func add(_ interceptor: ResponseInterceptor) -> Self {
        current = InterceptorObject(nextResponder: current, wrapperValue: interceptor)
        return self
    }

    public func applyRequest(_ request: inout URLRequest) throws {
        try self.test { (interceptor: InterceptorObject<RequestInterceptor>) in
            try interceptor.wrapperValue.intercept(&request)
        }
    }
    
    public func applyResponse(completionHandler: @escaping SessionComppletion) -> SessionComppletion  {
        return { data, response, error in
            self.test { (interceptor: InterceptorObject<ResponseInterceptor>) in
                interceptor.wrapperValue.intercept(data, response: response, error: error)
            }
            completionHandler(data, response, error)
        }
    }

    // MARK: - Internal Methods

    internal func clean() {
        current = nil
    }

    // MARK: - Private Methods

    private func test<Object>(execute: (Object) throws -> Void) rethrows {
        var last = current
        repeat {
            if let interceptor = last as? Object {
                try execute(interceptor)
            }
            last = last?.nextResponder

        } while last != nil && last is Object
    }

}

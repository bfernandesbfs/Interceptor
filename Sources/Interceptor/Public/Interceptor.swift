import Foundation
import Responder

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

    public func apply(_ request: inout URLRequest) throws {
        var last = current
        repeat {
            if let interceptor = last as? InterceptorObject {
                try interceptor.wrapperValue.intercept(&request)
            }
            last = last?.nextResponder

        } while last != nil
    }

    // MARK: - Internal Methods

    internal func clean() {
        current = nil
    }

}

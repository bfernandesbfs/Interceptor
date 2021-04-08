import Foundation

public protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest) throws
}

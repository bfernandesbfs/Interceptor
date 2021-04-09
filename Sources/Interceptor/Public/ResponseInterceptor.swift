import Foundation

public protocol ResponseInterceptor {
    func intercept(_ data: Data?, response: URLResponse?, error: Error?)
}

import Foundation
import Responder

internal struct InterceptorObject: Responder {
    var nextResponder: Responder?
    let wrapperValue: RequestInterceptor
}

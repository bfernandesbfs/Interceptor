import Foundation
import Responder

internal struct InterceptorObject<Type>: Responder {
    var nextResponder: Responder?
    let wrapperValue: Type
}

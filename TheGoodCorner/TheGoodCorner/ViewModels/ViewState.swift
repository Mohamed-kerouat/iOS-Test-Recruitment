import Foundation

enum ViewState<Value> {
    case loading
    case loaded(Value)
    case empty
    case error(message: String)
}

extension ViewState: Equatable where Value: Equatable {
    static func == (lhs: ViewState<Value>, rhs: ViewState<Value>) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading), (.empty, .empty):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

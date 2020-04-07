import Foundation

public enum APIError: Swift.Error, Equatable {
    case failedToBuildURLRequest
    case apiError(Swift.Error?)
    case describedError(String)
    case noDataError
    case decodingError(Swift.Error?)

    public static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToBuildURLRequest, .failedToBuildURLRequest),
             (.apiError, .apiError),
             (.noDataError, .noDataError),
             (.decodingError, .decodingError):
            return true
        case (.describedError(let lhsError), .describedError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

extension APIError: CustomStringConvertible {
    private var genericError: String { "Something went wrong" }
    public var description: String {
        switch self {
        case .failedToBuildURLRequest:
            return "Failed to build request."
        case .apiError(let error):
            return (error as NSError?)?.localizedDescription ?? genericError
        case .describedError(let error):
            return error
        case .noDataError:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode data from server."
        }
    }
}

import Foundation

enum APIError: Swift.Error, Equatable {
    case failedToBuildURLRequest
    case apiError(Swift.Error?)
    case flickAPIError(FlickrError)
    case noDataError
    case decodingError(Swift.Error?)

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.failedToBuildURLRequest, .failedToBuildURLRequest),
             (.apiError, .apiError),
             (.noDataError, .noDataError),
             (.decodingError, .decodingError):
            return true
        case (.flickAPIError(let lhsError), .flickAPIError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

extension APIError: CustomStringConvertible {
    private var genericError: String { "Something went wrong" }
    var description: String {
        switch self {
        case .failedToBuildURLRequest:
            return "Failed to build request."
        case .apiError(let error):
            return (error as NSError?)?.localizedDescription ?? genericError
        case .flickAPIError(let error):
            return error.message
        case .noDataError:
            return "No data received from the server."
        case .decodingError:
            return "Failed to decode data from server."
        }
    }
}

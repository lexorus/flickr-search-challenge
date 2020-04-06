import Foundation

struct FlickrResponse<Model: Decodable>: Decodable {
    let status: Status
    let result: Result<Model, FlickrError>

    private enum CodingKeys: String, CodingKey {
        case status = "stat"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decode(Status.self, forKey: .status)
        switch status {
        case .success: result = .success(try Model(from: decoder))
        case .failure: result = .failure(try FlickrError(from: decoder))
        }
    }

    init(result: Result<Model, FlickrError>, status: Status) {
        self.result = result
        self.status = status
    }

    enum Status: String, Decodable, Equatable {
        case success = "ok"
        case failure = "fail"
    }
}

struct FlickrError: Swift.Error, Decodable, Equatable {
    let code: Int
    let message: String
}

extension FlickrResponse: Equatable where Model: Equatable {
    static func == (lhs: FlickrResponse<Model>, rhs: FlickrResponse<Model>) -> Bool {
        return lhs.result == rhs.result && lhs.status == rhs.status
    }
}

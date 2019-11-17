import Foundation
@testable import FlickrSearchChallenge

final class MockRequestBuilder: RequestBuilderType {
    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    var urlRequestStub: URLRequest?
    var urlRequestFuncCheck = FunckCheck<FlickrRequest>()
    func urlRequest(from request: FlickrRequest) -> URLRequest? {
        urlRequestFuncCheck.call(request)
        return urlRequestStub
    }
}

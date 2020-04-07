import Foundation
import PhotosAPIMocks
@testable import PhotosAPI

final class MockRequestBuilder: RequestBuilderType {
    let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    var urlRequestStub: URLRequest?
    var urlRequestFuncCheck = FuncCheck<FlickrRequest>()
    func urlRequest(from request: FlickrRequest) -> URLRequest? {
        urlRequestFuncCheck.call(request)
        return urlRequestStub
    }
}

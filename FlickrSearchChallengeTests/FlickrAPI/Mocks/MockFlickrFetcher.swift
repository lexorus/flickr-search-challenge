import Foundation
@testable import FlickrSearch

final class MockFlickrFetcher<M: Decodable>: FlickrFetcherType {
    var performCancellableStub = MockCancellable()
    var performFuncCheck = FuncCheck<(FlickrRequest, (Result<M, APIError>) -> Void)>()
    func perform<T: Decodable>(_ request: FlickrRequest, callback: @escaping (Result<T, APIError>) -> Void) -> Cancellable {
        performFuncCheck.call((request, callback as! (Result<M, APIError>) -> Void))

        return performCancellableStub
    }

    var getDataFuncCheck = FuncCheck<(String, (Result<Data, APIError>) -> Void)>()
    func getData(from stringURL: String, callback: @escaping (Result<Data, APIError>) -> Void) {
        getDataFuncCheck.call((stringURL, callback))
    }
}

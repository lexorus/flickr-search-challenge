import Foundation

protocol URLSessionType {
    @discardableResult
    func perform(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancellable
}

extension URLSession: URLSessionType {
    @discardableResult
    func perform(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> Cancellable {
        let task = dataTask(with: request, completionHandler: completionHandler)
        task.resume()

        return task
    }
}

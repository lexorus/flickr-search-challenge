import Foundation

extension URL {
    static func mocked(string: String = "http://google.com") -> URL {
        return URL(string: string)!
    }
}

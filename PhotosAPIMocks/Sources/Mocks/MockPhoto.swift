import Foundation
@testable import PhotosAPI

extension Photo {
    public static func mocked(id: String = "id",
                              title: String = "title",
                              secret: String = "secret",
                              server: String = "server",
                              farm: Int = 0) -> Photo {
        return .init(id: id,
                     title: title,
                     secret: secret,
                     server: server,
                     farm: farm)
    }
}

import Foundation

public struct Photo: Codable, Equatable {
    public let id: String
    public let title: String
    public let secret: String
    public let server: String
    public let farm: Int

    public init(id: String, title: String, secret: String, server: String, farm: Int) {
        self.id = id
        self.title = title
        self.secret = secret
        self.server = server
        self.farm = farm
    }
}

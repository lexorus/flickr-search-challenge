import Foundation

struct Photo: Codable, Equatable {
    let id: String
    let title: String
    let secret: String
    let server: String
    let farm: Int
}

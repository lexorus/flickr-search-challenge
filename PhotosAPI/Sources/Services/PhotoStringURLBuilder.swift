import Foundation

final class PhotoStringURLBuilder {
    func urlString(for photo: Photo) -> String {
        return urlString(farm: "\(photo.farm)",
                         server: photo.server,
                         id: photo.id,
                         secret: photo.secret)
    }

    func urlString(farm: String, server: String, id: String, secret: String) -> String {
        return "https://farm\(farm).static.flickr.com/\(server)/\(id)_\(secret).jpg"
    }
}

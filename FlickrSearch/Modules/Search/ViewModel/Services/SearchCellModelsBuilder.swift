import UIKit

final class SearchCellModelsBuilder {
    typealias ImageDataProvider = ((Photo), @escaping (Result<Data, APIError>) -> Void) -> Void

    func photoCellModel(for photo: Photo, imageProvider: ImageDataProvider?) -> PhotoCell.Model {
        // Noticed that Flickr can return multiple photos with the same id in one response
        // Which will break the animated collection logic
        let id = UUID().uuidString // photo.id
        let imageClosure: (@escaping (UIImage) -> Void) -> Void = { closure in
            imageProvider?(photo) { (result) in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        debugPrint("Failed to create image from data")
                        return
                    }
                    closure(image)
                case .failure(let error):
                    debugPrint("Failed to get image with \(error)")
                }
            }
        }

        return .init(id: id, imageClosure: imageClosure)
    }
}

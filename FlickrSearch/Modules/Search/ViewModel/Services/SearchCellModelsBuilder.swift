import UIKit
import RxSwift
import PhotosAPI

final class SearchCellModelsBuilder {
    private let imageDataProvider: ImageDataProvider
    private let disposeBag = DisposeBag()

    init(imageDataProvider: ImageDataProvider) {
        self.imageDataProvider = imageDataProvider
    }

    func photoCellModel(for photo: Photo) -> PhotoCell.Model {
        let id = photo.id
        let imageClosure: (@escaping (UIImage) -> Void) -> Void = { [weak self] closure in
            guard let self = self else { return }
            self.imageDataProvider.getImageData(for: photo)
                .subscribe(onSuccess: { data in
                    guard let image = UIImage(data: data) else {
                        debugPrint("Failed to create image from data")
                        return
                    }
                    closure(image)
                }, onError: { error in
                    debugPrint("Failed to get image with \(error)")
                }).disposed(by: self.disposeBag)
        }

        return .init(id: id, imageClosure: imageClosure)
    }
}

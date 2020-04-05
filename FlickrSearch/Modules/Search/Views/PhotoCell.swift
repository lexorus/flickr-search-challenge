import UIKit
import RxDataSources

final class PhotoCell: UICollectionViewCell, IdentifiableType {
    static let id = "PhotoCell"

    @IBOutlet private var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        resetImage()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        resetImage()
    }

    func configure(with model: Model) {
        model.imageClosure { image in
            DispatchQueue.main.async { [weak self] in
                self?.set(image: image)
            }
        }
    }

    private func set(image: UIImage) {
        backgroundColor = .clear
        imageView.image = image
    }

    private func resetImage() {
        backgroundColor = .lightGray
        imageView.image = nil
    }

    struct Model: Equatable, RxDataSources.IdentifiableType {
        let id: String
        let imageClosure: (@escaping (UIImage) -> Void) -> Void

        var identity: String { id }

        static func == (lhs: Model, rhs: Model) -> Bool {
            return lhs.id == rhs.id
        }
    }
}

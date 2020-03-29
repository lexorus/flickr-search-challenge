import UIKit

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

    struct Model {
        let imageClosure: (@escaping (UIImage) -> Void) -> Void
    }
}

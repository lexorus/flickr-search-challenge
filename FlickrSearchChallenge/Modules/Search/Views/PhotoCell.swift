import UIKit

final class PhotoCell: UICollectionViewCell, IdentifiableType {
    static let id = "PhotoCell"

    @IBOutlet private weak var imageView: UIImageView!

    #warning("To Update: Will need to define the config and update this cell.")
    func configure() {
        self.backgroundColor = .red
    }
}

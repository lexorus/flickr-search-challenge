import UIKit

final class LoadingFooter: UICollectionReusableView, IdentifiableType {
    static let id = "LoadingFooter"

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        stopAnimating()
    }

    func startAnimating() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }

    func stopAnimating() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

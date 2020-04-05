import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell & IdentifiableType>(_ type: T.Type) {
        register(UINib(nibName: type.id, bundle: nil), forCellWithReuseIdentifier: type.id)
    }

    func register<T: UICollectionReusableView & IdentifiableType>(_ type: T.Type, for kind: String) {
        register(UINib(nibName: type.id, bundle: nil), forSupplementaryViewOfKind: kind, withReuseIdentifier: type.id)
    }

    func dequeue<T: UICollectionViewCell & IdentifiableType>(_ type: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable:next force_cast
        return dequeueReusableCell(withReuseIdentifier: type.id, for: indexPath) as! T
    }

    func dequeue<T: UICollectionReusableView & IdentifiableType>(_ type: T.Type,
                                                                 at indexPath: IndexPath,
                                                                 for kind: String) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind,
                                                withReuseIdentifier: type.id,
                                                // swiftlint:disable:next force_cast
                                                for: indexPath) as! T
    }
}

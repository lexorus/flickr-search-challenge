import UIKit

final class UICollectionViewLayoutBuilder {
    func flowLayout(itemsPerRow: Int, interitemSpacing: CGFloat, inset: CGFloat) -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let screenWidth = UIScreen.main.bounds.width
        let spacing = inset * 2 + interitemSpacing * CGFloat(itemsPerRow - 1)
        let cellWidth = Int((screenWidth - spacing) / CGFloat(itemsPerRow))
        layout.itemSize = .init(width: cellWidth, height: cellWidth)
        layout.sectionInset = .init(top: inset, left: inset, bottom: inset, right: inset)
        layout.minimumLineSpacing = interitemSpacing
        layout.minimumInteritemSpacing = interitemSpacing
        layout.footerReferenceSize = .init(width: screenWidth, height: 50)

        return layout
    }
}

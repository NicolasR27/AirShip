import UIKit
import Kingfisher

class ItemTableCell: UITableViewCell {
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    
    var item: Item? {
        didSet {
            guard let i = item else { return }
            itemImageView.image = nil
            if let thumbnail = URL(string: i.thumbnail) {
                itemImageView.kf.setImage(with: thumbnail)
            }
            
            itemTitleLabel.text = i.title
        }
    }
}

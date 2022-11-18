//
//  ArticlesCustomTableViewCell.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit
import Kingfisher

class ArticlesCustomTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var articleImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 30
    }

    // Func configure with home articles
    func configure(with model: ArticlesModel?) {
        self.titleLabel.text = model?.title
        self.descriptionLabel.text = model?.description
        self.sourceLabel.text = model?.source?.name
        self.authorLabel.text = model?.author

        guard
            let imageString = model?.urlToImage
        else {
            return
        }

        let imageURL = URL(string: imageString)
        self.articleImage.kf.indicatorType = .activity
        self.articleImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.5))])
    }
}

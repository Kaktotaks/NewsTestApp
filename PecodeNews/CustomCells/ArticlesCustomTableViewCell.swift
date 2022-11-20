//
//  ArticlesCustomTableViewCell.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit
import Kingfisher

protocol ArticlesCustomTableViewCellDelegate: AnyObject {
    func saveToFavouritesButtonTapped(tappedForItem item: Int)
}

class ArticlesCustomTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var articleImage: UIImageView!
    @IBOutlet private weak var saveToFavouritesButton: UIButton!
    weak var delegate: ArticlesCustomTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 22
        saveToFavouritesButton.layer.cornerRadius = 6
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

    // Func configure with Core Data articles
    func configureCoreData(with coreDataArticleModel: CDArticle) {
        self.titleLabel.text = coreDataArticleModel.title
        self.descriptionLabel.text = coreDataArticleModel.descriptionText
        self.sourceLabel.text = coreDataArticleModel.source
        self.authorLabel.text = coreDataArticleModel.author

        guard
            let imageString = coreDataArticleModel.urlToImage
        else {
            return
        }

        let imageURL = URL(string: imageString)
        self.articleImage.kf.indicatorType = .activity
        self.articleImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.5))])
        }

    @IBAction func saveToFavouritesButtonTapped(_ sender: Any) {
        self.delegate?.saveToFavouritesButtonTapped(tappedForItem: self.tag)
    }
}

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
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int)
}

class ArticlesCustomTableViewCell: UITableViewCell {
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var sourceLabel: UILabel!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var articleImage: UIImageView!
    @IBOutlet weak var saveToFavouritesButton: UIButton!
    weak var delegate: ArticlesCustomTableViewCellDelegate?

    public var buttonTogled = false

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 22
        saveToFavouritesButton.layer.cornerRadius = 2
    }

    // MARK: - Func configure with viewModel (API model / CoreData Model)
    func configure(with viewModel: ArticlesCustomTableViewCellViewModel) {
        self.titleLabel.text = viewModel.titleLabel
        self.descriptionLabel.text = viewModel.descriptionLabel
        self.sourceLabel.text = viewModel.sourceLabel
        self.authorLabel.text = viewModel.authorLabel
        if viewModel.urlToImage != nil {
            guard let imageString = viewModel.urlToImage else { return }

            let imageURL = URL(string: imageString)
            self.articleImage?.kf.indicatorType = .activity
            self.articleImage?.kf.setImage(with: imageURL, options: [.transition(.fade(0.5))])
        } else {
            articleImage?.image = UIImage(named: "pecodeLogo")
        }
    }

    @IBAction func saveToFavouritesButtonTapped(_ sender: Any) {
        if buttonTogled == false {
            buttonTogled = true
            saveToFavouritesButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
            self.delegate?.saveToFavouritesButtonTapped(tappedForItem: self.tag)
        } else {
            buttonTogled = false
            saveToFavouritesButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
            self.delegate?.deleteFromFavouritesButtonTapped(tappedForItem: self.tag)
        }
    }
}

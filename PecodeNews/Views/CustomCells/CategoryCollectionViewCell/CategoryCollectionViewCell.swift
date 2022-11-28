//
//  CategoryCollectionViewCell.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var categoryNameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        self.categoryNameLabel.text = viewModel.categoryName

        if viewModel.isSelected ?? false {
            indicatorView.isHidden = false
        } else {
            indicatorView.isHidden = true
        }
    }
}

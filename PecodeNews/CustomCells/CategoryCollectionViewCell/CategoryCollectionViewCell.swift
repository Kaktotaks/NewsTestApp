//
//  CategoryCollectionViewCell.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

// swiftlint: disable all

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var indicatorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(with countryModel: Country) {
        categoryNameLabel.text = countryModel.name
        categoryNameLabel.font = countryModel.isSelected ?
        UIFont.makeRoboto(.medium, size: 16.0) : UIFont.makeRoboto(.regular, size: 16.0)
        indicatorView.isHidden = !countryModel.isSelected
    }

    func configureCategorie(_ categoryModel: Category) {
        categoryNameLabel.text = categoryModel.name
        categoryNameLabel.font = categoryModel.isSelected! ?
    UIFont.makeRoboto(.medium, size: 16.0) : UIFont.makeRoboto(.regular, size: 16.0)
        indicatorView.isHidden = !categoryModel.isSelected!
    }

}

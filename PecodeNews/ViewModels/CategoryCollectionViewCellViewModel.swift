//
//  CategoryCollectionViewCellViewModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 28.11.2022.
//

struct CategoryCollectionViewCellViewModel {
    var categoryName: String?
    var isSelected: Bool?

    init(with countryModel: Country) {
        categoryName = countryModel.name
        isSelected = countryModel.isSelected
    }

    init(with categoryModel: Category) {
        categoryName = categoryModel.name
        isSelected = categoryModel.isSelected
    }
}

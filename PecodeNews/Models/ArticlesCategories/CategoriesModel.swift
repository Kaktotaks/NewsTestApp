//
//  CategoriesModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

struct CategoriesModel {
    static var categoriesList: [Category] = [Category(name: "business", isSelected: true),
                                            Category(name: "entertainment", isSelected: false),
                                            Category(name: "general", isSelected: false),
                                            Category(name: "health", isSelected: false),
                                            Category(name: "science", isSelected: false),
                                            Category(name: "sports", isSelected: false),
                                            Category(name: "technology", isSelected: false)
    ]
}

struct Category {
    let name: String?
    var isSelected: Bool
}

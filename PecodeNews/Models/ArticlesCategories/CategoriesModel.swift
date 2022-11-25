//
//  CategoriesModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

struct CategoriesModel {
    static var categoriesList: [Category] = [Category(name: "business"),
                                            Category(name: "entertainment"),
                                            Category(name: "general"),
                                            Category(name: "health"),
                                            Category(name: "science"),
                                            Category(name: "sports"),
                                            Category(name: "technology")
    ]
}

struct Category {
    let name: String?
    var isSelected: Bool?
}

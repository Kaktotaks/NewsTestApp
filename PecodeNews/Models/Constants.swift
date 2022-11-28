//
//  Constants.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit

enum Constants {
    enum TemporaryAlertAnswers {
        static let articleAdded = "Article was successfully added to favourites!"
        static let NoURLArticle = "This article has no url!"
    }

    static let categoryCell = String(describing: CategoryCollectionViewCell.self)
    static let articleCell = String(describing: ArticlesCustomTableViewCell.self)

    static var totalPage = 1
    static var currentPage = 1
    static let tableViewHeight = CGFloat(400)

    static var currentCountry = "us"
    static var currentCategory = "general"
}

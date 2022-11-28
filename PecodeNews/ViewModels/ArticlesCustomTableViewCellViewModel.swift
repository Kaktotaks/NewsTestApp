//
//  ArticlesCustomTableViewCellViewModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 27.11.2022.
//

struct ArticlesCustomTableViewCellViewModel {
    var titleLabel: String?
    var descriptionLabel: String?
    var sourceLabel: String?
    var authorLabel: String?
    var urlToImage: String?

    init(with model: ArticlesModel?) {
        titleLabel = model?.title
        descriptionLabel = model?.description
        sourceLabel = model?.source?.name
        authorLabel = model?.author
        urlToImage = model?.urlToImage
    }

    init(with coreDataModel: CDArticle?) {
        titleLabel = coreDataModel?.title
        descriptionLabel = coreDataModel?.description
        sourceLabel = coreDataModel?.source
        authorLabel = coreDataModel?.author
        urlToImage = coreDataModel?.urlToImage
    }
}

//
//  SearchArticlesViewControllerViewModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 28.11.2022.
//

import UIKit

class SearchArticlesViewControllerViewModel {
    // MARK: - Constants + Variables
    private var filteredArticles: [ArticlesModel] = []

    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    // MARK: - SearchArticlesViewController methods
    // init tableView for searching articles
    func setUpSearchTableView(viewController: UIViewController, tableView: UITableView) {
        let nib = UINib(nibName: Constants.articleCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.articleCell)
        viewController.view.addSubview(tableView)
        tableView.delegate = viewController as? any UITableViewDelegate
        tableView.dataSource = viewController as? any UITableViewDataSource
        tableView.frame = viewController.view.bounds
    }

    func updateSearchResultsInSearchArtVC(searchController: UISearchController, tableView: UITableView) {
        guard let query = searchController.searchBar.text else { return }

        print(query)

        RestService.shared.getAllTopArticles(country: nil,
                                             category: nil,
                                             query: query.trimmingCharacters(in: .whitespaces),
                                             page: 1, limit: 10) { [weak self] articles in
            guard let self = self else { return }

            self.filteredArticles = articles
            tableView.reloadData()
        }
    }

    // MARK: - Work with Core Data storage
    func deleteArticleFromFavourites(viewController: UIViewController) {
        let favoutiteVC = FavouriteArticlesViewController()
        if
            let storedArticle = favoutiteVC.articleToRemove {
            MyCoreDataManager.shared.deleteCoreDataObjct(object: storedArticle, context: self.context) {
                // Fake deletion
            }
        }

        let alert = MyAlertManager.shared.presentTemporaryInfoAlert(
            title: nil,
            message: "Article was deleted!",
            preferredStyle: .actionSheet,
            forTime: 1.0
        )
        viewController.present(alert, animated: true)
    }

    func saveArticleToFavourites(viewController: UIViewController, item: Int) {
        let article = self.filteredArticles[item]
        let cdArticle = CDArticle(context: self.context)
        cdArticle.title = article.title
        cdArticle.urlToImage = article.urlToImage
        cdArticle.author = article.author
        cdArticle.descriptionText = article.description
        cdArticle.source = article.source?.name
        cdArticle.webURL = article.url

        // Save in Core Data action
        MyCoreDataManager.shared.cdSave(self.context)

        let alert = MyAlertManager.shared.presentTemporaryInfoAlert(
            title: nil,
            message: Constants.TemporaryAlertAnswers.articleAdded,
            preferredStyle: .actionSheet,
            forTime: 1.0
        )

        viewController.present(alert, animated: true)
    }

    // MARK: - Work with TableView DataSource/Delegate methods
    func countFilteredArticles() -> Int {
        filteredArticles.count
    }

    func configureCellForRowAtForTableView(viewController: UIViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.articleCell) as? ArticlesCustomTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: ArticlesCustomTableViewCellViewModel(with: filteredArticles[indexPath.row]))
        cell.selectionStyle = .none

        cell.delegate = viewController as? any ArticlesCustomTableViewCellDelegate
        cell.tag = indexPath.row
        return cell
    }

    func presentWebViewViewController(indexPath: IndexPath, viewController: UIViewController) {
        if
            let stringURL = self.filteredArticles[indexPath.row].url,
            let articleURL = URL(string: stringURL) {

            let articleTitle = self.filteredArticles[indexPath.row].title
            let webVC = WebViewViewController(url: articleURL, title: articleTitle)
            let navVC = UINavigationController(rootViewController: webVC)

            viewController.present(navVC, animated: true)
        } else {
            print("No url was found")
            let noURLalert = MyAlertManager.shared.presentTemporaryInfoAlert(
                title: Constants.TemporaryAlertAnswers.NoURLArticle,
                message: nil, preferredStyle: .actionSheet,
                forTime: 1.0
            )

            viewController.present(noURLalert, animated: true)
            return
        }
    }
}

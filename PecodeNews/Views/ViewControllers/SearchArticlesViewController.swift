//
//  SearchArticlesViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 18.11.2022.
//

import UIKit

class SearchArticlesViewController: UIViewController, UISearchResultsUpdating {
    // Constants and Variables
    private let filteredArticlesTableView: UITableView = {
        let value = UITableView()
        value.translatesAutoresizingMaskIntoConstraints = false
        value.separatorStyle = .none
        return value
    }()
    private var filteredArticles: [ArticlesModel] = []

    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    // UI life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchTableView()
    }

    // Methods
    private func setUpSearchTableView() {
        let nib = UINib(nibName: Constants.articleCell, bundle: nil)
        self.filteredArticlesTableView.register(nib, forCellReuseIdentifier: Constants.articleCell)
        view.addSubview(filteredArticlesTableView)
        filteredArticlesTableView.delegate = self
        filteredArticlesTableView.dataSource = self
        filteredArticlesTableView.frame = view.bounds
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text else { return }

        print(query)

        RestService.shared.getAllTopArticles(country: nil,
                                             category: nil,
                                             query: query.trimmingCharacters(in: .whitespaces),
                                             page: 1,
                                             limit: Constants.pageLimit
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let articles):
                DispatchQueue.main.async {
                    self.filteredArticles = articles
                    self.filteredArticlesTableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                let noInternetConnectionAlert = MyAlertManager.shared.presentTemporaryInfoAlert(
                    title: Constants.somethingWentWrongAnswear,
                    message: error.localizedDescription,
                    preferredStyle: .actionSheet,
                    forTime: 10.0)
                DispatchQueue.main.async {
                    self.present(noInternetConnectionAlert, animated: true)
                }
            }
        }
    }
}

// MARK: - Work with tableView DataSource/Delegate methods
extension SearchArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filteredArticles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.articleCell) as? ArticlesCustomTableViewCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: ArticlesCustomTableViewCellViewModel(with: filteredArticles[indexPath.row]))
        cell.selectionStyle = .none

        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let stringURL = filteredArticles[indexPath.row].url,
            let artilleURL = URL(string: stringURL) {

            let articleTitle = filteredArticles[indexPath.row].title
            let webVC = WebViewViewController(url: artilleURL, title: articleTitle)
            let navVC = UINavigationController(rootViewController: webVC)
            self.present(navVC, animated: true)
        } else {
            print("No url was found")
            let noURLalert = MyAlertManager.shared.presentTemporaryInfoAlert(
                title: Constants.TemporaryAlertAnswers.NoURLArticle,
                message: nil, preferredStyle: .actionSheet,
                forTime: 1.0
            )

            self.present(noURLalert, animated: true)
            return
        }
    }
}

// MARK: - Work with custom Delegates
extension SearchArticlesViewController: ArticlesCustomTableViewCellDelegate {
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int) {
        // Fake deletion article

        let alert = MyAlertManager.shared.presentTemporaryInfoAlert(
            title: nil,
            message: Constants.TemporaryAlertAnswers.articleDelited,
            preferredStyle: .actionSheet,
            forTime: 1.0
        )

        present(alert, animated: true)
    }

    func saveToFavouritesButtonTapped(tappedForItem item: Int) {
        let article = filteredArticles[item]
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

        present(alert, animated: true)
    }
}

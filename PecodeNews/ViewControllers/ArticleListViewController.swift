//
//  ArticleListViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit

class ArticleListViewController: UIViewController {
    @IBOutlet private weak var articlesTableView: UITableView!

    private var articlesModel: [ArticlesModel]? = []
    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    private let searchController = UISearchController(searchResultsController: SearchArticlesViewController())
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
            return text.isEmpty
    }
    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        getCountryArticles(country: .us)
        setUpSerachController()
        setUpRefreshControl()
    }

    // Setup refreshControl
    private func setUpRefreshControl() {
        articlesTableView.refreshControl = UIRefreshControl()
        articlesTableView.refreshControl?.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
    }

    @objc private func didPullRefresh() {
        // Re-fetch data here
        print("Start refresh")
        fetchData()
    }

    private func fetchData() {
        self.articlesModel?.removeAll()

        if articlesTableView.refreshControl?.isRefreshing == true {
            print("refreshing data")
        } else {
            print("fetching data")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }

            self.getCountryArticles(country: .de)
            self.articlesTableView?.refreshControl?.endRefreshing()
        }
    }

    // SearchingSetup methods
    private func setUpSerachController() {
        let searchArtVC = SearchArticlesViewController()
        let searchController = UISearchController(searchResultsController: searchArtVC)
        searchController.searchResultsUpdater = searchArtVC
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
//        resultVC.delegate = self
    }

    // APICall methods
    private func getCountryArticles(country: Countries) {
        DispatchQueue.main.async {
            APIService.shared.requestCountryArticles(with: country) { articles in
                self.articlesModel = articles
                self.articlesTableView.reloadData()
            }
        }
    }

    // TableView methods
    private func configureTableView() {
        let nib = UINib(nibName: "ArticlesCustomTableViewCell", bundle: nil)
        self.articlesTableView.register(nib, forCellReuseIdentifier: "ArticlesCustomTableViewCell")
    }
}

extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.articlesModel?.count ?? 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "ArticlesCustomTableViewCell"
            ) as? ArticlesCustomTableViewCell
        else {
            return UITableViewCell()
        }

        cell.selectionStyle = .none
        cell.configure(with: articlesModel?[indexPath.row])

        cell.delegate = self
        cell.tag = indexPath.row
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let stringURL = articlesModel?[indexPath.row].url,
            let artilleURL = URL(string: stringURL) {

            let articleTitle = articlesModel?[indexPath.row].title
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

extension ArticleListViewController: ArticlesCustomTableViewCellDelegate {
    func saveToFavouritesButtonTapped(tappedForItem item: Int) {
        let article = articlesModel?[item]
        let cdArticle = CDArticle(context: self.context)
        cdArticle.title = article?.title
        cdArticle.urlToImage = article?.urlToImage
        cdArticle.author = article?.author
        cdArticle.descriptionText = article?.description
        cdArticle.source = article?.source?.name
        cdArticle.webURL = article?.url

        // if buttoneState == tapped {} else if buttoneState == untapped {}

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

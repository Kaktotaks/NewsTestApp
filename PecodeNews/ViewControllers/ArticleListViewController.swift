//
//  ArticleListViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit

class ArticleListViewController: UIViewController {
    @IBOutlet private weak var upNavButton: UIButton!
    @IBOutlet private weak var articlesTableView: UITableView!
    private var articlesModel: [ArticlesModel] = []
    @IBOutlet private weak var articleSettingsView: UIView!

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
//        getArticles(pagination: false, page: 1)
        refresArticles()
        setUpSerachController()
        setUpRefreshControl()
        scrollViewDidScroll(articlesTableView)
    }

    @IBAction func upnavButtonTapped(_ sender: Any) {
        let topRow = IndexPath(row: 0,
                               section: 0)

        self.articlesTableView.scrollToRow(at: topRow,
                                   at: .top,
                                   animated: true)
    }

    // Setup refreshControl
    private func setUpRefreshControl() {
        articlesTableView.refreshControl = UIRefreshControl()
        articlesTableView.refreshControl?.addTarget(self, action: #selector(didPullRefresh), for: .valueChanged)
    }

    @objc private func didPullRefresh() {
        refresArticles()
    }

    private func refresArticles() {
        // refresh data here
        DispatchQueue.main.async {
            self.articlesTableView.refreshControl?.beginRefreshing()
            print("Start refresh")

            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(page: Constants.currentPage)
            self.articlesTableView.refreshControl?.endRefreshing()
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
    }

    // APICall methods
    private func getArticles(pagination: Bool = false, page: Int = Constants.currentPage) {
        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 0 : 2), execute: { [ weak self ] in
            RestService.shared.getAllTopArticles(pagination: pagination, country: .us, category: nil, query: nil, page: page, limit: 10) { [weak self] articles in

                guard
                    let self = self
                else { return }

                //                self.articlesModel.removeAll()
                self.articlesModel.append(contentsOf: articles)
                DispatchQueue.main.async {
                    self.articlesTableView.reloadData()
                    self.articlesTableView.tableFooterView = nil
                }
            }
        })
        }

    // TableView methods
    private func configureTableView() {
        let nib = UINib(nibName: "ArticlesCustomTableViewCell", bundle: nil)
        self.articlesTableView.register(nib, forCellReuseIdentifier: "ArticlesCustomTableViewCell")
    }
}

// MARK: - Work with TableView
extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.articlesModel.count
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))

        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        return footerView
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
            cell.configure(with: articlesModel[indexPath.row])

            cell.delegate = self
            cell.tag = indexPath.row
            return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if Constants.currentPage >= Constants.totalPage && indexPath.row == articlesModel.count - 1 {
            Constants.currentPage += 1
            print("Current page now is: \(Constants.currentPage)")

            var isPaginatint = RestService.shared.isPaginating

            guard !isPaginatint else {
                print("We are already paginating more data")
                return
            }

            self.articlesTableView.tableFooterView = createSpinnerFooter()
            getArticles(page: Constants.currentPage)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let stringURL = articlesModel[indexPath.row].url,
            let artilleURL = URL(string: stringURL) {

            let articleTitle = articlesModel[indexPath.row].title
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

    // Configure aperiance upButton + settingView
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self
            else {
                return
            }

            let startPoint = scrollView.contentOffset.y
            let scrollHeight = scrollView.frame.height

            if startPoint >= abs(scrollHeight) {
                self.articleSettingsView.isHidden = true
                self.upNavButton.isHidden = false
            } else {
                self.articleSettingsView.isHidden = false
                self.upNavButton.isHidden = true
            }
        }
    }
}

// MARK: - Work with Delegates
extension ArticleListViewController: ArticlesCustomTableViewCellDelegate {
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int) {
        let favoutiteVC = FavouriteArticlesViewController()
        if
            let storedArticle = favoutiteVC.articleToRemove {
            MyCoreDataManager.shared.deleteCoreDataObjct(object: storedArticle, context: self.context) {
                //
            }
        }

        let alert = MyAlertManager.shared.presentTemporaryInfoAlert(
            title: nil,
            message: "Aticle was deleted!",
            preferredStyle: .actionSheet,
            forTime: 1.0
        )
        present(alert, animated: true)
    }

    func saveToFavouritesButtonTapped(tappedForItem item: Int) {
        let article = articlesModel[item]
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

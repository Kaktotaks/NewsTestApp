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
    @IBOutlet private weak var articleSettingsView: UIView!
    @IBOutlet private weak var categoriesCollectionView: UICollectionView!
    @IBOutlet private weak var filteredByButton: UIButton!

    private var articlesModel: [ArticlesModel] = []
    private var countriesModel = CountriesModel.countriesList
    private var categoriesModel = CategoriesModel.categoriesList
    private let spinner = UIActivityIndicatorView()
    private var categorySwitcher = 0

    private let searchController = UISearchController(searchResultsController: SearchArticlesViewController())

    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
            return text.isEmpty
    }
    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFilteredByButton()
        configureActivityIndicator()
        configureTableView()
        configureCollectionView()
        refreshArticles()
        setUpSearchController()
        setUpRefreshControl()
        scrollViewDidScroll(articlesTableView)
    }

    private func configureActivityIndicator() {
        spinner.center = view.center
        view.addSubview(spinner)
        spinner.startAnimating()
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

    private func setupFilteredByButton() {
        let categoriesMenu = UIMenu(title: "", children: [
            UIAction(title: "Countries",
                     image: UIImage(systemName: "flag"),
                     handler: { action in
                         print("Countries")
                         self.categorySwitcher = 0
                         self.categoriesCollectionView.reloadData()
            }),
            UIAction(title: "Categories",
                     image: UIImage(systemName: "soccerball"),
                     handler: { action in
                         print("Categories")
                         self.categorySwitcher = 1
                         self.categoriesCollectionView.reloadData()
            })
        ])

        filteredByButton.layer.cornerRadius = 4
        filteredByButton.menu = categoriesMenu
    }

    @objc private func didPullRefresh() {
        refreshArticles()
    }

    private func refreshArticles() {
        // refresh data here
            self.articlesTableView.refreshControl?.beginRefreshing()
            self.articlesTableView.isHidden = true
            print("Start refresh")

            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(page: Constants.currentPage)
            self.articlesTableView.refreshControl?.endRefreshing()
    }

    // SearchingSetup method
    private func setUpSearchController() {
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
            RestService.shared.getAllTopArticles(
                pagination: pagination,
                country: .us,
                category: nil,
                query: nil,
                page: page,
                limit: 10) { [weak self] articles in
                guard let self = self else { return }

                //                self.articlesModel.removeAll()
                self.articlesModel.append(contentsOf: articles)
                DispatchQueue.main.async {
                    self.articlesTableView.reloadData()
                    self.articlesTableView.tableFooterView = nil
                    self.articlesTableView.isHidden = false
                    self.spinner.removeFromSuperview()
                }
            }
        })
        }

    // TableView methods
    private func configureTableView() {
        let nib = UINib(nibName: Constants.articleCell, bundle: nil)
        self.articlesTableView.register(nib, forCellReuseIdentifier: Constants.articleCell)
    }

    private func configureCollectionView() {
        self.categoriesCollectionView.register(UINib(nibName: Constants.categoryCell, bundle: nil),
                                     forCellWithReuseIdentifier: Constants.categoryCell)
    }

//    func setCurrentCategory(at indexPath: IndexPath) {
//        guard let currentCountryCategory = currentCountryCategory else { return }
//
//        currentCategoryIndex = indexPath.row
//        countriesCollectionView.reloadData()
//    }

}

// MARK: - Work with TableView
extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.articlesModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.articleCell
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

            self.articlesTableView.tableFooterView = SpinnerFooterCell.shared.createSpinnerFooter(
                viewController: self,
                tableView: articlesTableView
            )

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
            guard let self = self else { return }

            let startPoint = scrollView.contentOffset.y
            let scrollHeight = scrollView.frame.height

            if startPoint >= abs(scrollHeight * 2) {
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

// MARK: - CollectionView extensions
extension ArticleListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if self.categorySwitcher == 1 {
            return self.categoriesModel.count
        } else {
            return self.countriesModel.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.categoryCell,
                for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        if self.categorySwitcher == 1 {
            let model = self.categoriesModel[indexPath.row]
            cell.categoryNameLabel.text = model.name
            cell.indicatorView.isHidden = !model.isSelected
            return cell
        } else {
            let model = self.countriesModel[indexPath.row]
            cell.categoryNameLabel.text = model.name
            cell.indicatorView.isHidden = !model.isSelected
            return cell
        }

//            cell.categoryNameLabel.text = model.name
//            cell.indicatorView.isHidden = !model.isSelected

//        cell.configure(with: model)

//        let isSelected = (indexPath.row == self.currentCategoryIndex)
//        cell.configure(with: .init(name: model.name, isSelected: isSelected))

    }
}

// MARK: - UICollectionViewDelegate

extension ArticleListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView == self.categoriesCollectionView else { return }

        print("Tap on index \(indexPath.row)")

//        setCurrentCategory(at: indexPath)
    }
}

//
//  ArticleListViewControllerViewModel.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 28.11.2022.
//

import UIKit

class ArticleListViewControllerViewModel {
    // MARK: - Constants + Variables
    private let searchController = UISearchController(searchResultsController: SearchArticlesViewController())
    private var isSearchBarEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    var articlesModel: [ArticlesModel] = []
    var countriesModel = CountriesModel.countriesList
    var categoriesModel = CategoriesModel.categoriesList
    var categorySwitcher = 0
    var lastActiveIndex: IndexPath = [1, 0]

    // swiftlint:disable force_cast
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    // MARK: - ArticleListViewController methods
    func upnavButtonTapped(tableView: UITableView) {
        let topRow = IndexPath(row: 0, section: 0)

        tableView.scrollToRow(at: topRow,
                              at: .top,
                              animated: true)
    }

    // Setup FilteredByButton menu actions
    func setupFilteredByButton(collectionView: UICollectionView, filteredByButton: UIButton) {
        let categoriesMenu = UIMenu(title: "", children: [
            UIAction(title: "Countries",
                     image: UIImage(systemName: "flag")) { [weak self] _ in
                         print("Countries")
                         self?.categorySwitcher = 0
                         collectionView.reloadData()
            },
            UIAction(title: "Categories",
                     image: UIImage(systemName: "soccerball")) { [weak self] _ in
                         print("Categories")
                         self?.categorySwitcher = 1
                         collectionView.reloadData()
            }
        ])

        filteredByButton.layer.cornerRadius = 4
        filteredByButton.menu = categoriesMenu
    }

    // Setup SearchController
    func setUpSearchController(viewController: UIViewController) {
        let searchArtVC = SearchArticlesViewController()
        let searchController = UISearchController(searchResultsController: searchArtVC)
        searchController.searchResultsUpdater = searchArtVC
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for News"
        viewController.navigationItem.searchController = searchController
        viewController.definesPresentationContext = true
    }

    // Setup API call
    func getArticles(pagination: Bool = false,
                     page: Int = Constants.currentPage,
                     showActivityIndicator: Bool = false,
                     countryName: String? = "us",
                     categoryName: String? = nil,
                     tableView: UITableView
    ) {
        if showActivityIndicator {
            ActivityIndicatorManager.shared.showIndicator(.magazineAnimation)
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 1 : 0)) {
            RestService.shared.getAllTopArticles(
                pagination: pagination,
                country: countryName,
                category: categoryName,
                query: nil,
                page: page,
                limit: 5) { [weak self] articles in
                    guard let self = self else { return }

                    self.articlesModel.append(contentsOf: articles)
                    DispatchQueue.main.async {
                        tableView.reloadData()
                        tableView.tableFooterView = nil
                        ActivityIndicatorManager.shared.hide()
                    }
            }
        }
    }

    // Configure UIRefresh
    func refreshArticles(tableView: UITableView) {
        tableView.refreshControl?.beginRefreshing()
        print("Start refreshing")

        articlesModel.removeAll()
        Constants.currentPage = 1
        self.getArticles(
            pagination: false,
            page: Constants.currentPage,
            showActivityIndicator: false,
            countryName: Constants.currentCountry,
            categoryName: Constants.currentCategory,
            tableView: tableView
        )
        tableView.refreshControl?.endRefreshing()
    }

    // Configure Pagination setup
    func setupPagination(indexPath: IndexPath, completion: @escaping(() -> Void)) {
        if Constants.currentPage >= Constants.totalPage && indexPath.row == self.articlesModel.count - 1 {
            Constants.currentPage += 1
            print("Current page now is: \(Constants.currentPage)")

            var isPaginatint = RestService.shared.isPaginating

            guard !isPaginatint else {
                print("We are already paginating more data")
                return
            }
            completion()
        }
    }

    // Configure DetailViewController(WebViewViewController)
    func presentWebViewViewController(indexPath: IndexPath, viewController: UIViewController) {
        if
            let stringURL = self.articlesModel[indexPath.row].url,
            let artilleURL = URL(string: stringURL) {

            let articleTitle = self.articlesModel[indexPath.row].title
            let webVC = WebViewViewController(url: artilleURL, title: articleTitle)
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

    // Configure upButton and settingView appearance
    func setUpScrollViewDidScroll(_ scrollView: UIScrollView, articleSettingsView: UIView, upNavButton: UIButton) {
        DispatchQueue.main.async {
            let startPoint = scrollView.contentOffset.y
            let scrollHeight = scrollView.frame.height

            if startPoint >= abs(scrollHeight * 2) {
                articleSettingsView.isHidden = true
                upNavButton.isHidden = false
            } else {
                articleSettingsView.isHidden = false
                upNavButton.isHidden = true
            }
        }
    }

    // MARK: - Work with Core Data storage
    func deleteArticleFromFavourites(viewController: UIViewController) {
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
        viewController.present(alert, animated: true)
    }

    func saveArticleToFavourites(viewController: UIViewController, item: Int) {
        let article = self.articlesModel[item]
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

    // MARK: - Work with TableView/CollectionView DataSource/Delegate methods
    // Configure TableView + CollectionView
    func configureTableView(tableView: UITableView) {
        let nib = UINib(nibName: Constants.articleCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constants.articleCell)
    }

    func configureCollectionView(collectionView: UICollectionView) {
        collectionView.register(UINib(nibName: Constants.categoryCell, bundle: nil),
                                forCellWithReuseIdentifier: Constants.categoryCell)
    }

    // Handle Switch action with filterButtin for CategoriesModel
    func handleSwitchCategoriesModelCount() -> Int {
        if self.categorySwitcher == 1 {
            return self.categoriesModel.count
        } else {
            return self.countriesModel.count
        }
    }

    // Setup cells in CategoryCollectionView depends on filterButtonAction
    func cellForItemAtCategoriesModel(collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Constants.categoryCell,
                for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }

        if self.categorySwitcher == 1 {
            let categoriesModel = self.categoriesModel[indexPath.row]
            cell.configure(with: CategoryCollectionViewCellViewModel(with: categoriesModel))

            return cell
        } else {
            let countriesModel = self.countriesModel[indexPath.row]
            cell.configure(with: CategoryCollectionViewCellViewModel(with: countriesModel))
            return cell
        }
    }

    // Setup customCells in ArticletableView
    func configureCellForRowAtForTableView(
        viewController: UIViewController,
        tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.articleCell
                ) as? ArticlesCustomTableViewCell
            else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none
            cell.configure(with: ArticlesCustomTableViewCellViewModel(with: articlesModel[indexPath.row]))

            cell.delegate = viewController as? any ArticlesCustomTableViewCellDelegate
            cell.tag = indexPath.row
            return cell
        }

    // Switch between countries and categories models
    func collectionViewDidSelectItemAt(collectionView: UICollectionView,
                                       didSelectItemAt indexPath: IndexPath,
                                       tableView: UITableView) {
        if self.categorySwitcher == 1 {
            guard let categoryName = self.categoriesModel[indexPath.row].name else { return }
            print(categoryName)
            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(pagination: false,
                             page: Constants.currentPage,
                             showActivityIndicator: true,
                             countryName: Constants.currentCountry,
                             categoryName: categoryName,
                             tableView: tableView)
            Constants.currentCategory = categoryName
        } else {
            guard let countryName = self.countriesModel[indexPath.row].name else { return }
            print(countryName)
            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(pagination: false,
                             page: Constants.currentPage,
                             showActivityIndicator: true,
                             countryName: countryName,
                             categoryName: Constants.currentCategory,
                             tableView: tableView
            )
            Constants.currentCountry = countryName
        }

        if self.lastActiveIndex != indexPath {
            let firstCell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
            firstCell?.indicatorView.isHidden = false

            let secondCell = collectionView.cellForItem(at: self.lastActiveIndex) as? CategoryCollectionViewCell
            secondCell?.indicatorView.isHidden = true
            self.lastActiveIndex = indexPath
        }
    }

    // MARK: - INITIAL VIEWMODEL SETUP
    func initialViewModelSetup(viewController: UIViewController,
                               tableView: UITableView,
                               collectionView: UICollectionView,
                               filteredByButton: UIButton) {
        self.setupFilteredByButton(collectionView: collectionView,
                                   filteredByButton: filteredByButton)
        self.configureTableView(tableView: tableView)
        self.configureCollectionView(collectionView: collectionView)
        self.getArticles(pagination: false,
                         page: Constants.currentPage, showActivityIndicator: true,
                         countryName: Constants.currentCountry,
                         categoryName: Constants.currentCategory,
                         tableView: tableView)
        self.setUpSearchController(viewController: viewController)
    }
}

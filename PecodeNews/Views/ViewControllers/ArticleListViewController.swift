//
//  ArticleListViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 17.11.2022.
//

import UIKit

class ArticleListViewController: UIViewController {
    // MARK: - Constants and Variables
    @IBOutlet private weak var upNavButton: UIButton!
    @IBOutlet private weak var articlesTableView: UITableView!
    @IBOutlet private weak var articleSettingsView: UIView!
    @IBOutlet private weak var categoriesCollectionView: UICollectionView!
    @IBOutlet private weak var filteredByButton: UIButton!

    private var articlesModel: [ArticlesModel] = []
    private var countriesModel = CountriesModel.countriesList
    private var categoriesModel = CategoriesModel.categoriesList
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

    enum TableSection: Int {
        case articlesList
        case loader
    }

    // MARK: - UI life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupFilteredByButton()
        configureTableView()
        configureCollectionView()
        getArticles(
            pagination: false,
            page: Constants.currentPage,
            showActivityIndicator: true,
            countryName: Constants.currentCountry,
            categoryName: Constants.currentCategory
        )
        setUpSearchController()
        setUpRefreshControl()
        scrollViewDidScroll(articlesTableView)
    }

    // Methods
    @IBAction func upnavButtonTapped(_ sender: Any) {
        let topRow = IndexPath(row: 0, section: 0)

        self.articlesTableView.scrollToRow(at: topRow,
                                           at: .top,
                                           animated: true
        )
    }

    // Setup refreshControl
    private func setUpRefreshControl() {
        articlesTableView.refreshControl = UIRefreshControl()
        articlesTableView.refreshControl?.addTarget(self,
                                                    action: #selector(didPullRefresh),
                                                    for: .valueChanged)
    }

    private func setupFilteredByButton() {
        let categoriesMenu = UIMenu(title: "",
                                    children: [
            UIAction(title: "Countries",
                     image: UIImage(systemName: "flag")) { _ in
                         print("Countries")
                         self.categorySwitcher = 0
                         self.categoriesCollectionView.reloadData()
            },
            UIAction(title: "Categories",
                     image: UIImage(systemName: "soccerball")) { _ in
                         print("Categories")
                         self.categorySwitcher = 1
                         self.categoriesCollectionView.reloadData()
            }
        ]
    )

        filteredByButton.layer.cornerRadius = 4
        filteredByButton.menu = categoriesMenu
    }

    // Refreshing data here
    @objc private func didPullRefresh() {
        self.articlesTableView.refreshControl?.beginRefreshing()
        print("Start refreshing")

        self.articlesModel.removeAll()
        Constants.currentPage = 1
        self.getArticles(
            pagination: false,
            page: Constants.currentPage,
            showActivityIndicator: false,
            countryName: Constants.currentCountry,
            categoryName: Constants.currentCategory
        )
        self.articlesTableView.refreshControl?.endRefreshing() // temporary solution (because of the bug)
    }

    // Setup UISearchController method
    private func setUpSearchController() {
        let searchArtVC = SearchArticlesViewController()
        let searchController = UISearchController(searchResultsController: searchArtVC)
        searchController.searchResultsUpdater = searchArtVC
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for News"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // APICall method
    private func getArticles(pagination: Bool = false,
                             page: Int = Constants.currentPage,
                             showActivityIndicator: Bool = false,
                             countryName: String? = "us",
                             categoryName: String? = nil
    ) {
        if showActivityIndicator {
            ActivityIndicatorManager.shared.showIndicator(.magazineAnimation)
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + (pagination ? 2 : 0)) {
            RestService.shared.getAllTopArticles(
                pagination: pagination,
                country: countryName,
                category: categoryName,
                query: nil,
                page: page,
                limit: Constants.pageLimit
            ) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let articles):
                    self.articlesModel.append(contentsOf: articles)
                    DispatchQueue.main.async {
                        ActivityIndicatorManager.shared.hide()
                        self.articlesTableView.reloadData()
                    }
                case .failure(let error):
                    let somethingWentWrongAlert = MyAlertManager.shared.presentTemporaryInfoAlert(
                        title: Constants.somethingWentWrongAnswear,
                        message: error.localizedDescription,
                        preferredStyle: .actionSheet,
                        forTime: 10.0)
                    DispatchQueue.main.async {
                        ActivityIndicatorManager.shared.hide()
                        self.present(somethingWentWrongAlert, animated: true)
                    }
                }
            }
        }
    }

    // TableView/CollectionView registr methods
    private func configureTableView() {
        let nib = UINib(nibName: Constants.articleCell, bundle: nil)
        self.articlesTableView.register(nib, forCellReuseIdentifier: Constants.articleCell)
    }

    private func configureCollectionView() {
        self.categoriesCollectionView.register(UINib(nibName: Constants.categoryCell, bundle: nil),
                                     forCellWithReuseIdentifier: Constants.categoryCell)
    }
}

// MARK: - Work with tableView DataSource/Delegate methods
extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let listSection = TableSection(rawValue: section) else { return 0 }

        switch listSection {
        case .articlesList:
            return self.articlesModel.count
        case .loader:
            return self.articlesModel.count >= Constants.pageLimit ? 1 : 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let section = TableSection(rawValue: indexPath.section)
        else {
            return UITableViewCell()
        }
        var totalRezults = RestService.shared.totalRezults

        switch section {
        case .articlesList:
            guard
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: Constants.articleCell
                ) as? ArticlesCustomTableViewCell
            else {
                return UITableViewCell()
            }

            cell.configure(with: ArticlesCustomTableViewCellViewModel(with: articlesModel[indexPath.row]))
            cell.delegate = self
            cell.tag = indexPath.row
            cell.selectionStyle = .none
            return cell
        case .loader:
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "loaderCell") else {
                return UITableViewCell()
            }

            cell.selectionStyle = .none

            if totalRezults > articlesModel.count {
                return cell
            }
        }

        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let section = TableSection(rawValue: indexPath.section) else { return }
        guard !self.articlesModel.isEmpty else { return }

        if section == .loader {
            var isPaginatint = RestService.shared.isPaginating
            guard !isPaginatint else {
                print("We are already paginating more data")
                return
            }

                print("load new data..")
                Constants.currentPage += 1
                print("Current page now is: \(Constants.currentPage)")
                getArticles(pagination: true,
                            page: Constants.currentPage,
                            countryName: Constants.currentCountry,
                            categoryName: Constants.currentCategory
                )
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = TableSection(rawValue: indexPath.section)

        if section == .loader {
            return 60
        }

        return Constants.tableViewHeight
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

    // Configure appearance upButton + settingView
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

// MARK: - Work with collectionView DataSource/Delegate methods
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
            let categoriesModel = self.categoriesModel[indexPath.row]
            cell.configure(with: CategoryCollectionViewCellViewModel(with: categoriesModel))

            return cell
        } else {
            let countriesModel = self.countriesModel[indexPath.row]
            cell.configure(with: CategoryCollectionViewCellViewModel(with: countriesModel))
            return cell
        }
    }
}

extension ArticleListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var lastActiveIndex: IndexPath = [1, 0]

        if self.categorySwitcher == 1 {
            guard let categoryName = categoriesModel[indexPath.row].name else { return }

            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(pagination: false,
                             page: Constants.currentPage,
                             showActivityIndicator: true,
                             countryName: Constants.currentCountry,
                             categoryName: categoryName)
            Constants.currentCategory = categoryName
        } else {
            guard let countryName = countriesModel[indexPath.row].name else { return }

            self.articlesModel.removeAll()
            Constants.currentPage = 1
            self.getArticles(pagination: false,
                             page: Constants.currentPage,
                             showActivityIndicator: true,
                             countryName: countryName,
                             categoryName: Constants.currentCategory
            )
            Constants.currentCountry = countryName
        }

        if lastActiveIndex != indexPath {
            let firstCell = collectionView.cellForItem(at: indexPath) as? CategoryCollectionViewCell
            firstCell?.indicatorView.isHidden = false

            let secondCell = collectionView.cellForItem(at: lastActiveIndex) as? CategoryCollectionViewCell
            secondCell?.indicatorView.isHidden = true
            lastActiveIndex = indexPath
        }
    }
}

// MARK: - Work with custom Delegates
extension ArticleListViewController: ArticlesCustomTableViewCellDelegate {
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int) {
        // Fake deletion article

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

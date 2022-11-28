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

    private var viewModel = ArticleListViewControllerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.initialViewModelSetup(viewController: self,
                                        tableView: articlesTableView,
                                        collectionView: categoriesCollectionView,
                                        filteredByButton: filteredByButton)
        setUpRefreshControl()
        scrollViewDidScroll(articlesTableView)
    }

    @IBAction func upnavButtonTapped(_ sender: Any) {
        viewModel.upnavButtonTapped(tableView: articlesTableView)
    }

    // Setup refreshControl
    func setUpRefreshControl() {
        articlesTableView.refreshControl = UIRefreshControl()
        articlesTableView.refreshControl?.addTarget(self,
                                                    action: #selector(refreshArticles),
                                                    for: .valueChanged)
    }

    @objc private func refreshArticles() {
        viewModel.refreshArticles(tableView: articlesTableView)
    }
}

// MARK: - Work with TableView
extension ArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.viewModel.articlesModel.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.configureCellForRowAtForTableView(viewController: self, tableView: tableView, cellForRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        viewModel.setupPagination(indexPath: indexPath) { [weak self] in
            guard let self = self else { return }

            self.articlesTableView.tableFooterView = SpinnerFooterCell.shared.createSpinnerFooter(
                viewController: self,
                tableView: self.articlesTableView
            )

            self.viewModel.getArticles(pagination: true,
                        page: Constants.currentPage,
                        countryName: Constants.currentCountry,
                                       categoryName: Constants.currentCategory,
                                       tableView: self.articlesTableView
            )
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentWebViewViewController(indexPath: indexPath, viewController: self)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        viewModel.setUpScrollViewDidScroll(scrollView, articleSettingsView: articleSettingsView, upNavButton: upNavButton)
    }
}

// MARK: - Work with CollectionView
extension ArticleListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.handleSwitchCategoriesModelCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        viewModel.cellForItemAtCategoriesModel(collectionView: collectionView, indexPath: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.collectionViewDidSelectItemAt(collectionView: collectionView,
                                                didSelectItemAt: indexPath,
                                                tableView: articlesTableView)
    }
}

// MARK: - Work with Custom Delegates
extension ArticleListViewController: ArticlesCustomTableViewCellDelegate {
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int) {
        viewModel.deleteArticleFromFavourites(viewController: self)
    }

    func saveToFavouritesButtonTapped(tappedForItem item: Int) {
        viewModel.saveArticleToFavourites(viewController: self, item: item)
    }
}

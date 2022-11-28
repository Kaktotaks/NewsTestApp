//
//  SearchArticlesViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 18.11.2022.
//

import UIKit

class SearchArticlesViewController: UIViewController, UISearchResultsUpdating {
    private let filteredArticlesTableView: UITableView = {
        let value = UITableView()
        value.translatesAutoresizingMaskIntoConstraints = false
        value.separatorStyle = .none
        return value
    }()

    private var viewModel = SearchArticlesViewControllerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.setUpSearchTableView(viewController: self, tableView: filteredArticlesTableView)
    }

    func updateSearchResults(for searchController: UISearchController) {
        viewModel.updateSearchResultsInSearchArtVC(searchController: searchController, tableView: filteredArticlesTableView)
    }
}

extension SearchArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.countFilteredArticles()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewModel.configureCellForRowAtForTableView(viewController: self,
                                                    tableView: filteredArticlesTableView,
                                                    cellForRowAt: indexPath
        )
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.tableViewHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.presentWebViewViewController(indexPath: indexPath, viewController: self)
    }
}

extension SearchArticlesViewController: ArticlesCustomTableViewCellDelegate {
    func deleteFromFavouritesButtonTapped(tappedForItem item: Int) {
        viewModel.deleteArticleFromFavourites(viewController: self)
    }

    func saveToFavouritesButtonTapped(tappedForItem item: Int) {
        viewModel.saveArticleToFavourites(viewController: self, item: item)
    }
}

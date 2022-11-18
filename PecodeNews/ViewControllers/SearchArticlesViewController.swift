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

    private var filteredArticles: [ArticlesModel]? = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSearchTableView()
    }

    private func setUpSearchTableView() {
        let nib = UINib(nibName: "ArticlesCustomTableViewCell", bundle: nil)
        self.filteredArticlesTableView.register(nib, forCellReuseIdentifier: "ArticlesCustomTableViewCell")
        view.addSubview(filteredArticlesTableView)
        filteredArticlesTableView.delegate = self
        filteredArticlesTableView.dataSource = self
        filteredArticlesTableView.frame = view.bounds
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard
            let query = searchController.searchBar.text
        else {
            return
        }

        print(query)

        APIService.shared.requestSearchingArticles(with: query.trimmingCharacters(in: .whitespaces)) { erticles in
            if let erticles = erticles {
                self.filteredArticles = erticles
                DispatchQueue.main.async {
                    self.filteredArticlesTableView.reloadData()
                }
            }
        }
    }
}

extension SearchArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.filteredArticles?.count ?? 5
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCustomTableViewCell") as? ArticlesCustomTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: filteredArticles?[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }
}

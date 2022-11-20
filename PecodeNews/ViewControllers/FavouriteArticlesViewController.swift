//
//  FavouriteArticlesViewController.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 20.11.2022.
//

import UIKit

class FavouriteArticlesViewController: UIViewController {
    private var articlesTableView: UITableView = {
       let tableView = UITableView()
       tableView.separatorStyle = .none
       return tableView
   }()

    private var favouriteArticles: [CDArticle] = []

    // swiftlint:disable force_cast
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // swiftlint:enable force_cast

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpArticlesTableView()
        self.favouriteArticles = getArticles()
        configureNavigationBar()
    }

    private func configureNavigationBar() {
        title = "Favourite Articles"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Clear all",
            style: .plain,
            target: self,
            action: #selector(didTapClearAllButton))

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(didTapBackButton))
    }

    @objc private func didTapClearAllButton() {
        MyCoreDataManager.shared.cdTryDeleteAllObjects(context: context) {
            self.getArticles()
        }
    }

    @objc private func didTapBackButton() {
        self.dismiss(animated: true)
    }

    private func setUpArticlesTableView() {
        let nib = UINib(nibName: "ArticlesCustomTableViewCell", bundle: nil)
        self.articlesTableView.register(nib, forCellReuseIdentifier: "ArticlesCustomTableViewCell")
        view.addSubview(articlesTableView)
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        articlesTableView.frame = view.bounds
    }

    private func getArticles() -> [CDArticle] {
       // Fetch data from Core Data to displayin the table View
       do {
           self.favouriteArticles = try context.fetch(CDArticle.fetchRequest())
           DispatchQueue.main.async {
               self.articlesTableView.reloadData()
           }
       } catch {
           print("An error while fetch some data from Core Data")
       }

        return favouriteArticles
   }
}

extension FavouriteArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteArticles.count
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
        cell.configureCoreData(with: favouriteArticles[indexPath.row])
        
//        cell.delegate = self
//        cell.tag = indexPath.row

        return cell
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // create swipe action
        let action = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in

            // Wich present to remove
            let articlesToRemove = self.favouriteArticles[indexPath.row]

            // Remove the articles + Save the data + Re-fetch the data
            MyCoreDataManager.shared.deleteCoreDataObjct(object: articlesToRemove, context: self.context) {
                self.getArticles()
            }
        }

        return UISwipeActionsConfiguration(actions: [action])
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        400
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if
            let stringURL = favouriteArticles[indexPath.row].webURL,
            let articleURL = URL(string: stringURL) {

            let articleTitle = favouriteArticles[indexPath.row].title
            let webVC = WebViewViewController(url: articleURL, title: articleTitle)
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
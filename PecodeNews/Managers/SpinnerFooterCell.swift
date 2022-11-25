//
//  SpinnerFooterCell.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 23.11.2022.
//

import UIKit

struct SpinnerFooterCell {
    static let shared = SpinnerFooterCell()
    private init() {}

    func createSpinnerFooter(viewController: UIViewController, tableView: UITableView) -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: viewController.view.frame.size.width, height: 50))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        // Check and delete if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
            tableView.tableFooterView = nil
        })

        return footerView
    }
}

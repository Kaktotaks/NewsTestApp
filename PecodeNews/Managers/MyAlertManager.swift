//
//  MyAlertManager.swift
//  PecodeNews
//
//  Created by Леонід Шевченко on 20.11.2022.
//

import UIKit

struct MyAlertManager {
    static let shared = MyAlertManager()

    private init() { }

    func presentTemporaryInfoAlert(
        title: String?,
        message: String?,
        preferredStyle: UIAlertController.Style,
        forTime: TimeInterval
    ) -> UIAlertController {
        let alertController: UIAlertController = .init(title: title,
                                                       message: message,
                                                       preferredStyle: preferredStyle
        )

        Timer.scheduledTimer(withTimeInterval: forTime,
                             repeats: false) {_ in
                alertController.dismiss(animated: true, completion: nil)
        }
        return alertController
    }
}

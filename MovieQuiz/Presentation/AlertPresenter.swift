//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by GiyaDev on 13.12.2023.
//

import UIKit

class AlertPresenter {
    weak var presentingViewController: UIViewController?
    var alertIdentifier: String? // переменная для идентификатора
    
    init(presentingViewController: UIViewController? = nil, alertIdentifier: String? = nil) {
        self.presentingViewController = presentingViewController
        self.alertIdentifier = alertIdentifier
    }
    
    func show(in vc: UIViewController, model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.competion()
        }
        alert.addAction(action)
        vc.present(alert, animated: true, completion: nil)
        alert.view.accessibilityIdentifier = self.alertIdentifier
    }

}


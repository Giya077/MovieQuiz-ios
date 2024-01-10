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
    
    func presentAlert(model: AlertModel) {
        let alertController = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.competion()
        }
        alertController.addAction(action)
        
        presentingViewController?.present(alertController, animated: true, completion: nil)
            alertController.view.accessibilityIdentifier = self.alertIdentifier
        
    }

}


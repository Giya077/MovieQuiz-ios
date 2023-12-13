//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by GiyaDev on 13.12.2023.
//

import UIKit

class AlertPresenter {
    weak var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController? = nil) {
        self.presentingViewController = presentingViewController
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
    }
}


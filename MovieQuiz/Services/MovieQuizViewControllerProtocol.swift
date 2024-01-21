//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by GiyaDev on 20.01.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    
    func show(quiz step: QuizStepViewModel)
    func show(quiz results: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func enableButtons(_ enable: Bool)
    
    func showNetworkError(message: String)
}

//
//  MovieQuizPresenterTests.swift
//  MovieQuizPresenterTests
//
//  Created by GiyaDev on 20.01.2024.
//
import Foundation
import XCTest
@testable import MovieQuiz


final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func enableButtons(_ enable: Bool) {
    }
    
    func show(quiz step: MovieQuiz.QuizStepViewModel) {
    }
    
    func show(quiz results: MovieQuiz.QuizResultsViewModel) {
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
    }
    
    func showLoadingIndicator() {
    }
    
    func hideLoadingIndicator() {
    }
    
    func showNetworkError(message: String) {
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let movieQuizPresenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = movieQuizPresenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by GiyaDev on 16.01.2024.
//

import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
   private let statisticService: StatisticService!
   private var questionFactory: QuestionFactoryProtocol?
   
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    private var currentQuestion: QuizQuestion?
    private var errorManager: ErrorManager?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticServiceImplementation()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
        errorManager = ErrorManager()
        
    }
    
    weak var viewController: (MovieQuizViewControllerProtocol)?
    
    // MARK: - QuestionFactoryDelegate
 
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        if let apiError = error as? ApiError {
            errorManager?.handleApiError(apiError)
        } else {
            viewController?.showNetworkError(message: error.localizedDescription)
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1 // ?
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        viewController?.enableButtons(true)
        viewController?.hideLoadingIndicator()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func proceedToNextQuestionOrResults() {
        viewController?.enableButtons(true)
        
            if self.isLastQuestion() {
                let text = correctAnswers == self.questionsAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
                
                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.show(quiz: viewModel)
            }
        else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }
    
    func makeResultsMessage() -> String {
                    statisticService.store(correct: correctAnswers, total: questionsAmount)
        
                    let bestGame = statisticService.bestGame
        
                    let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
                    let currentGameResultLine = "Ваш результат: \(correctAnswers)\\\(questionsAmount)"
                    let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
                    + " (\(bestGame.date.dateTimeString))"
                    let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        
                    let resultMessage = [
                        currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
                    ].joined(separator: "\n")
        
                    return resultMessage
    }
    
    func proceedWithAnswer(isCorrect: Bool) {
        viewController?.enableButtons(true)
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        viewController?.enableButtons(false)
    }
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer{
            correctAnswers += 1
        }
    }
    
}

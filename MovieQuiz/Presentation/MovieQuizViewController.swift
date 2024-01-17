import UIKit


final class MovieQuizViewController: UIViewController {
    //outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTextLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //Properties
    private var statisticService: StatisticService? // Экземпляр для работы с данными и статистикой
    private var isProcessinqQuestion = false //флаг по обработке след. вопроса для блок. и разблк. кнопки
    private var alertPresenter: AlertPresenter? // alert injection
    private var errorManager = ErrorManager()
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
        presenter.viewController = self
        
        statisticService = StatisticServiceImplementation()

        showLoadingIndicator()
        
        errorManager.showNetworkError = { [weak self] message in
            self?.showNetworkError(message: message)}
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent //меняем цвет status bara,  так же в info добавил ключ
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private functions
   
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
     func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)

            let bestGame = statisticService.bestGame

            let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            let currentGameResultLine = "Ваш результат: \(presenter.correctAnswers)\\\(presenter.questionsAmount)"
            let bestGameInfoLine = "Рекорд: \(bestGame.correct)\\\(bestGame.total)"
            + " (\(bestGame.date.dateTimeString))"
            let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"

            let resultMessage = [
                currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
            ].joined(separator: "\n")

            message = resultMessage
        }

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            presenter.resetQuestionIndex()
            self.presenter.restartGame()
        }

        alertPresenter?.show(in: self, model: model)
    }
    
    // приватный метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        guard !isProcessinqQuestion else {
            return
        }

        isProcessinqQuestion = true //флаг
                
        if isCorrect {
            presenter.correctAnswers += 1
        }

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            imageView.layer.borderColor = UIColor.clear.cgColor
            self.presenter.correctAnswers = presenter.correctAnswers
            self.presenter.showNextQuestionOrResults()
            self.isProcessinqQuestion = false // возращаю кнопку в исходное значение
        }
    }
    
//    private func showNextQuestionOrResults() {
//        enableButtons(false) //выкл.
//        
//        if presenter.isLastQuestion() {
//            // идём в состояние Результат квиза
//            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount) //вызываем статистику
//            alertResults(correctAnswers: correctAnswers, questionAmount: presenter.questionsAmount)
//        } else {
//            presenter.switchToNextQuestion() // ?
//            questionFactory?.requestNextQuestion() // ?
//            enableButtons(true) //включаю кнопку
//        }
//    }
    
//   private func restartRound() {
//       presenter.resetQuestionIndex()
//       presenter.correctAnswers = 0
//        enableButtons(true)
//        questionFactory?.requestNextQuestion()
//    }
    
    
    func enableButtons(_ enable: Bool) { //метод вкл,откл кнопок
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }
    
     func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
     func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
     }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let modelError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
//                self.presenter.resetQuestionIndex()
                self.presenter.restartGame()
//                self.presenter.didLoadDataFromServer() //кидаю новый запрос при восстановлении сети
        }
        
        alertPresenter?.show(in: self, model: modelError)
    }
}




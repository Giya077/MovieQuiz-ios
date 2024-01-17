import UIKit


final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //Properties
    private var correctAnswers = 0
    private var statisticService: StatisticService = StatisticServiceImplementation() // Экземпляр для работы с данными и статистикой
    
    private var isProcessinqQuestion = false //флаг по обработке след. вопроса для блок. и разблк. кнопки
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter? // alert injection
    
    private var errorManager = ErrorManager()
    
    private let presenter = MovieQuizPresenter()
    
    //outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTextLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
        
        alertPresenter = AlertPresenter(presentingViewController: self)

        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        
        questionFactory?.loadData()
        
        errorManager.showNetworkError = { [weak self] message in
            self?.showNetworkError(message: message)}
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        if let apiError = error as? ApiError {
            errorManager.handleApiError(apiError)
        } else {
            showNetworkError(message: error.localizedDescription)
        }
        hideLoadingIndicator()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent //меняем цвет status bara,  так же в info добавил ключ
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: true)}
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: false)
    }
    
    // MARK: - Private functions
   

    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func alertResults(correctAnswers: Int, questionAmount: Int) {
        let averageAccurancyString = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        let message = """
            Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
            Количество завершённых игр: \(statisticService.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) \((bestGame.date.dateTimeString))
            Средняя точность: \(averageAccurancyString)%
            """
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз",
            competion: { [weak self] in // замыкания на кнопку рестарт
                self?.restartRound()
            }
        )
        let alertPresenter = AlertPresenter(presentingViewController: self, alertIdentifier: "Game Results")
        alertPresenter.presentAlert(model: alertModel)
        
    }
    
    // приватный метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        guard !isProcessinqQuestion else {
            return
        }
        
        isProcessinqQuestion = true //флаг
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let isCorrect = isCorrect == currentQuestion.correctAnswer
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            print("ответ верный, количество правильных ответов: \(correctAnswers) из \(presenter.questionsAmount)")
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            print("ответ не верный, количество правильных ответов: \(correctAnswers) из \(presenter.questionsAmount)")
        }
//        presenter.switchToNextQuestion()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //добавил задержку
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor // Сброс цвета рамки перед отображением следующего вопроса
            self.showNextQuestionOrResults()
            self.isProcessinqQuestion = false // возращаю кнопку в исходное значение
        }
    }
    
    private func showNextQuestionOrResults() {
        enableButtons(false) //выкл.
        
        if presenter.isLastQuestion() {
            // идём в состояние Результат квиза
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount) //вызываем статистику
            alertResults(correctAnswers: correctAnswers, questionAmount: presenter.questionsAmount)
        } else {
            presenter.switchToNextQuestion() // ?
            questionFactory?.requestNextQuestion() // ?
            enableButtons(true) //включаю кнопку
        }
    }
    
   private func restartRound() {
       presenter.resetQuestionIndex()
        correctAnswers = 0
        enableButtons(true)
        questionFactory?.requestNextQuestion()
    }
    
    
    private func enableButtons(_ enable: Bool) { //метод вкл,откл кнопок
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
     }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let modelError = AlertModel(
            title: "Ошибка",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else {return}
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                
                showLoadingIndicator()
                self.questionFactory?.loadData() //кидаю новый запрос при востановлении сети
        }
        alertPresenter?.presentAlert(model: modelError)
    }
    
}




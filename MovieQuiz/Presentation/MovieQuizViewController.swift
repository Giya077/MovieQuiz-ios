import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statisticService: StatisticService = StatisticServiceImplementation() // Экземпляр для работы с данными и статистикой
    
    private var isProcessinqQuestion = false //флаг по обработке след. вопроса для блок. и разблк. кнопки
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter? // alert injection
    
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
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent //меняем цвет status bara,  так же в info добавил ключ
    }
    
    //actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: true)}
    
    // метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),//Инициализирую картинку с помощью конструктора UIImage(named: )
            question: model.text, //забираем уже готовый вопрос из мокового вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") //Высчитываем номер вопроса с помощью переменной текущего вопроса currentQuestionIndex
    }
    
    private func showNextQuestionOrResults() {
        enableButtons(false) //выкл.
        
        if currentQuestionIndex == questionsAmount {
            // идём в состояние Результат квиза
            statisticService.store(correct: correctAnswers, total: questionsAmount) //вызываем статистику
            alertResults(correctAnswers: correctAnswers, questionAmount: questionsAmount)
        } else {
            self.questionFactory?.requestNextQuestion()
            enableButtons(true) //включаю кнопку
        }
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
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        currentQuestionIndex += 1
        print("кол-во правильных ответов \(correctAnswers)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //добавил задержку
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor // Сброс цвета рамки перед отображением следующего вопроса
            self.showNextQuestionOrResults()
            self.isProcessinqQuestion = false // возращаю кнопку в исходное значение
        }
    }
    
    private func alertResults(correctAnswers: Int, questionAmount: Int) {
        let averageAccurancyString = String(format: "%.2f", statisticService.totalAccuracy)
        let bestGame = statisticService.bestGame
        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
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
        alertPresenter?.presentAlert(model: alertModel)
    }
    
   private func restartRound() {
        //            statisticService.store(correct: correctAnswers, total: questionsAmount)
        currentQuestionIndex = 0
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
        activityIndicator.stopAnimating()
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let modelError = AlertModel(
            title: "Ошибка",
            message: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else {return}
                
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.showLoadingIndicator() // включаю анимацию
                self.questionFactory?.loadData() //кидаю новый запрос при востановлении сети
        }
        alertPresenter?.presentAlert(model: modelError)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
}




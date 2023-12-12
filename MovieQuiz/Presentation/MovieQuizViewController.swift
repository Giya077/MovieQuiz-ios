import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    //Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var isProcessinqQuestion = false //флаг по обработке след. вопроса для блок. и разблк. кнопки
    
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    //outlets
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var questionTextLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet weak private var yesButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
        
        if let firstQuestion = self.questionFactory.requestNextQuestion() {
            self.currentQuestion = firstQuestion
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        showNextQuestionOrResults()
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        <#code#>
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent //меняем цвет status bara,  так же в info добавил ключ
    }
    
    //actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
            guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: false)}
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard currentQuestion != nil else {
            return
        }
        showAnswerResult(isCorrect: true)}
    
    //private methods
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    // приватный метод конвертации, который принимает моковый вопрос и возвращает вью модель для главного экрана
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),//Инициализирую картинку с помощью конструктора UIImage(named: )
            question: model.text, //забираем уже готовый вопрос из мокового вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") //Высчитываем номер вопроса с помощью переменной текущего вопроса currentQuestionIndex
        return questionStep
    }
    
    private func showNextQuestionOrResults() {
        enableButtons(false) //выкл.
        
        if currentQuestionIndex == questionsAmount {
            // идём в состояние Результат квиза
            showQuizResultsAlert(buttonTitle: "Сыграть ещё раз")
        } else {
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
                enableButtons(true) //включаю кнопку
            }
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
        print("кол-во правильных ответов \(correctAnswers)") //понимаю что логика работает
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in //добавил задержку
            guard let self = self else { return }
            self.imageView.layer.borderColor = UIColor.clear.cgColor // Сброс цвета рамки перед отображением следующего вопроса
            self.showNextQuestionOrResults()
            self.isProcessinqQuestion = false // возращаю кнопку в исходное значение
        }
    }
    
    private func showQuizResultsAlert(buttonTitle: String) {
        let currentDate = Date() // текущая дата и время
        let dateFormatter = DateFormatter() // форматтер для преобразования даты в строку
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let formattedDate = dateFormatter.string(from: currentDate) // преобразуем текущую дату в строку
        
        var averagePercentage: Int //средний процент правильных ответов
        if questionsAmount > 0 {
            averagePercentage = correctAnswers * 100 / questionsAmount //count полюбому надо
        } else {
            averagePercentage = 0
        }
        
        let alert = UIAlertController(
            title: "Этот раунд окончен!",
            message: "Ваш результат: \(correctAnswers) из \(questionsAmount)\nТочность: \(averagePercentage)% \nВремя: \(formattedDate)",
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonTitle, style: .default) { [weak self] _ in
            guard let self = self else {return}
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0 // Здесь обнуляем correctAnswers перед переходом на новый раунд
            self.enableButtons(true) //включаю кнопки на след. раунд
            if let firstQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = firstQuestion
                // заново показываем первый вопрос
                let viewModel = self.convert(model: firstQuestion) // заново показываем первый вопрос
                self.show(quiz: viewModel) // заново показываем первый вопрос // мб self не надо!!!!!
            }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func enableButtons(_ enable: Bool) { //метод вкл,откл кнопок
        noButton.isEnabled = enable
        yesButton.isEnabled = enable
    }
}




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
    private var statisticService: StatisticService?
    var isProcessinqQuestion = false //флаг по обработке след. вопроса для блок. и разблк. кнопки
    private var alertPresenter: AlertPresenter? // alert injection
    private var errorManager = ErrorManager()
    private var presenter: MovieQuizPresenter!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(presentingViewController: self)
        showLoadingIndicator()
        
//        presenter.viewController = self
//        statisticService = StatisticServiceImplementation()
//        errorManager.showNetworkError = { [weak self] message in
//        self?.showNetworkError(message: message)}
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
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        questionTextLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()

        let alert = UIAlertController(
            title: result.title,
            message: message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        alert.view.accessibilityIdentifier = "GameResultsAlert"
        
        alert.addAction(action)
        
        alertPresenter?.alertIdentifier = "Game Results"
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
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
        imageView.layer.borderColor = UIColor.clear.cgColor
        showLoadingIndicator()
        enableButtons(false)
        
        
        let modelError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
            
                self.presenter.restartGame()
        }
        
        alertPresenter?.show(in: self, model: modelError)
    }
}




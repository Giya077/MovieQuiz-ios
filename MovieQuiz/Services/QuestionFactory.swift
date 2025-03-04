//
//  QuestionFactory.swift
//  MovieQuiz
//
//

import UIKit

class QuestionFactory: QuestionFactoryProtocol {

    private let moviesLoader: MoviesLoading
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items // сохраняем фильм в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case.failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке MovieQuizViewController
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in /* запускаем код в другом потоке global*/
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else  { return }
            
            //            var imageData = Data() /* по умолчанию будут пустые данные*/
            
            do {
                let imageData = try Data(contentsOf: movie.resizedImageURL)
                
                let rating = Float(movie.rating) ?? 0 // превращаем строку в число
                let text = "Рейтинг этого фильма больше чем 7?"
                let correctAnswer = rating > 7
                
                let question = QuizQuestion( //Создаём вопрос, определяем его корректность и создаём модель вопроса
                    image: imageData,
                    text: text,
                    correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in //когда загрузка и обработка данных завершена, пора вернуться в главный поток main
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
            } catch {
                // Ошибка загрузки изображения
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let errorMessage = "Failed to load data: \(error.localizedDescription)"
                    self.delegate?.didFailToLoadData(with: NSError(domain: "com.yourapp", code: 1, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                }
            }
        }
    }
}

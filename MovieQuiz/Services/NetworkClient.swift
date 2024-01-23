//
//  NetworkClient.swift
//  MovieQuiz
//
//  Created by GiyaDev on 27.12.2023.
//

import Foundation

protocol NetworkRouting {
    func fetch(url:URL, handler: @escaping (Result<Data,Error>) -> Void)
}


/// Отвечает за загрузку данных по URL
struct NetworkClient: NetworkRouting {

    private enum NetworkError: Error {
        case codeError
    }
    weak var delegate: QuestionFactoryDelegate?
    var errorManager: ErrorManager?
    
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) { //успех data, ошибка error
        let request = URLRequest(url: url) // создаём запрос из url
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Проверяем, пришла ли ошибка
            if let error = error {
                self.errorManager?.handleApiError(ApiError.unexpectedResponse)
                self.delegate?.didFailToLoadData(with: error) //ошибка
                handler(.failure(error))
                return
            }
            
            // Проверяем, что нам пришёл успешный код ответа
            if let response = response as? HTTPURLResponse, /*URLResponse — это базовый тип ответа на все сетевые протоколы*/
                response.statusCode < 200 || response.statusCode >= 300 {
                self.errorManager?.handleApiError(ApiError.unexpectedResponse)
                self.delegate?.didFailToLoadData(with: NetworkError.codeError)
                handler(.failure(NetworkError.codeError))
                return
            }
            
            // Возвращаем данные
            guard let data = data else { return }
            handler(.success(data))
        }
        
        task.resume()
    }
} 

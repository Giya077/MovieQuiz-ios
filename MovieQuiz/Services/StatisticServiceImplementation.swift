//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by GiyaDev on 18.12.2023.
//

import Foundation

class StatisticServiceImplementation: StatisticService {
    // Приватные свойства для хранения данных
    private var correctAnswers = 0
    private var totalQuestions = 0
    private let userDefaults = UserDefaults.standard // UserDefaults для хранения данных
    
    init() {
        gamesCount = 0
    }

    var totalAccuracy: Double { //свойство для общей точности
        guard totalQuestions > 0 else {
            return 0
        }
        return Double(correctAnswers * 100) / Double(totalQuestions)
    }

    //подсчет количества завершенных игр
    var gamesCount: Int {
        get {
            return userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                // Если данных нет, возвращаем начальное значение
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            //новый результат в Data и сохраняем в UserDefaults
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    //свойство для средней точности
    var averageAccuracy: Double {
        guard gamesCount > 0 else {
            return 0
        }
        return totalAccuracy / Double(gamesCount)
    }

    //сохранения результатов текущей игры
    func store(correct count: Int, total amount: Int) {
        let currentGameRecord = GameRecord(correct: count, total: amount, date: Date())
        // Получаем сохраненный рекорд из UserDefaults
        let storedGameRecord = userDefaults.codable(forKey: Keys.bestGame.rawValue, as: GameRecord.self) ?? GameRecord(
            correct: 0,
            total: 0,
            date: Date(timeIntervalSince1970: 0))
        // Если новый результат лучше, обновляем рекорд
        if currentGameRecord.isBetterThan(storedGameRecord) {
            userDefaults.setCodable(currentGameRecord, forKey: Keys.bestGame.rawValue)
        }
        // Обновляем общее количество правильных ответов и вопросов
        correctAnswers += count
        totalQuestions += amount
        gamesCount += 1
    }
}

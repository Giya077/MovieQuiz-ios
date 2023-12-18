//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by GiyaDev on 18.12.2023.
//

import Foundation

protocol StatisticService {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
    
    func store(correct count: Int, total amount: Int)
}



struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool { // метод сравнения по количеству верных ответов
        correct > another.correct
    }
}


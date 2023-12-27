//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by GiyaDev on 11.12.2023.
//

import Foundation

struct QuizQuestion { //преобразование данных из структуры вопроса QuizQuestion во вью модель для экрана QuizStepViewModel.
    let image: Data
    let text: String
    let correctAnswer: Bool
}

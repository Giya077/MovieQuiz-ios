//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by GiyaDev on 12.12.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
func didReceiveNextQuestion(question: QuizQuestion?)
}

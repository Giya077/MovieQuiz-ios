//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by GiyaDev on 12.12.2023.
//  QuestionFactoryDelegate Это протокол, через который QuestionFactory общается с нашим MovieQuizViewController

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
func didReceiveNextQuestion(question: QuizQuestion?)
func didLoadDataFromServer() // сообщение об успешной загрузке
func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
}

//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by GiyaDev on 13.12.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let competion: () -> Void
}

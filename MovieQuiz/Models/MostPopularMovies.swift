//
//  MostPopularMovies.swift
//  MovieQuiz
//
//  Created by GiyaDev on 27.12.2023.
//

import Foundation

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
//Чтобы преобразовать JSON в Swift-структуру, нужно чтобы она реализовала протокол Codable. Если имена полей в JSON не совпадают с именами полей в структуре данных, надо указать, какое поле в JSON соответствует полю в структуре. То есть конечный вид структур будет выглядеть так:

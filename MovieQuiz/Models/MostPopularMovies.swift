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
    
    var resizedImageURL: URL {
        // создаем строку из адреса
        let urlString = imageURL.absoluteString
        //  обрезаем лишнюю часть и добавляем модификатор желаемого качества
        let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
        // пытаемся создать новый адрес, если не получается возвращаем старый
        guard let newURL = URL(string: imageUrlString) else {
            return imageURL
        }
        return newURL
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "fullTitle"
        case rating = "imDbRating"
        case imageURL = "image"
    }
}
//Чтобы преобразовать JSON в Swift-структуру, нужно чтобы она реализовала протокол Codable. Если имена полей в JSON не совпадают с именами полей в структуре данных, надо указать, какое поле в JSON соответствует полю в структуре. То есть конечный вид структур будет выглядеть так:

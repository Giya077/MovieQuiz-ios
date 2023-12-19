//
//  UserDefaults + Extension.swift
//  MovieQuiz
//
//  Created by GiyaDev on 18.12.2023.
//

import Foundation

extension UserDefaults {
    func setCodable<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            set(encoded, forKey: key)
        }
    }
    
    func codable<T: Codable>(forKey key: String,as type: T.Type) -> T? {
        if let data = data(forKey: key) {
            let decoder = JSONDecoder()
            return try? decoder.decode(type, from: data)
        }
        return nil
    }
}

//setCodable: Кодирует объект типа T с использованием JSONEncoder и сохраняет закодированные данные в UserDefaults по ключу.
//codable: Получает данные из UserDefaults по ключу и декодирует их в объект типа T с использованием JSONDecoder.

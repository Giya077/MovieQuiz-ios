//
//  ErrorManager.swift
//  MovieQuiz
//
//  Created by GiyaDev on 02.01.2024.
//

import UIKit

enum ApiError: Error {
    case invalidApiKey
    case requestsLimitExceeded
    case unexpectedResponse
}

class ErrorManager {
    var showNetworkError: ((String) -> Void)?
    
    func handleApiError(_ apiError: ApiError) {
        var errorMessage = ""
        
        switch apiError {
        case.invalidApiKey:
            errorMessage = "Invalid API Key. Please check your settings."
        case.requestsLimitExceeded:
            errorMessage = "Requests limit exceeded. Please try again later."
        case .unexpectedResponse:
            errorMessage = "Unexpected response from the server."
        }
        showNetworkError?(errorMessage)
    }
}

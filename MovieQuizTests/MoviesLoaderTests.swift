//
//  MoviesLoaderTests.swift
//  MovieQuizTests
//
//  Created by GiyaDev on 08.01.2024.
//


import XCTest

@testable import MovieQuiz

class MoviesLoaderTests: XCTestCase {
    func testSuccessLoading() throws {
    // Given
        let stubNetworkClient = StubNetworkClient(emulateError: false) // не хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        
    // When
        let expectation = expectation(description: "Loading Expectation")
        
        loader.loadMovies { result in
    // Then
            switch result {
            case .success(let movies):
                //проверим, что пришло, например, два фильма — ведь в тестовых данных их всего два
                XCTAssertEqual(movies.items.count, 2)
                expectation.fulfill()
            case.failure(_):
                XCTFail("Unexpected Failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
    
    func testFailureLoading() throws {
        // Given
        let stubNetworkClient = StubNetworkClient(emulateError: true) // хотим эмулировать ошибку
        let loader = MoviesLoader(networkClient: stubNetworkClient)
        // When
        let expectation = expectation(description: "Loading Expectation")
        
        loader.loadMovies { result in
        // Then
            switch result {
            case.failure(let error):
                XCTAssertNotNil(error)
                expectation.fulfill()
            case.success(_):
                XCTFail("Unexpected failure")
            }
        }
        waitForExpectations(timeout: 1)
    }
}

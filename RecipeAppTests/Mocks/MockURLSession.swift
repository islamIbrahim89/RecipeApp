//
//  MockURLSession.swift
//  RecipeAppTests
//
//  Created by islam moussa on 05/02/2025.
//

import Foundation
@testable import RecipeApp


class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, response)
    }
}


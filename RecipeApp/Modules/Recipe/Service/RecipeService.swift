//
//  RecipeService.swift
//  RecipeApp
//
//  Created by islam moussa on 05/02/2025.
//

import Foundation

protocol RecipeServiceProtocol {
    func fetchRecipes(limit: Int, skip: Int) async throws -> RecipeResponse
    func searchRecipes(query: String) async throws -> RecipeResponse
}

class RecipeService: RecipeServiceProtocol {
    private let baseURL = "https://dummyjson.com/recipes"
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    private func fetchData<T: Decodable>(from urlString: String, responseType: T.Type) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw RecipeServiceError.badURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw RecipeServiceError.serverError
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw RecipeServiceError.mappingError
        }
    }
    
    func fetchRecipes(limit: Int, skip: Int) async throws -> RecipeResponse {
        let urlString = "\(baseURL)?limit=\(limit)&skip=\(skip)&sortBy=name&order=asc"
        return try await fetchData(from: urlString, responseType: RecipeResponse.self)
    }
    
    func searchRecipes(query: String) async throws -> RecipeResponse {
        let urlString = "\(baseURL)/search?q=\(query)"
        return try await fetchData(from: urlString, responseType: RecipeResponse.self)
    }
}

enum RecipeServiceError: Error, LocalizedError {
    case badURL
    case mappingError
    case serverError

    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL. Please check your request."
        case .mappingError:
            return "Something went wrong. Please try again."
        case .serverError:
            return "Server error. Please try again later."
        }
    }
}

protocol URLSessionProtocol {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

//
//  MockRecipeService.swift
//  RecipeAppTests
//
//  Created by islam moussa on 05/02/2025.
//

import Foundation
import Combine
@testable import RecipeApp

class MockRecipeService: RecipeServiceProtocol {
    var fetchRecipesResult: Result<RecipeResponse, Error>?
    var searchRecipesResult: Result<RecipeResponse, Error>?

    func fetchRecipes(limit: Int, skip: Int) async throws -> RecipeResponse {
        if let result = fetchRecipesResult {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
        throw RecipeServiceError.serverError
    }

    func searchRecipes(query: String) async throws -> RecipeResponse {
        if let result = searchRecipesResult {
            switch result {
            case .success(let response):
                return response
            case .failure(let error):
                throw error
            }
        }
        throw RecipeServiceError.serverError
    }
}

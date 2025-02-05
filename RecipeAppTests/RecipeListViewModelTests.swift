//
//  RecipeListViewModelTests.swift
//  RecipeAppTests
//
//  Created by islam moussa on 05/02/2025.
//

import XCTest
import Combine
@testable import RecipeApp

@MainActor
class RecipeListViewModelTests: XCTestCase {

    var viewModel: RecipeListViewModel!
    var mockService: MockRecipeService!
    
    override func setUp() {
        super.setUp()
        mockService = MockRecipeService()
        viewModel = RecipeListViewModel(service: mockService)
    }

    override func tearDown() {
        viewModel = nil
        mockService = nil
        super.tearDown()
    }
    
    func testFetchRecipes_Success() async {
        let mockRecipes = [Recipe(id: 1, name: "Pasta",
                                  ingredients: [], instructions: [], image: ""),
                           Recipe(id: 2, name: "Pizza",
                                  ingredients: [], instructions: [], image: "")]
        mockService.fetchRecipesResult = .success(RecipeResponse(recipes: mockRecipes, total: 2, skip: 0, limit: 10))

        await viewModel.fetchRecipes()

        XCTAssertEqual(viewModel.recipes.count, 2)
        XCTAssertEqual(viewModel.recipes.first?.name, "Pasta")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }
    
    func testFetchRecipes_EmptyResponse() async {
        mockService.fetchRecipesResult = .success(RecipeResponse(recipes: [], total: 0, skip: 0, limit: 10))

        let expectation = XCTestExpectation(description: "Wait for errorMessage to be updated")

        let cancellable = viewModel.$emptyMessage
            .dropFirst() // Skip initial nil state
            .sink { errorMessage in
                if errorMessage == "No Recipes Found." {
                    expectation.fulfill() // Mark expectation as fulfilled
                }
            }

        await viewModel.fetchRecipes()

        await fulfillment(of: [expectation], timeout: 2.0) // Wait for async update

        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.emptyMessage, "No Recipes Found.")
        XCTAssertFalse(viewModel.hasMoreData)

        cancellable.cancel()
    }

    
    func testFetchRecipes_Failure() async {
        mockService.fetchRecipesResult = .failure(RecipeServiceError.serverError)

        await viewModel.fetchRecipes()

        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.errorMessage, "Server error. Please try again later.")
    }
    
    func testSearchRecipes_Success() async {
        let mockRecipes = [Recipe(id: 3, name: "Chocolate Cake", ingredients: [], instructions: [], image: "")]
        mockService.searchRecipesResult = .success(RecipeResponse(recipes: mockRecipes, total: 0, skip: 0, limit: 10))

        viewModel.searchText = "Cake"
        await viewModel.searchRecipes()

        XCTAssertEqual(viewModel.recipes.count, 1)
        XCTAssertEqual(viewModel.recipes.first?.name, "Chocolate Cake")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchRecipes_NoResults() async {
        mockService.searchRecipesResult = .success(RecipeResponse(recipes: [], total: 0, skip: 0, limit: 10))

        viewModel.searchText = "xyz"
        await viewModel.searchRecipes()

        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.emptyMessage, "No Recipes Found.")
    }
    
    func testSearchRecipes_Failure() async {
        mockService.searchRecipesResult = .failure(RecipeServiceError.serverError)

        viewModel.searchText = "Cake"
        await viewModel.searchRecipes()

        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.errorMessage, "Server error. Please try again later.")
    }

    func testResetPagination() {
        viewModel.recipes = [Recipe(id: 1, name: "Pasta", ingredients: [], instructions: [], image: "")]
        viewModel.skip = 10
        viewModel.hasMoreData = false

        viewModel.resetPagination()

        XCTAssertEqual(viewModel.recipes.count, 0)
        XCTAssertEqual(viewModel.skip, 0)
        XCTAssertTrue(viewModel.hasMoreData)
    }
}


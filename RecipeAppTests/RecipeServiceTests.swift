//
//  RecipeServiceTests.swift
//  RecipeAppTests
//
//  Created by islam moussa on 03/02/2025.
//

import XCTest
@testable import RecipeApp

class RecipeServiceTests: XCTestCase {
    
    var recipeService: RecipeService!
    var mockSession: MockURLSession!

    override func setUp() {
        super.setUp()
        mockSession = MockURLSession()
        recipeService = RecipeService(session: mockSession)
    }

    override func tearDown() {
        recipeService = nil
        mockSession = nil
        super.tearDown()
    }
    
    func testFetchRecipes_Success() async throws {
        // Mocked JSON Response
        let mockJSON = """
        {
            "recipes": [
                {"id": 1, "name": "Pasta", "image": "", "ingredients": [], "instructions": []},
                {"id": 2, "name": "Pizza", "image": "",  "ingredients": [], "instructions": []}
            ],
            "total": 2,
            "skip": 0,
            "limit": 10
        }
        """.data(using: .utf8)!

        mockSession.mockData = mockJSON
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        let response = try await recipeService.fetchRecipes(limit: 10, skip: 0)

        XCTAssertEqual(response.recipes.count, 2)
        XCTAssertEqual(response.recipes.first?.name, "Pasta")
    }

    func testFetchRecipes_Failure_ServerError() async {
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com")!,
                                                   statusCode: 500,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        mockSession.mockData = Data() // Empty response

        do {
            _ = try await recipeService.fetchRecipes(limit: 10, skip: 0)
            XCTFail("Expected a server error but got a success response")
        } catch let error as RecipeServiceError {
            XCTAssertEqual(error, .serverError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSearchRecipes_Success() async throws {
        let mockJSON = """
        {
            "recipes": [
                {"id": 1, "name": "Chocolate Cake", "image": "", "ingredients": [], "instructions": []}
            ],
            "total": 1,
            "skip": 0,
            "limit": 10
        }
        """.data(using: .utf8)!
        
        mockSession.mockData = mockJSON
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)
        
        let response = try await recipeService.searchRecipes(query: "Cake")
        
        XCTAssertEqual(response.recipes.count, 1)
        XCTAssertEqual(response.recipes.first?.name, "Chocolate Cake")
    }
    
    func testFetchRecipes_Failure_BadURL() async {
        mockSession.mockError = RecipeServiceError.badURL

        do {
            _ = try await recipeService.fetchRecipes(limit: 10, skip: 0)
            XCTFail("Expected bad URL error")
        } catch let error as RecipeServiceError {
            XCTAssertEqual(error, .badURL)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testFetchRecipes_Failure_MappingError() async {
        let invalidJSON = "Invalid JSON".data(using: .utf8)!

        mockSession.mockData = invalidJSON
        mockSession.mockResponse = HTTPURLResponse(url: URL(string: "https://dummyjson.com")!,
                                                   statusCode: 200,
                                                   httpVersion: nil,
                                                   headerFields: nil)

        do {
            _ = try await recipeService.fetchRecipes(limit: 10, skip: 0)
            XCTFail("Expected mapping error")
        } catch let error as RecipeServiceError {
            XCTAssertEqual(error, .mappingError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}



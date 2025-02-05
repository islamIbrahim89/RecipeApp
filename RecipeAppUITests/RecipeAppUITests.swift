//
//  RecipeAppUITests.swift
//  RecipeAppUITests
//
//  Created by islam moussa on 03/02/2025.
//

import XCTest

final class RecipeAppUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testRecipeList_LoadsSuccessfully() {
        let list = app.collectionViews["RecipeList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Recipe list should appear.")
    }

    func testSearchRecipes_ShowsResults() {
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.exists, "Search bar should exist.")
        
        searchField.tap()
        searchField.typeText("Pizza\n") // Simulates entering "Pizza"
        
        let pizzaCell = app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "Pizza")).firstMatch
        XCTAssertTrue(pizzaCell.waitForExistence(timeout: 5), "Search should return 'Pizza'.")
    }

    
    func testSearch_NoResults_ShowsErrorMessage() {
        let searchField = app.textFields["Search"]
        XCTAssertTrue(searchField.exists, "Search field should exist.")
        
        searchField.tap()
        searchField.typeText("xyz123\n") // Assuming this returns no results

        let noResultsText = app.staticTexts["No Recipes Found."]
        XCTAssertTrue(noResultsText.waitForExistence(timeout: 5), "Should display 'No Recipes Found.'")
    }

    func testPullToRefreshIndicator() {
        let recipeList = app.collectionViews["RecipeList"]
        let refreshIndicator = app.activityIndicators.firstMatch // Detects the spinning loader

        // Ensure the recipe list is loaded
        XCTAssertTrue(recipeList.exists, "Recipe list should exist")

        // Simulate pull-to-refresh
        recipeList.swipeDown()

        // 1. Check if refresh indicator appears
        XCTAssertTrue(refreshIndicator.waitForExistence(timeout: 2), "Refresh indicator should appear")
    }

    func testScrollToBottom_LoadsMoreRecipes() {
        let list = app.collectionViews["RecipeList"]
        XCTAssertTrue(list.waitForExistence(timeout: 5), "Recipe list should be visible.")
        
        let initialCount = list.cells.count

        for _ in 0...(initialCount / 5) {
            list.swipeUp()
        }
        
        sleep(3) // Allow API to load more items
        
        let newCount = list.cells.count
        XCTAssertGreaterThan(newCount, initialCount, "Scrolling should load more recipes.")
    }

    func testNavigationToRecipeDetail() {
        let firstRecipe = app.collectionViews["RecipeList"].cells.firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5), "First recipe should exist.")

        firstRecipe.tap()
        
        let detailTitle = app.navigationBars.firstMatch
        XCTAssertTrue(detailTitle.exists, "Navigating should show Recipe Detail screen.")
    }

    func testRecipeDetail_ShowsIngredientsAndInstructions() {
        let firstRecipe = app.collectionViews["RecipeList"].cells.firstMatch
        XCTAssertTrue(firstRecipe.waitForExistence(timeout: 5), "First recipe should exist.")

        firstRecipe.tap()

        let detailTitle = app.navigationBars.firstMatch
        XCTAssertTrue(detailTitle.exists, "Should be on Recipe Detail screen.")

        // Check if "Ingredients" section is displayed
        let ingredientsTitle = app.staticTexts["Ingredients:"]
        XCTAssertTrue(ingredientsTitle.waitForExistence(timeout: 5), "Ingredients should be visible.")

        // Check if "Instructions" section is displayed
        let instructionsTitle = app.staticTexts["Instructions:"]
        XCTAssertTrue(instructionsTitle.waitForExistence(timeout: 5), "Instructions should be visible.")
    }

}



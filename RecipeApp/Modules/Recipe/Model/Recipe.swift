//
//  Recipe.swift
//  RecipeApp
//
//  Created by islam moussa on 05/02/2025.
//

import Foundation

struct Recipe: Identifiable, Decodable {
    let id: Int
    let name: String
    let ingredients: [String]
    let instructions: [String]
    let image: String
}

struct RecipeResponse: Decodable {
    let recipes: [Recipe]
    let total: Int
    let skip: Int
    let limit: Int
}

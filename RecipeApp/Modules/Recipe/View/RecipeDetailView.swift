//
//  RecipeDetailView.swift
//  RecipeApp
//
//  Created by islam moussa on 03/02/2025.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    var body: some View {
        ScrollView {
            Text(recipe.name)
                .font(.largeTitle)
                .minimumScaleFactor(0.5)
            VStack {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 200)
                
                VStack(alignment: .leading) {
                    Text("Ingredients:")
                        .font(.title2)
                        .padding(.vertical)
                    ForEach(recipe.ingredients, id: \.self) {
                        Text($0)
                    }
                    
                    Text("Instructions:")
                        .font(.title2)
                        .padding(.vertical)
                    ForEach(recipe.instructions, id: \.self) {
                        Text($0)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}



#Preview {
    RecipeDetailView(recipe: Recipe(id: 1, name: "Korean Bibimbap",
                                    ingredients: [
                                        "Cooked white rice",
                                        "Beef bulgogi (marinated and grilled beef slices)",
                                        "Carrots, julienned and sautéed",
                                        "Spinach, blanched and seasoned",
                                        "Zucchini, sliced and grilled",
                                        "Bean sprouts, blanched",
                                        "Fried egg",
                                        "Gochujang (Korean red pepper paste)",
                                        "Sesame oil",
                                        "Toasted sesame seeds"
                                    ],
                                    instructions:[
                                        "Arrange cooked white rice in a bowl.",
                                        "Top with beef bulgogi, sautéed carrots, seasoned spinach, grilled zucchini, and blanched bean sprouts.",
                                        "Place a fried egg on top and drizzle with gochujang and sesame oil.",
                                        "Sprinkle with toasted sesame seeds before serving.",
                                        "Mix everything together before enjoying this delicious Korean bibimbap!",
                                        "Feel free to customize with additional vegetables or protein."
                                    ], image: "https://cdn.dummyjson.com/recipe-images/18.webp"))
}

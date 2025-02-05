//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by islam moussa on 03/02/2025.
//

import SwiftUI

struct RecipeListView: View {
    @StateObject private var viewModel = RecipeListViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.recipes.isEmpty && !viewModel.isLoading {
                    VStack {
                        Image(systemName: "tray.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No Recipes Found.")
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.recipes) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                HStack {
                                    AsyncImage(url: URL(string: recipe.image)) { image in
                                        image.resizable().scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(width: 50, height: 50)
                                    
                                    VStack(alignment: .leading) {
                                        Text(recipe.name)
                                            .font(.headline)
                                    }
                                }
                            }
                            .onAppear {
                                if recipe.id == viewModel.recipes.last?.id {
                                    Task { await viewModel.fetchRecipes() }
                                }
                            }
                        }
                        
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                    .accessibilityIdentifier("RecipeList")
                    .task {
                        await viewModel.fetchRecipes()
                    }
                    .refreshable {
                        await viewModel.fetchRecipes(reset: true)
                    }
                }
            }
            .navigationTitle("Recipes")
        }
    }
}






#Preview {
    RecipeListView()
}

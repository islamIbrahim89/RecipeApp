//
//  RecipeListView.swift
//  RecipeApp
//
//  Created by islam moussa on 03/02/2025.
//

import SwiftUI

struct RecipesView: View {
    @StateObject var viewModel = RecipeListViewModel()

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText)
                
                if let errorMessage = viewModel.errorMessage {
                    ErrorMessageView(message: errorMessage)
                } else if let emptyMessage = viewModel.emptyMessage {
                    EmptyStateView(message: emptyMessage)
                } else {
                    RecipeListView(viewModel: viewModel)
                }
            }
            .navigationTitle("Recipes")
        }
    }
}

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeListViewModel

    var body: some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                RecipeCell(recipe: recipe)
                    .onAppear {
                        if recipe.id == viewModel.recipes.last?.id {
                            Task { await viewModel.fetchRecipes() }
                        }
                    }
            }

            if viewModel.isLoading {
                LoadingView()
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

struct RecipeCell: View {
    let recipe: Recipe

    var body: some View {
        NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
            HStack {
                AsyncImage(url: URL(string: recipe.image)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.headline)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

struct ErrorMessageView: View {
    let message: String

    var body: some View {
        VStack {
            Text(message)
                .foregroundColor(.red)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView: View {
    let message: String
    
    var body: some View {
        VStack {
            Image(systemName: "tray.fill")
                .font(.largeTitle)
                .foregroundColor(.gray)
            Text(message)
                .foregroundColor(.gray)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct LoadingView: View {
    var body: some View {
        HStack {
            Spacer()
            ProgressView()
            Spacer()
        }
    }
}





#Preview {
    RecipesView()
}

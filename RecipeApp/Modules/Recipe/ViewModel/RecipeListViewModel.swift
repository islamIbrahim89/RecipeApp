//
//  RecipeViewModel.swift
//  RecipeApp
//
//  Created by islam moussa on 03/02/2025.
//
import Foundation
import Combine

@MainActor
class RecipeListViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var hasMoreData: Bool = true
    @Published var errorMessage: String? = nil
    @Published var emptyMessage: String? = nil
    
    private let service: RecipeServiceProtocol
    private var limit = 10
    var skip = 0
    private var cancellables = Set<AnyCancellable>()
    
    init(service: RecipeServiceProtocol = RecipeService()) {
        self.service = service
        setupSearchListener()
    }
    
    private func setupSearchListener() {
        $searchText
            .throttle(for: .milliseconds(400), scheduler: DispatchQueue.main, latest: true)
            .removeDuplicates()
            .sink { [weak self] newText in
                guard let self = self else { return }
                Task { await self.handleSearch(text: newText) }
            }
            .store(in: &cancellables)
    }
    
    private func handleSearch(text: String) async {
        if text.count >= 2 {
            await searchRecipes()
        } else if text.isEmpty {
            resetPagination()
            await fetchRecipes()
        }
    }

    func fetchRecipes(reset: Bool = false) async {
        if reset {
            resetPagination()
        }
        guard !isLoading && hasMoreData  else { return }
        
        isLoading = true
        errorMessage = nil
        emptyMessage = nil
        
        do {
            let newRecipeResponse = try await service.fetchRecipes(limit: limit, skip: skip)
            hasMoreData = (skip + limit) < newRecipeResponse.total
            if newRecipeResponse.recipes.isEmpty {
                emptyMessage = "No Recipes Found."
            } else {
                recipes.append(contentsOf: newRecipeResponse.recipes)
                skip += limit
            }
        } catch let error as RecipeServiceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
    
    func searchRecipes() async {
        guard searchText.count >= 2 else { return }
        
        isLoading = true
        hasMoreData = false
        errorMessage = nil
        emptyMessage = nil
        
        do {
            let response = try await service.searchRecipes(query: searchText)
            if response.recipes.isEmpty {
                emptyMessage = "No Recipes Found."
            }
            recipes = response.recipes
        } catch let error as RecipeServiceError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }
        
        isLoading = false
    }
    
    func resetPagination() {
        recipes.removeAll()
        skip = 0
        hasMoreData = true
    }
}

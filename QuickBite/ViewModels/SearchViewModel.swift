import Foundation
import Combine
import CoreLocation

class SearchViewModel: ObservableObject {
    
    @Published var recipeResults: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""
    @Published var favoriteRecipeIDs: Set<Int> = []
    
    var trendingRecipes: [Recipe] = []
    
    let apiService = ApiService()
    let persistence = PersistenceManager.shared
    
    var cancellables = Set<AnyCancellable>()
    
    init() {
        print("SearchViewModel initialized")
        
        loadFavoriteIDs()
        fetchTrendingRecipes()
        
        // Search bar handling
        $searchText
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                print("Search text changed to: \(text)")
                
                if text.isEmpty {
                    print("Showing trending recipes")
                    self.recipeResults = self.trendingRecipes
                    self.isLoading = false
                } else {
                    print("Searching recipes for query: \(text)")
                    self.searchRecipes(query: text)
                }
            }
            .store(in: &cancellables)
        
        // Listen for favorite changes
        NotificationCenter.default.publisher(for: PersistenceManager.favoritesChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("Favorites changed")
                self?.loadFavoriteIDs()
            }
            .store(in: &cancellables)
    }
    
    func searchRecipes(query: String) {
        isLoading = true
        Task {
            do {
                let results = try await apiService.searchRecipes(query: query)
                await MainActor.run {
                    self.recipeResults = results
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func fetchTrendingRecipes() {
        isLoading = true
        Task {
            do {
                let results = try await apiService.searchRecipes()
                await MainActor.run {
                    self.trendingRecipes = results
                    if self.searchText.isEmpty {
                        self.recipeResults = results
                    }
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func loadFavoriteIDs() {
        do {
            let favorites = try persistence.getAllFavorites()
            let ids = favorites.map { Int($0.recipeId) }
            favoriteRecipeIDs = Set(ids)
            print("Loaded \(favoriteRecipeIDs.count) favorites.")
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func toggleFavorite(for recipe: Recipe) {
        if favoriteRecipeIDs.contains(recipe.id) {
            print("Removing favorite \(recipe.title)")
            persistence.removeFavorite(recipeId: recipe.id)
            favoriteRecipeIDs.remove(recipe.id)
        } else {
            print("Adding favorite \(recipe.title)")
            persistence.addFavorite(recipe: recipe)
            favoriteRecipeIDs.insert(recipe.id)
        }
    }
}

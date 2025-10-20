import CoreLocation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var recipeResults: [Recipe] = []
    @Published var isLoading = false
    @Published var searchText = ""
    
    // Holds the set of favorite IDs for quick lookup
    @Published var favoriteRecipeIDs: Set<Int> = []
    
    private var trendingRecipes: [Recipe] = []
    
    private let apiService = ApiService()
    // Instance of the persistence manager
    private let persistence = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load initial favorite status
        loadFavoriteIDs()
        fetchTrendingRecipes()
        
        // Debounce search text
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                
                if !query.isEmpty {
                    self.searchRecipes(query: query)
                } else {
                    self.isLoading = false
                    self.recipeResults = self.trendingRecipes
                }
            }
            .store(in: &cancellables)
            
        // Listen for external favorite changes ---
        NotificationCenter.default.publisher(for: PersistenceManager.favoritesChangedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadFavoriteIDs()
            }
            .store(in: &cancellables)
    }

    func searchRecipes(query: String) {
        Task {
            isLoading = true
            do {
                recipeResults = try await apiService.fetchRecipes(query: query)
            } catch {
                print("Error searching recipes: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    private func fetchTrendingRecipes() {
        Task {
            isLoading = true
            do {
                trendingRecipes = try await apiService.fetchRecipes()
                if searchText.isEmpty {
                    recipeResults = trendingRecipes
                }
            } catch {
                print("Error fetching trending recipes: \(error.localizedDescription)")
            }
            isLoading = false
        }
    }
    
    // Loads favorite IDs from persistence
    private func loadFavoriteIDs() {
        do {
            let favorites = try persistence.fetchAllFavorites()
            favoriteRecipeIDs = Set(favorites.map { Int($0.recipeId) })
        } catch {
            print("Error loading favorite IDs: \(error)")
        }
    }
    
    // Toggles the favorite status for a given recipe
    func toggleFavorite(for recipe: Recipe) {
        if favoriteRecipeIDs.contains(recipe.id) {
            // Remove
            persistence.removeFavorite(recipeId: recipe.id)
            favoriteRecipeIDs.remove(recipe.id)
        } else {
            // Add (using the new function that takes a 'Recipe')
            persistence.addFavorite(recipe: recipe)
            favoriteRecipeIDs.insert(recipe.id)
        }
    }
}

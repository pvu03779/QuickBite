import Foundation
import Combine
import CoreData

@MainActor
class FavoritesViewModel: ObservableObject {
    @Published var favoriteRecipes: [FavoriteRecipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let persistence = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Listen for external changes (e.g., from the detail screen) to refresh the list
        NotificationCenter.default.publisher(for: PersistenceManager.favoritesChangedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchFavorites()
            }
            .store(in: &cancellables)
    }
    
    func fetchFavorites() {
        isLoading = true
        errorMessage = nil
        
        do {
            favoriteRecipes = try persistence.fetchAllFavorites()
        } catch {
            errorMessage = "Failed to fetch favorite recipes: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

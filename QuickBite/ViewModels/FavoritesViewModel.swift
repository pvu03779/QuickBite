import Foundation
import Combine
import CoreData

class FavoritesViewModel: ObservableObject {
    
    @Published var favoriteRecipes: [FavoriteRecipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    let persistence = PersistenceManager.shared
    var cancellables = Set<AnyCancellable>()
    
    init() {
        // listen for updates when favorites change
        NotificationCenter.default.publisher(for: PersistenceManager.favoritesChanged)
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        do {
            let allFavs = self.persistence.getAllFavorites()
            self.favoriteRecipes = allFavs
        } catch {
            self.errorMessage = "Can not load favorites: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
}

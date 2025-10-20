import Foundation
import Combine
import CoreData

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var shoppingListRecipes: [ShoppingListRecipe] = []
    
    private let persistence = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Fetch initially
        fetchShoppingList()
        
        // Listen for changes (e.g., from the Detail screen)
        NotificationCenter.default.publisher(for: PersistenceManager.shoppingListChangedNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetchShoppingList()
            }
            .store(in: &cancellables)
    }
    
    /// Fetches all recipe groups from Core Data
    func fetchShoppingList() {
        do {
            shoppingListRecipes = try persistence.fetchAllShoppingListRecipes()
        } catch {
            print("Error fetching shopping list: \(error.localizedDescription)")
        }
    }
    
    /// Toggles the 'isChecked' state of an ingredient and saves the context
    func toggleChecked(for ingredient: ShoppingListIngredient) {
        ingredient.isChecked.toggle()
        persistence.saveContext()
    }
    
    /// Helper to get a sorted array of ingredients from the recipe's NSSet
    func getIngredients(for recipe: ShoppingListRecipe) -> [ShoppingListIngredient] {
        let set = recipe.ingredients as? Set<ShoppingListIngredient> ?? []
        // Sort alphabetically
        return set.sorted { $0.originalText ?? "" < $1.originalText ?? "" }
    }
}

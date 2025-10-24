import Foundation
import Combine
import CoreData

@MainActor
class ShoppingListViewModel: ObservableObject {
    @Published var shoppingListRecipes: [ShoppingListRecipe] = []
    
    private let persistence = PersistenceManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        getShoppingList()
        NotificationCenter.default.publisher(for: PersistenceManager.shoppingListChanged)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.getShoppingList()
            }
            .store(in: &cancellables)
    }
    
    // get all recipe groups from Core Data
    func getShoppingList() {
        do {
            shoppingListRecipes = try persistence.getAllShoppingListRecipes()
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    // Toggles state of an ingredient and saves the data
    func toggleChecked(for ingredient: ShoppingListIngredient) {
        ingredient.isChecked.toggle()
        persistence.saveData()
    }
    
    // sorted array of ingredients from recipe
    func getIngredients(for recipe: ShoppingListRecipe) -> [ShoppingListIngredient] {
        let set = recipe.ingredients as? Set<ShoppingListIngredient> ?? []
        // Sort alphabetically
        return set.sorted { $0.originalText ?? "" < $1.originalText ?? "" }
    }
    
    // delete a recipe from the shopping list
    func deleteRecipe(_ recipe: ShoppingListRecipe) {
        persistence.removeFromShoppingList(recipe: recipe)
    }
}

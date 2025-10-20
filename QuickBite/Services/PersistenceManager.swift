import Foundation
import CoreData

class PersistenceManager {
    static let shared = PersistenceManager()
    static let favoritesChangedNotification = Notification.Name("favoritesChanged")
    static let shoppingListChangedNotification = Notification.Name("shoppingListChanged")
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Favorite Operations
    // Add a simple recipe to favorites
    func addFavorite(recipe: Recipe) {
        // Check if already exists
        if isFavorite(recipeId: recipe.id) {
            return
        }
        
        let favorite = FavoriteRecipe(context: context)
        favorite.recipeId = Int64(recipe.id)
        favorite.title = recipe.title
        favorite.imageURL = recipe.image
        favorite.readyInMinutes = Int32(recipe.readyInMinutes ?? 45)
        favorite.dateAdded = Date()
        saveContext()
        
        // Post notification
        NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
    }
    
    // Add a full recipe to favorites
    func addFavorite(recipe: RecipeDetail) {
        // Check if already exists
        if isFavorite(recipeId: recipe.id) {
            return
        }
        
        let favorite = FavoriteRecipe(context: context)
        favorite.recipeId = Int64(recipe.id)
        favorite.title = recipe.title
        favorite.imageURL = recipe.image
        favorite.readyInMinutes = Int32(recipe.readyInMinutes)
        favorite.dateAdded = Date()
        saveContext()
        
        // Post notification
        NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
    }
    
    // Remove a recipe from favorites
    func removeFavorite(recipeId: Int) {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let results = try context.fetch(fetchRequest)
            for favorite in results {
                context.delete(favorite)
            }
            saveContext()
            
            // Post notification
            NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
        } catch {
            print("Error removing favorite: \(error)")
        }
    }
    
    // Check if a recipe is favorited
    func isFavorite(recipeId: Int) -> Bool {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking favorite: \(error)")
            return false
        }
    }
    
    // Get all favorite recipe objects (sorted by date added, newest first)
    func fetchAllFavorites() throws -> [FavoriteRecipe] {
        let fetchRequest: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching favorites: \(error)")
            return []
        }
    }
    
    // Clear all favorites
    func clearAllFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteRecipe.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveContext()
            
            // Post notification
            NotificationCenter.default.post(name: Self.favoritesChangedNotification, object: nil)
        } catch {
            print("Error clearing favorites: \(error)")
        }
    }
    
    func isRecipeInShoppingList(recipeId: Int) -> Bool {
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Error checking shopping list: \(error)")
            return false
        }
    }
    
    // Add a recipe and its ingredients to the shopping list
    func addRecipeToShoppingList(recipe: RecipeDetail) {
        // Don't add if it already exists
        if isRecipeInShoppingList(recipeId: recipe.id) {
            return
        }
        
        let newRecipe = ShoppingListRecipe(context: context)
        newRecipe.recipeId = Int64(recipe.id)
        newRecipe.recipeTitle = recipe.title
        
        for ingredient in recipe.extendedIngredients {
            let newIngredient = ShoppingListIngredient(context: context)
            newIngredient.ingredientId = Int64(ingredient.id)
            newIngredient.originalText = ingredient.original
            newIngredient.isChecked = false
            newIngredient.recipe = newRecipe // Link ingredient to the recipe
        }
        
        saveContext()
        
        // Post notification
        NotificationCenter.default.post(name: Self.shoppingListChangedNotification, object: nil)
    }
    
    // Get all shopping list recipe groups
    func fetchAllShoppingListRecipes() throws -> [ShoppingListRecipe] {
        let fetchRequest: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        // Sort by title
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "recipeTitle", ascending: true)]
        
        do {
            let results = try context.fetch(fetchRequest)
            return results
        } catch {
            print("Error fetching shopping list: \(error)")
            return []
        }
    }
    
    // Deletes a specific recipe and its ingredients from the shopping list
    func removeRecipeFromShoppingList(_ recipe: ShoppingListRecipe) {
        context.delete(recipe) // Cascade delete will handle ingredients
        saveContext()
        
        // Post notification so views can refresh
        NotificationCenter.default.post(name: Self.shoppingListChangedNotification, object: nil)
    }
}

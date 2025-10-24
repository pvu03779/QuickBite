import Foundation
import CoreData

class PersistenceManager {
    static let shared = PersistenceManager()
    static let favoritesChanged = Notification.Name("favoritesChanged")
    static let shoppingListChanged = Notification.Name("shoppingListChanged")
    
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { description, error in
    
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
    
    func saveData() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
            }
        }
    }
    
    func addFavorite(recipe: Recipe) {
        if isFavorite(recipeId: recipe.id) {
            return
        }
        
        let newFavorite = FavoriteRecipe(context: context)
        newFavorite.recipeId = Int64(recipe.id)
        newFavorite.title = recipe.title
        newFavorite.imageURL = recipe.image
        newFavorite.readyInMinutes = Int32(recipe.readyInMinutes ?? 45)
        newFavorite.dateAdded = Date()
        
        saveData()
        
        NotificationCenter.default.post(name: PersistenceManager.favoritesChanged, object: nil)
    }
    
    func addFavoriteDetail(recipe: RecipeDetail) {
        if isFavorite(recipeId: recipe.id) {
            return
        }
        
        let newFav = FavoriteRecipe(context: context)
        newFav.recipeId = Int64(recipe.id)
        newFav.title = recipe.title
        newFav.imageURL = recipe.image
        newFav.readyInMinutes = Int32(recipe.readyInMinutes)
        newFav.dateAdded = Date()
        
        saveData()
        
        NotificationCenter.default.post(name: PersistenceManager.favoritesChanged, object: nil)
    }
    
    func removeFavorite(recipeId: Int) {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let results = try context.fetch(request)
            for fav in results {
                context.delete(fav)
            }
            saveData()
            NotificationCenter.default.post(name: PersistenceManager.favoritesChanged, object: nil)
        } catch {
        }
    }
    
    func isFavorite(recipeId: Int) -> Bool {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func getAllFavorites() -> [FavoriteRecipe] {
        let request: NSFetchRequest<FavoriteRecipe> = FavoriteRecipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: false)]
        
        do {
            let favorites = try context.fetch(request)
            return favorites
        } catch {
            return []
        }
    }
    
    func clearFavorites() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = FavoriteRecipe.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            saveData()
            NotificationCenter.default.post(name: PersistenceManager.favoritesChanged, object: nil)
        } catch {
        }
    }

    
    func addToShoppingList(recipe: RecipeDetail) {
        if isInShoppingList(recipeId: recipe.id) {
            return
        }
        
        let newShoppingRecipe = ShoppingListRecipe(context: context)
        newShoppingRecipe.recipeId = Int64(recipe.id)
        newShoppingRecipe.recipeTitle = recipe.title
        
        for ing in recipe.extendedIngredients {
            let ingredient = ShoppingListIngredient(context: context)
            ingredient.ingredientId = Int64(ing.id)
            ingredient.originalText = ing.original
            ingredient.isChecked = false
            ingredient.recipe = newShoppingRecipe
        }
        
        saveData()
        NotificationCenter.default.post(name: PersistenceManager.shoppingListChanged, object: nil)
    }
    
    func isInShoppingList(recipeId: Int) -> Bool {
        let request: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        request.predicate = NSPredicate(format: "recipeId == %d", recipeId)
        
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            return false
        }
    }
    
    func getAllShoppingListRecipes() -> [ShoppingListRecipe] {
        let request: NSFetchRequest<ShoppingListRecipe> = ShoppingListRecipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "recipeTitle", ascending: true)]
        
        do {
            let list = try context.fetch(request)
            return list
        } catch {
            print("Error fetching shopping list: \(error)")
            return []
        }
    }
    
    func removeFromShoppingList(recipe: ShoppingListRecipe) {
        context.delete(recipe)
        saveData()
        NotificationCenter.default.post(name: PersistenceManager.shoppingListChanged, object: nil)
    }
}

import Foundation

class RecipeDetailViewModel: ObservableObject {
    
    @Published var recipeDetail: RecipeDetail? = nil
    @Published var videoInfo: VideoInfo? = nil
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isInShoppingList: Bool = false
    
    let apiService = ApiService()
    let persistenceManager = PersistenceManager.shared
    
    // load details for a recipe
    func loadRecipeDetails(recipeId: Int) async {
        isLoading = true
        errorMessage = nil
        videoInfo = nil
        
        // check if we already have data
        if let existing = recipeDetail, existing.id == recipeId {
            print("Already loaded recipe details.")
            isLoading = false
            return
        }
        
        do {
            print("Get recipe details")
            let detail = try await apiService.getRecipeDetails(id: recipeId)
            self.recipeDetail = detail
            
            print("Get video")
            let video = try await apiService.getVideo(query: detail.title)
            self.videoInfo = video
            
            self.isInShoppingList = persistenceManager.isInShoppingList(recipeId: recipeId)
            print("Recipe loaded success")
            
        } catch {
            self.errorMessage = "Err: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

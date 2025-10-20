import Foundation

@MainActor
class RecipeDetailViewModel: ObservableObject {
    @Published var recipeDetail: RecipeDetail?
    @Published var videoInfo: VideoInfo?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isInShoppingList: Bool = false
    
    private let service = ApiService()
    private let persistence = PersistenceManager.shared
    
    func fetchDetails(for recipeId: Int) async {
        isLoading = true
        errorMessage = nil
        videoInfo = nil
        
        if recipeDetail?.id == recipeId {
            isLoading = false;
            return
        }
        
        do {
            // 1. Fetch the main recipe details
            let detail = try await service.fetchRecipeDetails(id: recipeId)
            self.recipeDetail = detail
            // 2. Use the recipe title to search for a related video
            self.videoInfo = try await service.fetchVideo(for: detail.title)
            self.isInShoppingList = persistence.isRecipeInShoppingList(recipeId: recipeId)
        } catch {
            errorMessage = "Failed to fetch recipe details or video: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

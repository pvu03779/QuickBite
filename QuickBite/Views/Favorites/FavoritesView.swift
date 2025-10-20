import SwiftUI
 
 struct FavoritesView: View {
     @StateObject private var viewModel = FavoritesViewModel()
 
     var body: some View {
         NavigationView {
             Group {
                 if viewModel.isLoading {
                     ProgressView("Loading Favorites...")
                 } else if let errorMessage = viewModel.errorMessage {
                     Text(errorMessage).foregroundColor(.red).padding()
                 } else if viewModel.favoriteRecipes.isEmpty {
                     Text("You haven't saved any favorite recipes yet.")
                         .font(.headline)
                         .foregroundColor(.secondary)
                 } else {
                     List(viewModel.favoriteRecipes) { recipe in
                         NavigationLink(destination: RecipeDetailView(recipeId: Int(recipe.recipeId))) {
                             FavoriteRowView(recipe: recipe)
                         }
                     }
                 }
             }
             .navigationTitle("Favorites")
             .onAppear {
                 // This will run when the view first appears
                 viewModel.fetchFavorites()
             }
         }
     }
 }
 
 /// A simple row view for the favorites list.
 struct FavoriteRowView: View {
     let recipe: FavoriteRecipe // Updated to use the Core Data entity
 
     var body: some View {
         HStack(spacing: 16) {
             AsyncImage(url: URL(string: recipe.imageURL ?? "")) { image in
                 image.resizable()
             } placeholder: {
                 Rectangle().fill(Color.gray.opacity(0.3))
             }
             .frame(width: 80, height: 80)
             .cornerRadius(10)
 
             VStack(alignment: .leading) {
                 Text(recipe.title ?? "Unknown Recipe")
                     .font(.headline)
                     .lineLimit(2)
                 Text("\(recipe.readyInMinutes) Min")
                     .font(.subheadline)
                     .foregroundColor(.gray)
             }
         }
         .padding(.vertical, 8)
     }
 }

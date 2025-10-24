import SwiftUI

struct FavoritesView: View {
    
    @StateObject var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                
                if viewModel.isLoading {
                    ProgressView("Loading favorites...")
                        .padding()
                } else if let msg = viewModel.errorMessage {
                    Text(msg)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.favoriteRecipes.count == 0 {
                    Text("No favorite recipes yet!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.favoriteRecipes, id: \.self) { recipe in
                            NavigationLink(destination: RecipeDetailView(recipeId: Int(recipe.recipeId))) {
                                HStack {
                                    if let img = recipe.imageURL, let url = URL(string: img) {
                                        AsyncImage(url: url) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                        }
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(8)
                                    } else {
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 70, height: 70)
                                            .cornerRadius(8)
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Text(recipe.title ?? "Untitled Recipe")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                            .lineLimit(2)
                                        
                                        Text("\(recipe.readyInMinutes) min")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("My Favorites")
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

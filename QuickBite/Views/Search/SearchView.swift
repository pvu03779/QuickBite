import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedRecipeId: Int?
    @State private var isNavigationActive = false
    @State private var isShowingMapView = false
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                
                NavigationLink(
                    destination: RecipeDetailView(recipeId: selectedRecipeId ?? 0),
                    isActive: $isNavigationActive
                ) { EmptyView() }
                
                Text("Hi User,\nwhat you want to eat?")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search", text: $viewModel.searchText)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if viewModel.isLoading && viewModel.recipeResults.isEmpty {
                    ProgressView("Finding recipes...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    List(viewModel.recipeResults) { recipe in
                        SearchRecipeCard(
                            recipe: recipe,
                            isFavorite: viewModel.favoriteRecipeIDs.contains(recipe.id),
                            onToggleFavorite: {
                                viewModel.toggleFavorite(for: recipe)
                            }
                        )
                        .onTapGesture {
                            selectedRecipeId = recipe.id
                            isNavigationActive = true
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NearbyMarketsView()) {
                        Image(systemName: "map")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

// Card view now accepts favorite state and toggle action
struct SearchRecipeCard: View {
    let recipe: Recipe
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: recipe.image)) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 180)
                    .clipped()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
                    .frame(height: 180)
                    .overlay(Image(systemName: "photo"))
            }
            .overlay(alignment: .topTrailing) {
                Button(action: onToggleFavorite) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title2)
                        .padding(12)
                        .foregroundColor(isFavorite ? .red : .white)
                        .background(.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(recipe.title) | \(recipe.readyInMinutes ?? 45) Min")
                    .font(.headline)
                    .lineLimit(1)
                
                Text("Difficulty: \(recipe.difficulty)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .buttonStyle(BorderlessButtonStyle())
    }
}


struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

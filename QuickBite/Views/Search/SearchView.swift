import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var selectedRecipeId: Int?
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                NavigationLink(
                    destination: RecipeDetailView(recipeId: selectedRecipeId ?? 0),
                    tag: selectedRecipeId ?? 0,
                    selection: $selectedRecipeId
                ) { EmptyView() }

                Text("Hey there 👋\nWhat are you craving?")
                    .font(.title)
                    .fontWeight(.semibold)
                    .padding(.horizontal)

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search recipes...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)

                if viewModel.isLoading && viewModel.recipeResults.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView("Searching for recipes...")
                        Spacer()
                    }
                } else {
                    List(viewModel.recipeResults) { recipe in
                        VStack(alignment: .leading, spacing: 8) {
                            AsyncImage(url: URL(string: recipe.image)) { image in
                                image.resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipped()
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(height: 180)
                                    .overlay(Image(systemName: "photo"))
                            }
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    viewModel.toggleFavorite(for: recipe)
                                } label: {
                                    Image(systemName: viewModel.favoriteRecipeIDs.contains(recipe.id) ? "heart.fill" : "heart")
                                        .font(.title2)
                                        .padding(10)
                                        .foregroundColor(.red)
                                        .background(Color.black.opacity(0.3))
                                        .clipShape(Circle())
                                }
                                .padding(8)
                                .buttonStyle(PlainButtonStyle())
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(recipe.title)  •  \(recipe.readyInMinutes ?? 45) min")
                                    .font(.headline)
                                Text("Difficulty: \(recipe.difficulty)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.bottom, 8)
                        }
                        .onTapGesture {
                            selectedRecipeId = recipe.id
                        }
                        .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: NearbyMarketsView()) {
                        Image(systemName: "map")
                            .font(.title2)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
            .environmentObject(LocationManager())
    }
}

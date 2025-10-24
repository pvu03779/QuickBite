import SwiftUI

struct RecipeDetailView: View {
    
    let recipeId: Int
    @StateObject var viewModel = RecipeDetailViewModel()
    @State var showVideo = false
    
    var caloriesText: String {
        if let recipe = viewModel.recipeDetail {
            if let cal = recipe.nutrition?.nutrients.first(where: { $0.name == "Calories" }) {
                return "\(Int(cal.amount)) kcal"
            }
        }
        return "N/A"
    }
    
    var shareText: String {
        if let recipe = viewModel.recipeDetail {
            var txt = "\(recipe.title)\n\nIngredients:\n"
            for ing in recipe.extendedIngredients {
                txt += "- \(ing.original)\n"
            }
            txt += "\nSteps:\n"
            for stepGroup in recipe.analyzedInstructions {
                for step in stepGroup.steps {
                    txt += "\(step.number). \(step.step)\n"
                }
            }
            return txt
        }
        return "Check out this recipe!"
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                
                if viewModel.isLoading {
                    ProgressView("Loading recipe...")
                        .frame(maxWidth: .infinity, minHeight: 250)
                } else if let recipe = viewModel.recipeDetail {
                    
                    // Header image or video
                    if let _ = viewModel.videoInfo {
                        ZStack {
                            AsyncImage(url: URL(string: recipe.image)) { img in
                                img.resizable().scaledToFit()
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                            Rectangle().fill(Color.black.opacity(0.4))
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 70))
                                .foregroundColor(.white)
                        }
                        .onTapGesture {
                            showVideo = true
                        }
                    } else {
                        AsyncImage(url: URL(string: recipe.image)) { img in
                            img.resizable().scaledToFit()
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(recipe.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        
                        Divider()
                        
                        Text("Ingredients (\(recipe.servings) servings)")
                            .font(.headline)
                        ForEach(recipe.extendedIngredients) { item in
                            Text("• \(item.original)")
                        }
                        
                        Divider()
                        
                        Text("Steps")
                            .font(.headline)
                        ForEach(recipe.analyzedInstructions) { instruction in
                            ForEach(instruction.steps) { step in
                                Text("\(step.number). \(step.step)")
                                    .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding()
                    
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .task {
            await viewModel.loadRecipeDetails(recipeId:recipeId)
        }
        .navigationTitle("Recipe Details")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let recipe = viewModel.recipeDetail {
                VStack(spacing: 8) {
                    HStack {
                        Label("\(recipe.readyInMinutes) min", systemImage: "clock")
                        Spacer()
                        Label(caloriesText, systemImage: "flame")
                    }
                    .font(.subheadline)
                    .padding(.horizontal)
                    
                    Button {
                        PersistenceManager.shared.addToShoppingList(recipe: recipe)
                        viewModel.isInShoppingList = true
                    } label: {
                        Text(viewModel.isInShoppingList ? "Added!" : "Add to Shopping List")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isInShoppingList ? Color.gray : Color.blue)
                            .cornerRadius(8)
                    }
                    .disabled(viewModel.isInShoppingList)
                }
                .padding()
                .background(Color(.systemGray6))
            }
        }
        .sheet(isPresented: $showVideo) {
            if let video = viewModel.videoInfo {
                VideoPlayerView(youTubeId: video.youTubeId)
            } else {
                Text("No video available")
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.recipeDetail != nil {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

import SwiftUI

struct RecipeDetailView: View {
    let recipeId: Int
    @StateObject private var viewModel = RecipeDetailViewModel()
    @State private var isShowingVideo = false
    
    private var caloriesString: String {
        if let calories = viewModel.recipeDetail?.nutrition?.nutrients.first(where: { $0.name == "Calories" }) {
            // Format to a whole number
            return String(format: "%.0f kcal", calories.amount)
        }
        return "N/A"
    }
    
    // Computed property to build the full shareable string
    private var shareableContent: String {
        guard let detail = viewModel.recipeDetail else { return "Check out this recipe!" }
        
        var content = "\(detail.title)\n\n"
        
        content += "--- INGREDIENTS ---\n"
        for ingredient in detail.extendedIngredients {
            content += "• \(ingredient.original)\n"
        }
        
        content += "\n--- STEPS ---\n"
        for instructionSet in detail.analyzedInstructions {
            for step in instructionSet.steps {
                content += "\(step.number). \(step.step)\n"
            }
        }
        
        return content
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.isLoading {
                    ProgressView("Loading Recipe...")
                        .frame(height: 300)
                } else if let detail = viewModel.recipeDetail {
                    HeaderMediaView(videoInfo: viewModel.videoInfo, imageUrl: detail.image)
                        .onTapGesture {
                            if viewModel.videoInfo != nil {
                                isShowingVideo = true
                            }
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title
                        Text(detail.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                        Divider()
                        
                        // Ingredients Section
                        Text("Ingredients (for \(detail.servings) servings)")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(detail.extendedIngredients) { ingredient in
                            Text("• \(ingredient.original)")
                        }
                        
                        Divider()
                        
                        // Steps Section
                        Text("Steps")
                            .font(.title2)
                            .fontWeight(.semibold)
                        ForEach(detail.analyzedInstructions) { instructionSet in
                            ForEach(instructionSet.steps) { step in
                                HStack(alignment: .top) {
                                    Text("\(step.number).")
                                        .fontWeight(.bold)
                                        .padding(.trailing, 4)
                                    Text(step.step)
                                }
                                .padding(.bottom, 4)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
        .task {
            await viewModel.fetchDetails(for: recipeId)
        }
        .navigationTitle("Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let detail = viewModel.recipeDetail {
                
                VStack(spacing: 12) {
                    HStack {
                        Label("\(detail.readyInMinutes) min", systemImage: "clock")
                        Spacer()
                        Label(caloriesString, systemImage: "flame")
                    }
                    .font(.headline)
                    .padding(.horizontal)
                    
                    Button(action: {
                        PersistenceManager.shared.addRecipeToShoppingList(recipe: detail)
                        viewModel.isInShoppingList = true
                    }) {
                        Text(viewModel.isInShoppingList ? "Added to List" : "Add to Shopping")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(viewModel.isInShoppingList ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(viewModel.isInShoppingList)
                }
                .padding()
                .background(.thinMaterial)
            }
        }
        .sheet(isPresented: $isShowingVideo) {
            if let video = viewModel.videoInfo {
                VideoPlayerView(youTubeId: video.youTubeId)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.recipeDetail != nil {
                    ShareLink(
                        item: shareableContent,
                        subject: Text("Recipe: \(viewModel.recipeDetail?.title ?? "")")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
    }
}

struct HeaderMediaView: View {
    let videoInfo: VideoInfo?
    let imageUrl: String
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3)).aspectRatio(contentMode: .fit)
            }
            
            if videoInfo != nil {
                Rectangle().fill(.black.opacity(0.4))
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
        }
    }
}


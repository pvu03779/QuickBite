import SwiftUI

struct ShoppingListView: View {
    @StateObject private var viewModel = ShoppingListViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.shoppingListRecipes.isEmpty {
                    Text("Your shopping list is empty.\nAdd ingredients from a recipe detail page.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    List {
                        ForEach(viewModel.shoppingListRecipes) { recipe in
                            // Group by recipe
                            Section(header: Text(recipe.recipeTitle ?? "Unknown Recipe").font(.title3)) {
                                // Get sorted ingredients
                                ForEach(viewModel.getIngredients(for: recipe)) { ingredient in
                                    ShoppingItemView(
                                        ingredient: ingredient,
                                        onToggle: {
                                            viewModel.toggleChecked(for: ingredient)
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
            }
            .navigationTitle("Shopping List")
            .onAppear {
                // Refresh when the view appears
                viewModel.fetchShoppingList()
            }
        }
    }
}

struct ShoppingItemView: View {
    let ingredient: ShoppingListIngredient
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                Image(systemName: ingredient.isChecked ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(ingredient.isChecked ? .green : .secondary)
                
                // Ingredient Text
                Text(ingredient.originalText ?? "Unknown Ingredient")
                    .font(.body)
                    .foregroundColor(ingredient.isChecked ? .secondary : .primary)
                    .strikethrough(ingredient.isChecked, color: .secondary)
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        ShoppingListView()
    }
}

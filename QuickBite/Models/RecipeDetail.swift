struct RecipeDetail: Decodable, Identifiable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int
    let servings: Int
    let extendedIngredients: [ExtendedIngredient]
    let analyzedInstructions: [AnalyzedInstruction]
    let nutrition: Nutrition?
}

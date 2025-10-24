struct Recipe: Identifiable, Decodable {
    let id: Int
    let title: String
    let image: String
    let readyInMinutes: Int?
    let healthScore: Int?

    var difficulty: String {
        guard let score = healthScore else { return "Medium" }
        if score > 75 {
            return "Easy"
        } else if score > 40 {
            return "Medium"
        } else {
            return "Hard"
        }
    }
}

import Foundation

struct Nutrient: Decodable, Identifiable {
    var id: String { name }
    let name: String
    let amount: Double
    let unit: String
}

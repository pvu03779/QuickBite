struct InstructionStep: Identifiable, Decodable {
    let number: Int
    let step: String
    var id: Int { number }
}

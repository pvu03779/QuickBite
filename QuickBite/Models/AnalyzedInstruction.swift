struct AnalyzedInstruction: Decodable, Identifiable {
    let name: String
    let steps: [InstructionStep]
    var id: String { name }
}

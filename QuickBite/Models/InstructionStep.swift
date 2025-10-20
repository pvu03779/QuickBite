struct InstructionStep: Identifiable, Decodable {
    let number: Int
    let step: String
    
    // Use the step number for Identifiable conformance within its set
    var id: Int { number }
}

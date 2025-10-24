struct VideoSearchResponse: Decodable {
    let videos: [VideoInfo]
}

struct VideoInfo: Decodable, Identifiable {
    let title: String
    let youTubeId: String

    var id: String { youTubeId }
}

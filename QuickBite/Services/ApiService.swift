import Foundation

enum ApiError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
}

final class ApiService {
    private let apiKey = "5e0356f3b7bd454886811a57765cecf9"
    private let baseURL = "https://api.spoonacular.com"
    
    private let decoder = JSONDecoder()
    
    // MARK: - Core Request
    
    private func request<T: Decodable>(
        endpoint: String,
        params: [URLQueryItem] = []
    ) async throws -> T {
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw ApiError.invalidURL
        }
        
        var items = params
        items.append(.init(name: "apiKey", value: apiKey))
        components.queryItems = items
        
        guard let url = components.url else {
            throw ApiError.invalidURL
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw ApiError.decoding(error)
        } catch {
            throw ApiError.network(error)
        }
    }
    
    // MARK: - Public Methods
    
    func loadRecipes(for ids: [Int]) async throws -> [RecipeDetail] {
        guard !ids.isEmpty else { return [] }
        let idString = ids.map(String.init).joined(separator: ",")
        let params = [URLQueryItem(name: "ids", value: idString)]
        
        return try await request(
            endpoint: "/recipes/informationBulk",
            params: params
        )
    }
    
    func searchRecipes(query: String? = nil, cuisine: String? = nil) async throws -> [Recipe] {
        var params: [URLQueryItem] = [
            .init(name: "number", value: "15"),
            .init(name: "addRecipeInformation", value: "true")
        ]
        
        if let q = query, !q.isEmpty {
            params.append(.init(name: "query", value: q))
        } else if let c = cuisine {
            params.append(.init(name: "cuisine", value: c))
        }
        
        let response: ApiResponse = try await request(
            endpoint: "/recipes/complexSearch",
            params: params
        )
        return response.results
    }
    
    func getRecipeDetails(id: Int) async throws -> RecipeDetail {
        let params = [URLQueryItem(name: "includeNutrition", value: "true")]
        return try await request(
            endpoint: "/recipes/\(id)/information",
            params: params
        )
    }
    
    func getVideo(query: String) async throws -> VideoInfo? {
        let params: [URLQueryItem] = [
            .init(name: "query", value: query),
            .init(name: "number", value: "1")
        ]
        
        let response: VideoSearchResponse = try await request(
            endpoint: "/food/videos/search",
            params: params
        )
        return response.videos.first
    }
}

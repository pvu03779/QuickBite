import Foundation

enum ApiError: Error {
    case badURL
    case requestFailed(Error)
    case decodingFailed(Error)
}

class ApiService {
    private let apiKey = "api_key"
    private let baseURL = "https://api.spoonacular.com"
    
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        return decoder
    }()
    
    private func performRequest<T: Decodable>(
        endpoint: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> T {
        
        // Build the URL
        guard var components = URLComponents(string: baseURL + endpoint) else {
            throw ApiError.badURL
        }
        
        // Add all provided query items + the API key
        var allQueryItems = queryItems
        allQueryItems.append(URLQueryItem(name: "apiKey", value: apiKey))
        components.queryItems = allQueryItems
        
        guard let url = components.url else {
            throw ApiError.badURL
        }
        
        // Perform the network request
        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw ApiError.requestFailed(error)
        }
        
        // Decode the data
        do {
            let decodedResponse = try jsonDecoder.decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw ApiError.decodingFailed(error)
        }
    }
    
    func fetchRecipes(by ids: [Int]) async throws -> [RecipeDetail] {
        guard !ids.isEmpty else { return [] }
        
        let idString = ids.map { String($0) }.joined(separator: ",")
        let queryItems = [
            URLQueryItem(name: "ids", value: idString)
        ]

        // Just call the reusable function
        return try await performRequest(
            endpoint: "/recipes/informationBulk",
            queryItems: queryItems
        )
    }
    
    func fetchRecipes(query: String? = nil, cuisine: String? = nil) async throws -> [Recipe] {
        var queryItems = [
            URLQueryItem(name: "number", value: "15"),
            URLQueryItem(name: "addRecipeInformation", value: "true")
        ]
        
        if let query = query, !query.isEmpty {
            queryItems.append(URLQueryItem(name: "query", value: query))
        } else if let cuisine = cuisine {
            queryItems.append(URLQueryItem(name: "cuisine", value: cuisine))
        }
        
        // The generic function decodes the wrapper, and we return the results
        let decodedResponse: ApiResponse = try await performRequest(
            endpoint: "/recipes/complexSearch",
            queryItems: queryItems
        )
        return decodedResponse.results
    }
    
    func fetchRecipeDetails(id: Int) async throws -> RecipeDetail {
        let queryItems = [
            URLQueryItem(name: "includeNutrition", value: "true")
        ]
        
        return try await performRequest(
            endpoint: "/recipes/\(id)/information",
            queryItems: queryItems
        )
    }
    
    func fetchVideo(for query: String) async throws -> VideoInfo? {
        let queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "number", value: "1")
        ]
        
        // The generic function decodes the wrapper, and we return the first video
        let decodedResponse: VideoSearchResponse = try await performRequest(
            endpoint: "/food/videos/search",
            queryItems: queryItems
        )
        return decodedResponse.videos.first
    }
}

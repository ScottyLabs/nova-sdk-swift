import Foundation

public class Nova: @unchecked Sendable {
    
    private init() {
            fatalError("This class should not be instantiated")
        }
    
    internal struct APIKeys: Codable {
        let openAI: String?
        let stabilityAI: String?
        let humeAI: String?
    }
    
    private nonisolated(unsafe) static var _isInitialized: Bool = false
    
    private nonisolated(unsafe) static var _keys: APIKeys?
    private static var keys: APIKeys {
        get {
            guard let keys = _keys else {
                fatalError("Nova key is not set. Please set it up using Nova.setup(teamID:) before using any Nova features.")
            }
            return keys
        }
    }

    public static func setup(teamID: String) {
        guard !_isInitialized else {
            fatalError("Attempted to configure the Nova SDK multiple times. Please only call setup once.")
        }
        
        @Sendable func failConfiguration() -> Never {
            fatalError("Error while configuring Nova SDK. Check your network connection and team ID and try again.")
        }
        
        Task {
            // TODO: Set URL
            let url = URL(string: "")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error {
                    failConfiguration()
                }
                
                guard let data = data else {
                    failConfiguration()
                }
                
                do {
                    let apiKeys = try JSONDecoder().decode(APIKeys.self, from: data)
                    _keys = apiKeys
                } catch {
                    failConfiguration()
                }
            }
            
            task.resume()
        }
        
        _isInitialized = true
    }
    
    public static func setup(openAIKey: String?, stabilityAIKey: String?, humeAIKey: String?) {
        guard !_isInitialized else {
            fatalError("Attempted to configure the Nova SDK multiple times. Please only call setup once.")
        }
        
        _keys = APIKeys(openAI: openAIKey, stabilityAI: stabilityAIKey, humeAI: humeAIKey)
        
        _isInitialized = true
    }
}

internal extension Nova {
    static var openAIKey: String {
        guard let key = keys.openAI else {
            fatalError(
                // TODO: Add specific list of features that require OpenAI or link to a page
                "OpenAI key is not set. Please set it using Nova.setup(openAIKey:) before using any OpenAI-based Nova SDK features."
            )
        }
        return key
    }
    
    static var stabilityAIKey: String {
        guard let key = keys.stabilityAI else {
            fatalError(
                // TODO: Add specific list of features that require StabilityAI or link to a page
                "StabilityAI key is not set. Please set it using Nova.setup(stabilityAIKey:) before using any Stability-based Nova SDK features."
            )
        }
        return key
    }
    
    static var humeAIKey: String {
        guard let key = keys.humeAI else {
            fatalError(
                // TODO: Add specific list of features that require HumeAI or link to a page
                "HumeAI key is not set. Please set it using Nova.setup(humeAIKey:) before using any Hume-based Nova SDK features."
            )
        }
        return key
    }
}

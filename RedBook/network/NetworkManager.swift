import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(url: URL,
                               method: String,
                               body: Data? = nil,
                               completion: @escaping (Result<T, Error>) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let noDataError = NSError(domain: "NetworkManager",
                                          code: -1,
                                          userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(noDataError))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func get<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, method: "GET", completion: completion)
    }
    
    func post<T: Decodable>(url: URL, body: Data?, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, method: "POST", body: body, completion: completion)
    }
    
    func delete<T: Decodable>(url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        request(url: url, method: "DELETE", completion: completion)
    }
}

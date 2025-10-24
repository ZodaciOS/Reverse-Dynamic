import Foundation

public enum IPCError: Error {
    case invalidURL
    case serverError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case networkError(Error)
    case timeout
}

public final class IPCClient: @unchecked Sendable {
    public static let shared = IPCClient()
    public var host: String = "127.0.0.1"
    public var port: Int = 31337
    public var useTLS: Bool = false
    public var timeout: TimeInterval = 6.0
    public var mockFallback: Bool = true

    private var baseURL: URL? {
        let scheme = useTLS ? "https" : "http"
        return URL(string: "\(scheme)://\(host):\(port)")
    }

    private let session: URLSession

    public init() {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest = 8.0
        cfg.waitsForConnectivity = true
        self.session = URLSession(configuration: cfg)
    }

    public func getJSON<T: Decodable>(_ path: String, query: [String:String]? = nil, completion: @escaping (Result<T, IPCError>) -> Void) {
        guard var url = baseURL else { completion(.failure(.invalidURL)); return }
        url.appendPathComponent(path)
        if let q = query, !q.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            comps?.queryItems = q.map { URLQueryItem(name:$0.key, value:$0.value) }
            if let u = comps?.url { url = u }
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeout
        let task = session.dataTask(with: req) { data, resp, err in
            if let err = err {
                completion(.failure(.networkError(err)))
                return
            }
            guard let http = resp as? HTTPURLResponse else {
                completion(.failure(.invalidURL))
                return
            }
            guard (200..<300).contains(http.statusCode) else {
                completion(.failure(.serverError(statusCode: http.statusCode, data: data)))
                return
            }
            guard let data = data else {
                completion(.failure(.serverError(statusCode: http.statusCode, data: nil)))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let model = try decoder.decode(T.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }

    public func getData(_ path: String, query: [String:String]? = nil, completion: @escaping (Result<Data, IPCError>) -> Void) {
        guard var url = baseURL else { completion(.failure(.invalidURL)); return }
        url.appendPathComponent(path)
        if let q = query, !q.isEmpty {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
            comps?.queryItems = q.map { URLQueryItem(name:$0.key, value:$0.value) }
            if let u = comps?.url { url = u }
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.timeoutInterval = timeout
        let task = session.dataTask(with: req) { data, resp, err in
            if let err = err {
                completion(.failure(.networkError(err))); return
            }
            guard let http = resp as? HTTPURLResponse else { completion(.failure(.invalidURL)); return }
            guard (200..<300).contains(http.statusCode) else { completion(.failure(.serverError(statusCode: http.statusCode, data: data))); return }
            guard let data = data else { completion(.failure(.serverError(statusCode: http.statusCode, data: nil))); return }
            completion(.success(data))
        }
        task.resume()
    }
}

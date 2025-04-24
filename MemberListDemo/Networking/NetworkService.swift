//
//  NetworkService.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Combine
import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private lazy var session: URLSession = URLSession(configuration: .default)
    private let token: String = ""
    
    
    func request<T: Decodable>(_ ep: APIEndpoint,
                               as type: T.Type = T.self) -> AnyPublisher<T, APIError> {
        guard let url = ep.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = ep.method
        ep.headers?.forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }
        req.httpBody = ep.body
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // MARK: -
        print("""
              -----[REQUEST]-------
              \(req.httpMethod ?? "GET") \(req.url?.absoluteString ?? "")
              """)
        if let headers = req.allHTTPHeaderFields { print("Headers: \(headers)") }
        if let body = req.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
        
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session.dataTaskPublisher(for: req)
            .retry(3)
            .mapError { APIError.network($0) }
            .tryMap { output -> Data in
                guard let resp = output.response as? HTTPURLResponse,
                      200..<300 ~= resp.statusCode else {
                    let code = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                    throw APIError.invalidResponse(status: code)
                }
                return output.data
            }
            .handleEvents(receiveOutput: { data in
                if let json = try? JSONSerialization.jsonObject(with: data),
                   let pretty = try? JSONSerialization.data(withJSONObject: json,
                                                            options: .prettyPrinted),
                   let jsonString = String(data: pretty, encoding: .utf8) {
                    print("""
                        ---- [RESPONSE]: \(url.absoluteString):
                        \(jsonString)
                        """)
                } else {
                    print("---- [RESPONSE]: \(url.absoluteString) (\(data.count) bytes)")
                }
            })
            .decode(type: T.self, decoder: decoder)
            .mapError {
                ($0 as? APIError) ?? APIError.decoding($0)
            }
            .catch { error -> AnyPublisher<T, APIError> in
                Fail(error: error).eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

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
    
    func request<T: Decodable>(_ ep: APIEndpoint,
                               as type: T.Type = T.self) -> AnyPublisher<T, APIError> {
        guard let url = ep.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = ep.method
        ep.headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        req.httpBody = ep.body
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return session.dataTaskPublisher(for: req)
            .mapError { APIError.network($0) }
            .tryMap { output -> Data in
                guard let resp = output.response as? HTTPURLResponse,
                      200..<300 ~= resp.statusCode else {
                    let code = (output.response as? HTTPURLResponse)?.statusCode ?? -1
                    throw APIError.invalidResponse(status: code)
                }
                return output.data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError {
                ($0 as? APIError) ?? APIError.decoding($0)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

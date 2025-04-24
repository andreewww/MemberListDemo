//
//  NetworkService.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private init() {}
    
    private lazy var session: URLSession = URLSession(configuration: .default)
    
    func request<T: Decodable>(_ endpoint: APIEndpoint,
                               as type: T.Type = T.self) async throws -> T {
        let req = try RequestBuilder.build(from: endpoint)
        
        let (data, resp) = try await session.data(for: req)
        
        guard let http = resp as? HTTPURLResponse,
              200..<300 ~= http.statusCode else {
            throw APIError.invalidResponse(status: (resp as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
}

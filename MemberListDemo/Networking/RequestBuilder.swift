//
//  RequestBuilder.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

struct RequestBuilder {
    
    static func build(from endpoint: APIEndpoint) throws -> URLRequest {
        guard let url = endpoint.url else { throw APIError.invalidURL }
        
        var req = URLRequest(url: url)
        req.httpMethod = endpoint.method
        endpoint.headers?.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        return req
    }
}

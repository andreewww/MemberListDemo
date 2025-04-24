//
//  APIError.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

enum APIError: Error {
    case invalidURL
    case invalidResponse(status: Int)
    case decoding(Error)
    case network(Error)
    case underlying(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse(let status):
            return "Invalid response with status code:\(status)."
        case .decoding(let err):
            return "Parse JSON error: \(err.localizedDescription)"
        case .network(let err):
            return "Network error: \(err.localizedDescription)"
        case .underlying(let error):
            return "Underlying error: \(error.localizedDescription)"
        }
    }
}

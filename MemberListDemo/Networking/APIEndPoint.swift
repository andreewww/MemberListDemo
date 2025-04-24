//
//  APIEndPoint.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

protocol APIEndpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem]? { get }
    var method: String { get }
    var headers: [String: String]? { get }
}

extension APIEndpoint {
    var scheme: String { "https" }
    var host: String { "api.github.com" }
    var method: String { "GET" }
    var headers: [String: String]? { ["Content-Type": "application/json; charset=utf-8"] }
    
    var url: URL? {
        var component = URLComponents()
        component.scheme = scheme
        component.host   = host
        component.path   = path
        component.queryItems = queryItems
        return component.url
    }
}

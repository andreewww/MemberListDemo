//
//  Endpoint.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

enum Endpoint {
    case usersList(perPage: Int, since: Int)
    case userDetail(login: String)
}

extension Endpoint: APIEndpoint {
    var method: String {
        return "GET"
    }
    
    var path: String {
        switch self {
        case .usersList:
            return "/users"
        case .userDetail(let login):
            return "/users/\(login)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .usersList(let per, let since):
            return [
                .init(name: "per_page", value: String(per)),
                .init(name: "since", value: String(since))
            ]
        case .userDetail:
            return nil
        }
    }
    
    
}

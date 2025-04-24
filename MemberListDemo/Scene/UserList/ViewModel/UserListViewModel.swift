//
//  UserListViewModel.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

protocol UserListViewModelOutput: AnyObject {
    func usersPager(didUpdate list: [UserDetail])
    func usersPager(didChangeLoading isLoading: Bool)
    func usersPager(didReachEnd reached: Bool)
    func usersPager(didFail error: APIError)
}

@MainActor
protocol UserListViewModelProtocol: AnyObject {
    var users: [UserDetail] { get }
    var isLoading: Bool { get }
    var reachedEnd: Bool { get }
    var lastError: APIError? { get }
    
    func refresh() async
    func loadNextPage() async
}

@MainActor
final class UserListViewModel: UserListViewModelProtocol {
    // MARK: - Storage
    var users: [UserDetail] = []
    private var sinceCursor = 0
    private let perPage: Int
    private let service: NetworkService
    
    // MARK: - Output targetUserListViewModelOutput
    weak var output: UserListViewModelOutput?
    
    // MARK: - Init
    init(perPage: Int = 20,
         service: NetworkService = .shared,
         output: UserListViewModelOutput? = nil) {
        self.perPage  = perPage
        self.service  = service
        self.output   = output
    }
    
    // MARK: - State flags
    var isLoading = false {
        didSet { output?.usersPager(didChangeLoading: isLoading) }
    }
    var reachedEnd = false {
        didSet { output?.usersPager(didReachEnd: reachedEnd) }
    }
    var lastError: APIError?
    
    // MARK: - Actions (protocol)
    
    func refresh() async {
        sinceCursor = 0
        reachedEnd  = false
        users.removeAll()
        output?.usersPager(didUpdate: users)
        await loadNextPage()
    }
    
    func loadNextPage() async {
        guard !isLoading, !reachedEnd else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let page: [UserDetail] = try await service.request(
                Endpoint.usersList(perPage: perPage, since: sinceCursor)
            )
            self.users.append(contentsOf: page)
            self.output?.usersPager(didUpdate: self.users)
            
            sinceCursor = page.last?.id ?? sinceCursor
            reachedEnd  = page.count < perPage
        } catch let apiErr as APIError {
            output?.usersPager(didFail: apiErr)
        } catch {
            output?.usersPager(didFail: .underlying(error))
        }
    }
}

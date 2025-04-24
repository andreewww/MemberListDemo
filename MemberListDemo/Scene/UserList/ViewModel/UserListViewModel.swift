//
//  UserListViewModel.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation
import Combine

final class UserListViewModel: ObservableObject {
    @Published private(set) var users: [UserDetail] = []
    @Published private(set) var isLoading = false
    @Published var error: APIError?
    
    private let service = NetworkService.shared
    private var cancellables = Set<AnyCancellable>()
    
    private var since = 0
    private let per = 20
    private var reachedEnd = false
    
    func refresh() {
        since = 0
        reachedEnd = false
        users.removeAll()
        loadNextPage()
    }
    
    func loadNextPage() {
        guard !isLoading, !reachedEnd else { return }
        isLoading = true
        
        service.request(Endpoint.usersList(perPage: per, since: since),
                        as: [UserDetail].self)
        .flatMap { [weak self] page -> AnyPublisher<[UserDetail], APIError> in
            guard let self = self else {
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            
            let detailPublishers = page.map { user in
                self.service.request(Endpoint.userDetail(login: user.login), as: UserDetail.self)
            }
            
            return Publishers.MergeMany(detailPublishers)
                .collect()
                .map { detailedUsers in
                    detailedUsers.sorted { $0.id < $1.id }
                }
                .eraseToAnyPublisher()
        }
        .sink { [weak self] completion in
            guard let self = self else { return }
            self.isLoading = false
            if case .failure(let err) = completion {
                self.error = err
            }
        } receiveValue: { [weak self] detailedUsers in
            guard let self = self else { return }
            self.users.append(contentsOf: detailedUsers)
            self.since = detailedUsers.last?.id ?? self.since
            self.reachedEnd = detailedUsers.count < self.per
        }
        .store(in: &cancellables)
    }
}

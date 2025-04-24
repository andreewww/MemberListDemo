//
//  UserList.swift
//  MemberListDemo
//
//  Created by Quân Dư on 24/4/25.
//

import Foundation

protocol UserBasicInfo: Codable {
    var avatarUrl: String? { get }
    var eventsUrl: String? { get }
    var followersUrl: String? { get }
    var followingUrl: String? { get }
    var gistsUrl: String? { get }
    var gravatarId: String? { get }
    var htmlUrl: String? { get }
    var id: Int? { get }
    var login: String? { get }
    var nodeId: String? { get }
    var organizationsUrl: String? { get }
    var receivedEventsUrl: String? { get }
    var reposUrl: String? { get }
    var siteAdmin: Bool? { get }
    var starredUrl: String? { get }
    var subscriptionsUrl: String? { get }
    var type: String? { get }
    var url: String? { get }
    var userViewType: String? { get }
}

//
//  Protocols.swift
//  InstagramClone
//
//  Created by Mekua on 12/1/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import Foundation
protocol UserProfileHeaderDelegate{
    func handleEditFollowTapped(for header : UserProfileHeaderCollectionViewCell)
    func setUserStats(for header : UserProfileHeaderCollectionViewCell)
    func handleFollowersTapped(for header : UserProfileHeaderCollectionViewCell)
    func handleFollowingTapped(for header : UserProfileHeaderCollectionViewCell)
}
protocol FollowCellDelegate{
    func handleFollowTapped (for cell : FollowCell)
    
    
}
protocol FeedCellDelegate {
    func handleUserNameTapped(for cell: FeedCell)
    func handleOptionsTapped(for cell: FeedCell)
    func handleLikeTapped(for cell: FeedCell)
    func handleCommentTapped(for cell: FeedCell)
    func handleConfigureLikeButton (for cell : FeedCell)
    func handleShowLikes(for cell : FeedCell)
}

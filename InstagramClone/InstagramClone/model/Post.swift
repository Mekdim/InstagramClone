//
//  Post.swift
//  InstagramClone
//
//  Created by Mekua on 7/11/21.
//  Copyright © 2021 cs61. All rights reserved.
//
// needed for creation date
import Foundation
import Firebase
class Post{
    var caption : String!
    var creationDate : Date!
    var imageUrl : String!
    var likes : Int!
    var ownerUid : String!
    var postId : String!
    // so that when we click the user we can go show user
    var user : User?
    init(postId: String!, user: User, dictionary : Dictionary<String, AnyObject>) {
        self.user = user
        self.postId = postId
        if let caption = dictionary["caption"] as? String{
            self.caption = caption
        }
        if let imageUrl = dictionary["imageUrl"] as? String{
            self.imageUrl = imageUrl
        }
        if let ownerUid = dictionary["ownerUid"] as? String{
            self.ownerUid = ownerUid
        }
        if let likes = dictionary["likes"] as? Int{
            self.likes = likes
        }
        if let creationDate = dictionary["creationDate"] as? Double{
            self.creationDate = Date(timeIntervalSince1970: creationDate)
        }
    }
    
}

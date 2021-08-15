//
//  Comment.swift
//  InstagramClone
//
//  Created by Mekua on 7/31/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import Foundation
import Firebase
class Comment {
    var creationDate : Date!
    var uid : String!
    var commentText : String!
    var user : User?
    init(user: User, dictionary : Dictionary<String, AnyObject>){
        self.user = user
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        if let creationDate = dictionary["creationDate"] as? Date {
            self.creationDate = creationDate
        }
    }
}

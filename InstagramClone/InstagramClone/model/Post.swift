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
    var usersLikesRef = Database.database().reference().child("users_likes")
    var postLikesRef = Database.database().reference().child("post_likes")
    var caption : String!
    var creationDate : Date!
    var imageUrl : String!
    var likes : Int!
    var ownerUid : String!
    var postId : String!
    var didLike = false
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
    // make this using firebase increment to make it atomic and use batch to update other document reference too
    func adjustLikes(addLike: Bool, completion: @escaping(Int) ->()){
        guard let currentUid = Auth.auth().currentUser?.uid else{
                       return
        }
        guard let postID = postId else{
            return
        }
        if addLike{
            // these have to be updated in a completion block
            likes = likes + 1
            didLike = true
            usersLikesRef.child(currentUid).updateChildValues([postID:1]) { (err, ref) in
                if let error = err {
                    print (" there was error in user  ref setting value of likes with error  \(error.localizedDescription)")
                    return
                }
            }
            postLikesRef.child(postId).updateChildValues([currentUid:1])
        }else{
            guard likes > 0 else{return}
            likes = likes - 1
            didLike = false
           // do this with completion block and batch update too and update the likes after that
            usersLikesRef.child(currentUid).child(postID).removeValue()
            postLikesRef.child(postId).child(currentUid).removeValue()
        }
        // this will result race condition but just for now
        PostsRef.child(postId).child("likes").setValue(likes) { (err, ref) in
            if let error = err {
                print (" there was error in post ref setting value of likes")
                return
            }
            completion(self.likes)
        }
        print("This post has \(likes!) likes")
        
    }
    
}

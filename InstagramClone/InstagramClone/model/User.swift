//
//  User.swift
//  InstagramClone
//
//  Created by Mekua on 11/24/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import Foundation
import Firebase
class User{
    var userName : String!
    var uid : String!
    var name : String!
    var profileImageUrl : String!
    var isFollowed = false
    var UserFollowingRef = Database.database().reference().child("users_following")
    var UserFollowerRef = Database.database().reference().child("users_followers")
    init(uid :String, dictionary : Dictionary<String, AnyObject>){
        self.uid = uid
        if let userName = dictionary["userName"] as? String {
            self.userName = userName
        }
        if let name = dictionary["fullName"] as? String {
            self.name = name
        }
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    func follow(){
        guard let currentuid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let uid = uid else{
            return
        }
        // this should move down?
        self.isFollowed = true
        // self.uid is optional so dont write that instead write uid
        UserFollowingRef.child(currentuid).updateChildValues([uid:1])
        UserFollowerRef.child(uid).updateChildValues([currentuid:1])
    }
    func unFollow(){
        guard let currentuid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let uid = uid else{
            return
        }
        self.isFollowed = false
        UserFollowingRef.child(currentuid).child(self.uid).removeValue()
        UserFollowerRef.child(uid).child(currentuid).removeValue()
    }
    // the closure outlives the functions it is called in so @escape
    func checkIfUserIsFollowed(completion : @escaping(Bool)->()){
        guard let currentuid = Auth.auth().currentUser?.uid else{
            return
        }
        UserFollowingRef.child(currentuid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(self.uid){
                self.isFollowed  = true
                //print("user is followed")
                completion(true)
            } else{
                self.isFollowed = false
                //print("user is not followed")
                completion(false)
            }
        }
    }
}

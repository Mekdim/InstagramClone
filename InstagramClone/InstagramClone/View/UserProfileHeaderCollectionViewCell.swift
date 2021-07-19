//
//  UserProfileHeaderCollectionViewCell.swift
//  InstagramClone
//
//  Created by Mekua on 11/23/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit
import Firebase
class UserProfileHeaderCollectionViewCell: UICollectionViewCell {
    // Mark Properties
    var UserFollowingRef = Database.database().reference().child("users_following")
    var UserFollowerRef = Database.database().reference().child("users_followers")
    var delegate : UserProfileHeaderDelegate?
    var user : User? {
        didSet {
            // configure edit profile button
            configureEditProfileFollowButton()
            setUserStats(user: user)
            let fullName = user?.name
            nameLabel.text = fullName
            guard let profileImageUrl = user?.profileImageUrl else {
                return
            }
            profileImageView.loadImage(with: profileImageUrl)
        }
    }
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    let nameLabel : UILabel = {
        let label = UILabel()
        label.text = "Hedge Ledger"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        return label
        
    }()
    
    let postLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        let attributedString = NSMutableAttributedString(string: "5\n", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
        let postsAttributedString = NSMutableAttributedString(string: "Posts", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedString.append(postsAttributedString)
        label.attributedText = attributedString
        return label
    }()
    // why lazy var? for gesture recognizer? 
    lazy var followersLabel : UILabel = {
       let label = UILabel()
       label.numberOfLines = 0
       label.textAlignment = .center
       // add here the followers text here to follow label at least with attributed string with number of follow /n
       return label
    }()
    lazy var followingLabel : UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
    }()
    // this button could be following and unfollow button too
    let editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        // this didnt work so took this to init
        //button.addTarget(self, action: //#selector(handleEditProfileFollow), for: .touchUpInside)
        return button
    }()
    let gridButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        return button
    }()
    let listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    let bookMarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    // Mark - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        editProfileButton.addTarget(self, action: #selector(handleEditProfileFollow), for: .touchUpInside)
        
        
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTapped))
        followingTap.numberOfTapsRequired = 1
        followingLabel.isUserInteractionEnabled = true
        followingLabel.addGestureRecognizer(followingTap)
        
        // add gesture recognizer
        let followerTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTapped))
        followerTap.numberOfTapsRequired = 1
        followersLabel.isUserInteractionEnabled = true
        followersLabel.addGestureRecognizer(followerTap)
        
        //self.backgroundColor = .red
        addSubview(profileImageView)
        addSubview(nameLabel)
        profileImageView.anchor(top: self.topAnchor, bottom: nil, left: self.leftAnchor, right: nil, paddingTop: 16, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, width: 80, height: 80)
        nameLabel.anchor(top: profileImageView.bottomAnchor, bottom: nil, left: self.leftAnchor, right: nil, paddingTop: 12, paddingBottom: 0, paddingLeft: 12, paddingRight: 0, width: 0, height: 0)
        configureUserStats()
        profileImageView.layer.cornerRadius = 80/2
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: postLabel.bottomAnchor, bottom: nil, left: postLabel.leftAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 8, paddingRight: 12, width: 0, height: 30)
        
        configureBottomToolBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Mark -- handlers
    func configureUserStats(){
        let stackView = UIStackView(arrangedSubviews: [postLabel,followersLabel, followingLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.anchor(top: topAnchor, bottom: nil, left: profileImageView.rightAnchor, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 12, paddingRight: 12, width: 0, height: 50)
    }
    func setUserStats(user : User?){
        delegate?.setUserStats(for: self)
        
    }
    @objc func handleEditProfileFollow(){
        print("tapped handleditProfileFollow")
        delegate?.handleEditFollowTapped(for: self) 
    }
    @objc func handleFollowersTapped(){
         
        delegate?.handleFollowersTapped(for: self)
    }
    @objc func handleFollowingTapped(){
        
        delegate?.handleFollowingTapped(for: self)
    }
    func configureEditProfileFollowButton(){
        guard let currentuid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let user = self.user else {
            return
        }
        if currentuid == user.uid {
            editProfileButton.setTitle("Edit Profile", for: .normal)
        }
        else{
            user.checkIfUserIsFollowed { (followed) in
                if followed {
                    self.editProfileButton.setTitle("Following", for: .normal)
                }
                else{
                    self.editProfileButton.setTitle("Follow", for: .normal)
                }
            }
           
            editProfileButton.setTitleColor(.white, for: .normal)
            editProfileButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
    func configureBottomToolBar(){
        let topDeviderView = UIView()
        topDeviderView.backgroundColor = .lightGray
        
        let bottomDeviderView = UIView()
        bottomDeviderView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton,listButton, bookMarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        addSubview(topDeviderView)
        addSubview(bottomDeviderView)
        
        stackView.anchor(top: nil, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 50)
        topDeviderView.anchor(top: nil , bottom: stackView.topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0.5)
        bottomDeviderView.anchor(top: stackView.bottomAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0.5)
    }
}

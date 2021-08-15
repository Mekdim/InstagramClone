//
//  FeedCell.swift
//  InstagramClone
//
//  Created by Mekua on 7/13/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import UIKit
import Firebase
class FeedCell: UICollectionViewCell {
    var delegate : FeedCellDelegate?
    var post :Post?{
        didSet {
            guard let ownerUid = post?.ownerUid else{
                return
            }
            guard let imageUrl = post?.imageUrl else{
                return
            }
            guard let likes = post?.likes else{
                return
            }
            // why do this when post has user already?
            Database.fetchUser(with: ownerUid) { (user) in
                self.profileImageView.loadImage(with: user.profileImageUrl)
                self.userNameButton.setTitle(user.userName, for: .normal)
                self.configurePostCaption(user: user)
            }
            postImageView.loadImage(with: imageUrl)
            likesLabel.text = "\(likes)  likes"
            configureLikeButton()
        }
    }
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    let userNameButton : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("UserName", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    let optionsButton : UIButton = {
        let button = UIButton(type: .system)
        // option + 8 for ...
        button.setTitle("•••", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    let postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    let likesButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "like_unselected"), for: .normal)
        button.tintColor = .black
        return button
    }()
    let commentButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.tintColor = .black
        return button
    }()
    let messageButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "send2"), for: .normal)
        button.tintColor = .black
        return button
    }()
    let savePostButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = .black
        return button
    }()
    lazy var  likesLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "3 likes"
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(handleShowLikes))
        likeTap.numberOfTapsRequired  = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(likeTap)
        
        return label
    }()
    let captionLabel : UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        let attributedText = NSMutableAttributedString(string: "user name ", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 12)])
        let attributedText1 = NSMutableAttributedString(string: "here is the caption", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12)])
        attributedText.append(attributedText1)
        label.attributedText = attributedText
        return label
    }()
    let postTimeLabel : UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "2 days ago"
        return label
    }()
     override init(frame: CGRect) {
         super.init(frame: frame)
        userNameButton.addTarget(self, action: #selector(handleUsernameTapped), for: .touchUpInside)
        likesButton.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        optionsButton.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(handleCommentTapped), for: .touchUpInside)
         addSubview(profileImageView)
         profileImageView.anchor(top: topAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40/2
        addSubview(userNameButton)
        userNameButton.anchor(top: nil, bottom: nil, left: profileImageView.rightAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        userNameButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(optionsButton)
        optionsButton.anchor(top: nil, bottom: nil, left: nil, right: rightAnchor , paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 8, width: 0, height: 0)
        optionsButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
        configureActionButtons()
        addSubview(savePostButton)
        savePostButton.anchor(top: postImageView.bottomAnchor, bottom: nil, left: nil, right: rightAnchor, paddingTop: 12, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 20, height: 24)
        
        addSubview(likesLabel)
        // -4 here for paddingtop
        likesLabel.anchor(top: likesButton.bottomAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: -4, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor, bottom: nil, left: leftAnchor, right: rightAnchor, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 8, width: 0, height: 0)
        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor, bottom: nil, left: leftAnchor, right: nil, paddingTop: 8, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        
     }
    func configurePostCaption(user : User){
        guard let post = self.post else{
            return
        }
        guard let caption = post.caption else{
            return
        }
        let attributedText = NSMutableAttributedString(string: user.userName, attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 12)])
        let attributedText1 = NSMutableAttributedString(string: " \(caption) ", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12)])
        attributedText.append(attributedText1)
        captionLabel.attributedText = attributedText
    }
    func configureActionButtons(){
        let stackView = UIStackView(arrangedSubviews: [likesButton,commentButton,messageButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        addSubview(stackView)
        // no padding for top because the buttons already have white spaces in them?
        stackView.anchor(top: postImageView.bottomAnchor, bottom: nil, left: nil, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 120, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    @objc func handleUsernameTapped(){
        delegate?.handleUserNameTapped(for: self)
    }
    @objc func handleOptionsTapped(){
        delegate?.handleOptionsTapped(for: self)
    }
    @objc func handleLikeTapped(){
        delegate?.handleLikeTapped(for: self)
    }
    @objc func handleCommentTapped(){
        delegate?.handleCommentTapped(for: self)
    }
    @objc func handleShowLikes(){
        delegate?.handleShowLikes(for: self)
    }
    func configureLikeButton(){
        delegate?.handleConfigureLikeButton(for: self)
    }
}

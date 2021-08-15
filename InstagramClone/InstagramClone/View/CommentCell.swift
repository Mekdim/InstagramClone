//
//  CommentCellCollectionViewCell.swift
//  InstagramClone
//
//  Created by Mekua on 7/31/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import UIKit

class CommentCell: UICollectionViewCell {
    var comment : Comment? {
        didSet{
            guard let username = comment?.user?.name else{
                return
            }
            guard let profileImageUrl = comment?.user?.profileImageUrl else{
                return
            }
            guard let commentText = comment?.commentText else{
                return
            }
            profileImageView.loadImage(with: profileImageUrl)
            let attributedString = NSMutableAttributedString(string: " \(username) ", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
            let commentAttributedString = NSMutableAttributedString(string: "\(commentText) ", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12)])
            let commentAttributedString2 = NSMutableAttributedString(string: "2d", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            attributedString.append(commentAttributedString)
            attributedString.append(commentAttributedString2)
            commentLabel.attributedText = attributedString
            
        }
    }
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    let commentLabel : UILabel = {
        let label = UILabel()
        let attributedString = NSMutableAttributedString(string: "mekdem ", attributes: [NSAttributedString.Key.font :UIFont.boldSystemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)])
        let commentAttributedString = NSMutableAttributedString(string: "Here is my comment ", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12)])
        let commentAttributedString2 = NSMutableAttributedString(string: "2d", attributes: [NSAttributedString.Key.font :UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedString.append(commentAttributedString)
        attributedString.append(commentAttributedString2)
        label.attributedText = attributedString
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(profileImageView)
              
       profileImageView.anchor(top: nil, bottom: nil, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 48, height: 48)
       profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
       profileImageView.layer.cornerRadius = 48/2
       profileImageView.clipsToBounds = true
        addSubview(commentLabel)
        commentLabel.anchor(top: nil, bottom: nil, left: profileImageView.rightAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 0, height: 0)
        commentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

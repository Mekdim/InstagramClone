//
//  UserPostCell.swift
//  InstagramClone
//
//  Created by Mekua on 7/12/21.
//  Copyright © 2021 cs61. All rights reserved.
//

import UIKit

class UserPostCell: UICollectionViewCell {
    var post : Post? {
        didSet {
       
            
            guard let postImageUrl = post?.imageUrl else{
                return
            }
        
            postImageView.loadImage(with: postImageUrl)
        }
    }
    let postImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postImageView)
        postImageView.anchor(top: topAnchor, bottom: bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 0, paddingBottom: 0, paddingLeft: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

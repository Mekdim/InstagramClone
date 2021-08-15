//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by Mekua on 11/25/20.
//  Copyright © 2020 cs61. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    // make properties
    var user : User? {
        didSet {
           
            guard let userName = user?.userName else{
                return
            }
            guard let profileImageUrl = user?.profileImageUrl else{
                return
            }
            guard let fullName = user?.name else{
                return
            }
            profileImageView.loadImage(with: profileImageUrl)
            self.textLabel?.text = userName
            self.detailTextLabel?.text = fullName
        }
    }
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        profileImageView.anchor(top: nil, bottom: nil, left: leftAnchor, right: nil, paddingTop: 0, paddingBottom: 0, paddingLeft: 8, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48/2
        profileImageView.clipsToBounds = true
        
        self.textLabel?.text = "User name"
        self.detailTextLabel?.text = "Full name"
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 68, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        textLabel?.font  = UIFont.boldSystemFont(ofSize: 12)
        detailTextLabel?.frame = CGRect(x: 68, y: detailTextLabel!.frame.origin.y , width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        detailTextLabel?.font  = UIFont.systemFont(ofSize: 12)
        detailTextLabel?.textColor = .lightGray
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

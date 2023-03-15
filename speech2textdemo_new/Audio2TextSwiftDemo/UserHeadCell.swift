//
//  UserHeadCell.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/24.
//

import UIKit

private let kImgWidth:CGFloat = 32

class UserHeadCell: UICollectionViewCell {
    
    lazy var imageView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kImgWidth * 0.5
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "head")
        return imgView
    }()
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews(){
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(5)
            make.centerX.equalTo(contentView)
            make.width.height.equalTo(kImgWidth)
        }
        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(5)
            make.centerX.equalTo(contentView)
        }
    }
    
    func setIcon(_ icon:String, name:String, isBroadcastor:Bool) {
        contentView.backgroundColor = isBroadcastor ? .red : .white
        nameLabel.text = name
//        imageView.image = UIImage(named: icon)
    }
}

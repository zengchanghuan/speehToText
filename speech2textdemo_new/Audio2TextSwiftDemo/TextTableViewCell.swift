//
//  TextTableViewCell.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/23.
//

import UIKit
import SnapKit

private let kImgWidth:CGFloat = 30

class TextTableViewCell: UITableViewCell {

    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .blue
        return label
    }()
    
    lazy var resultTextLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    lazy var iconImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kImgWidth * 0.5
        imgView.layer.masksToBounds = true
        imgView.image = UIImage(named: "head")
        return imgView
    }()
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(iconImgView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(resultTextLabel)
        contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        layoutUI()
    }
    
    
    func setUid(_ uid:UInt, name:String, text:String) {
        nameLabel.text = name
        resultTextLabel.text = text
    }
    
    func layoutUI() {
    }
    
    func attributedTextWithText(_ text: String) -> NSAttributedString {
        let shadow = NSShadow()
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        shadow.shadowColor = UIColor.white
        let attributedText = NSAttributedString(string: text, attributes: [.shadow:shadow])
        return attributedText
    }
}


class RemoteTextCell: TextTableViewCell {
    override func layoutUI() {
        
        iconImgView.snp.makeConstraints { make in
            make.top.left.equalTo(5)
            make.width.height.equalTo(kImgWidth)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImgView)
            make.left.equalTo(iconImgView.snp.right).offset(5)
        }
        resultTextLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.width.equalTo(contentView.bounds.width - 70)
            make.top.equalTo(contentView).offset(25)
            make.bottom.equalTo(contentView).offset(-5)
        }
    }
}

class LocalTextCell: TextTableViewCell {

    override func layoutUI() {
        iconImgView.snp.makeConstraints { make in
            make.right.equalTo(-5)
            make.top.equalTo(5)
            make.width.height.equalTo(kImgWidth)
        }
        nameLabel.snp.makeConstraints { make in
            make.right.equalTo(iconImgView.snp.left).offset(-5)
            make.top.equalTo(iconImgView)
        }
        resultTextLabel.snp.makeConstraints { make in
            make.right.equalTo(nameLabel)
            make.width.equalTo(contentView.bounds.width - 70)
            make.top.equalTo(contentView).offset(25)
            make.bottom.equalTo(contentView).offset(-5)
        }
    }
}



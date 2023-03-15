//
//  Audio2TextView.swift
//  Audio2TextSwiftDemo
//
//  Created by FanPengpeng on 2022/3/25.
//

import UIKit
import YYText

private let kImgWidth:CGFloat = 40

private let lineHieght:CGFloat = 18
private let lineSpacing:CGFloat = 2

class Audio2TextView: UIView {
    
    var uid:Int64 = 0
    
    var text:String = "" {
        didSet{
            text = text.appending("\n\n")
            let attributedText = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()
            style.lineSpacing = lineSpacing
            style.maximumLineHeight = lineHieght
            style.minimumLineHeight = lineHieght
            attributedText.setAttributes([NSAttributedString.Key.paragraphStyle : style], range: NSMakeRange(0, text.count))
            resultTextView.attributedText = attributedText
        }
    }
    
    func setText(_ content:String,finalLength:Int) {
        let newLineCount = 3
        var newLineStr = ""
        for _ in 0..<newLineCount {
            newLineStr.append("\n")
        }
        let text = content.appending(newLineStr)
        let attributedText = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpacing
        style.maximumLineHeight = lineHieght
        style.minimumLineHeight = lineHieght
        attributedText.setAttributes([NSAttributedString.Key.paragraphStyle : style], range: NSMakeRange(0, text.count))
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: 0xc92f28), range: NSMakeRange(0, finalLength))
        
        resultTextView.attributedText = attributedText
        self.resultTextView.scrollRangeToVisible(NSMakeRange(text.count - newLineCount - 1, 1))
//        self.resultTextView.layoutManager.allowsNonContiguousLayout = false
    }
    
    lazy var nameLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.init(hex: 0x1b1b1b)
        return label
    }()
    
    lazy var resultTextLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.init(hex: 0x141414)
        label.font = UIFont.systemFont(ofSize: 14)
        label.lineBreakMode = .byCharWrapping
        label.text = "I'm talking about it slowly, there is something wrong"
        
        return label
    }()
    
    lazy var resultTextView:YYTextView = {
        let textView = YYTextView()
        textView.textColor = UIColor.init(hex: 0x141414)
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
//        textView.textContainer.lineBreakMode = .byTruncatingMiddle
        textView.isUserInteractionEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return textView
    }()
    
    lazy var iconImgView:UIImageView = {
        let imgView = UIImageView()
        imgView.layer.cornerRadius = kImgWidth * 0.5
        imgView.layer.masksToBounds = true
//        let name = "head\(arc4random() % 4)"
//        imgView.image = UIImage(named: name)
        return imgView
    }()
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubviews() {
        addSubview(iconImgView)
        addSubview(nameLabel)
//        addSubview(resultTextLabel)
        addSubview(resultTextView)
        
        iconImgView.snp.makeConstraints { make in
            make.top.left.equalTo(10)
            make.width.height.equalTo(kImgWidth)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImgView)
            make.left.equalTo(iconImgView.snp.right).offset(10)
        }
//        resultTextLabel.snp.makeConstraints { make in
//            make.left.equalTo(nameLabel)
//            make.width.equalTo(300)
//            make.top.equalTo(30)
//        }
        let height = (lineHieght + lineSpacing) * 4
        resultTextView.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.width.equalTo(300)
            make.top.equalTo(30)
            make.height.equalTo(height)
        }
    }
    
}

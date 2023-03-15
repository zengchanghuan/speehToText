//
//  LanguageAlertCell.swift
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/8.
//

import UIKit

class LanguageAlertCell: UITableViewCell {
    
    var curIndexPath : IndexPath?
    
    var model:LanguageAlertModel?{

        didSet{
            guard let model = model else { return }
            titleLabel.text = model.title
            contenLabel.text = model.code
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        createSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var valueChangedAction:((_ aSwitch: UISwitch,_ curIdex: IndexPath)->(Void))?
    
    func createSubviews(){
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(29)
            make.centerY.equalTo(contentView)
        }
        contentView.addSubview(contenLabel)
        contenLabel.snp.makeConstraints { make in
            make.right.equalTo(-29)
            make.centerY.equalTo(contentView)
        }
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.right.equalTo(-24)
            make.left.equalTo(24)
            make.height.equalTo(0.3)
        }
    }
    
    private lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var contenLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    func setTitle(_ title:String?) -> Void {
        titleLabel.text = title
    }

}

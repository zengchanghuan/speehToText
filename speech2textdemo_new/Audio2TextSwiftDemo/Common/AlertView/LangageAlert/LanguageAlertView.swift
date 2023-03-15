//
//  LanguageAlertView.swift
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/8.
//

import UIKit

enum NodeType {
    case none
    case Language
    
    var title: String {
        switch self {
        case .none: return "none"
        case .Language: return "Language"
        }
    }
}

class LanguageAlertView: UIView {
    
    private let titleText : String = "Languages".L
    private let cancelBtnText : String = "Cancel".L
    
    var didCellClosure: ((_ model : LanguageAlertModel?) -> Void)?
    
    private lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black
        label.textAlignment = .center
        label.text = titleText
        return label
    }()
    
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.tag = 1001
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        btn.setTitle(cancelBtnText, for: .normal)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.backgroundColor = UIColor.clear
        btn.addTarget(self, action: #selector(btnEvent(btn:)), for: .touchUpInside)
        return btn
    }()
    
    
    private lazy var tableView: UITableView = {
        let tableV = UITableView()
        tableV.delegate = self
        tableV.dataSource = self
        tableV.backgroundColor = UIColor.white
        tableV.register(LanguageAlertCell.self, forCellReuseIdentifier: LanguageAlertCell.description())
        tableV.separatorStyle = .none
        
        return tableV
    }()
    
    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    private var dataArray = LanguageAlertModel.createNodeData()
    
    init(type: NodeType) {
        super.init(frame: .zero)
        setupUI()
        if type == .Language {
            tableView.heightAnchor.constraint(equalToConstant: 255).isActive = true
        }
        tableView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {

        addSubview(topView)
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(25)
        }
        
        topView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-15)
            make.width.equalTo(65)
            make.height.equalTo(25)
        }
        
        topView.addSubview(lineView)
        lineView.snp.makeConstraints { make in
            make.bottom.equalTo(topView.snp.bottom)
            make.right.equalTo(-5)
            make.left.equalTo(5)
            make.height.equalTo(0.5)
        }
        
        addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.height.equalTo(255)
        }
        
        self.backgroundColor = .white

        
        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant: 255).isActive = true
        
    }
    
    @objc func btnEvent(btn : UIButton){
        switch btn.tag {
        case 1001:
            didCellClosure?(nil)
            break
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //设置左上右上圆角
        let leftCorners: UIRectCorner = [.topLeft,.topRight]

        let leftPath =  UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: leftCorners, cornerRadii: CGSize(width: 30.0,height: 30.0))

        let shapeLayer = CAShapeLayer.init()

        shapeLayer.frame = self.bounds

        shapeLayer.path = leftPath.cgPath

        self.layer.mask = shapeLayer

        self.clipsToBounds = true
    }
    
}

extension LanguageAlertView: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageAlertCell.description(), for: indexPath) as! LanguageAlertCell
        cell.model = dataArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 51
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat{

        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?{

        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataArray[indexPath.row]
        didCellClosure?(model)
    }
}

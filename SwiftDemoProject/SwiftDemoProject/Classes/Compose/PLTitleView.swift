//
//  PLTitleView.swift
//  WB
//
//  Created by Page on 2017/12/23.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SnapKit

class PLTitleView: UIView {

    // MARK:- 懒加载属性
    fileprivate lazy var titleLabel : UILabel = UILabel()
    fileprivate lazy var screenNameLabel : UILabel = UILabel()
    
    // MARK:- 构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK:- 设置UI界面
extension PLTitleView {
    fileprivate func setupUI() {
        // 1.将子控件添加到view中
        addSubview(titleLabel)
        addSubview(screenNameLabel)
        
        // 2.设置frame
        titleLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(self)
            make.top.equalTo(self)
        }

        screenNameLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(titleLabel.snp.centerX)
            make.top.equalTo(titleLabel.snp.bottom).offset(3)
        }
        
        // 3.设置控件的属性
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        screenNameLabel.font = UIFont.systemFont(ofSize: 14)
        screenNameLabel.textColor = UIColor.lightGray
        
        // 4.设置文字内容
        titleLabel.text = "发微博"
        screenNameLabel.text = UserAccountViewModel.shareIntance.accountItem?.screen_name
    }
}

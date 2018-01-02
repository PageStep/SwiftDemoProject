//
//  TitleButton.swift
//  WB
//
//  Created by Page on 2017/12/18.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

// 自定义button
class TitleButton: UIButton {
    
//----------------------------------------------------------------------
    // MARK:- 重写init函数
    override init(frame: CGRect) {
        super.init(frame : frame)
        
        setImage(UIImage(named: "navigationbar_arrow_down"), for: .normal)
        setImage(UIImage(named: "navigationbar_arrow_up"), for: .selected)
        setTitleColor(UIColor.black, for: .normal)
        sizeToFit()
    }
    
    // swift中规定: 重写控件的init(frame)方法或者init()方法, 必须重写init?(coder aDecoder: NSCoder)方法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//----------------------------------------------------------------------
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        titleLabel!.frame.origin.x = 0
        imageView!.frame.origin.x = titleLabel!.frame.size.width + 5
     }
    
    
}

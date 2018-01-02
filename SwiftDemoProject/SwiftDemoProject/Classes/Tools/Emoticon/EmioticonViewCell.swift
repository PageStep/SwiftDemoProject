//
//  EmioticonViewCell.swift
//  WB-封装表情键盘
//
//  Created by Page on 2017/12/25.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class EmioticonViewCell: UICollectionViewCell {
    // MARK:- 懒加载属性
    fileprivate lazy var emoticonBtn : UIButton = UIButton()
    
    // MARK:- 定义的属性
    var emoticonItem : EmoticonItem? {
        didSet {
            guard let emoticonItem = emoticonItem else {
                return
            }
            
            // 1.设置emoticonBtn的内容
            emoticonBtn.setImage(UIImage(contentsOfFile: emoticonItem.pngPath ?? ""), for: .normal)
            emoticonBtn.setTitle(emoticonItem.emojiCode, for: .normal)
            
            // 2.设置删除按钮
            if emoticonItem.isRemove {
                emoticonBtn.setImage(UIImage(named: "compose_emotion_delete"), for: .normal)
            }
        }
    }
    
    // MARK:- 重写构造函数
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- 设置UI界面内容
extension EmioticonViewCell {
    fileprivate func setupUI() {
        // 1.添加子控件
        contentView.addSubview(emoticonBtn)
        
        // 2.设置btn的frame
        emoticonBtn.frame = contentView.bounds
        
        // 3.设置btn属性
        emoticonBtn.isUserInteractionEnabled = false
        emoticonBtn.titleLabel?.font = UIFont.systemFont(ofSize: 32)
    }
}

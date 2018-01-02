//
//  WelcomeViewController.swift
//  WB
//
//  Created by Page on 2017/12/21.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SDWebImage

class WelcomeViewController: UIViewController {

    // MARK:- 拖线的属性
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var iconViewBottomCons: NSLayoutConstraint!
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 0.设置头像
        let profileURLString = UserAccountViewModel.shareIntance.accountItem?.avatar_large
    
        let url = NSURL(string: profileURLString ?? "")
        iconView.sd_setImage(with: url! as URL, placeholderImage: UIImage(named: "avatar_default_big"))
      
        
        // 1.改变约束的值
        iconViewBottomCons.constant = UIScreen.main.bounds.height - 200
        
        // 2.执行动画
        // Damping : 阻力系数,阻力系数越大,弹动的效果越不明显 0~1
        // initialSpringVelocity : 初始化速度
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 5.0, options: [], animations: { () -> Void in
            self.view.layoutIfNeeded()
        }) { (_) -> Void in
            // 3.将创建根控制器改成从Main.storyboard加载
            UIApplication.shared.keyWindow?.rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        }
    }
}

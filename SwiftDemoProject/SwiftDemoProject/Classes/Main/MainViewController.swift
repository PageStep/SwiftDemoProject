//
//  MainViewController.swift
//  WB
//
//  Created by Page on 2017/12/15.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {
    
    // MARK:- 懒加载属性
    fileprivate lazy var composeBtn : UIButton = UIButton(imageName: "tabbar_compose_icon_add", bgImageName: "tabbar_compose_button")
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupComposeBtn()
    }
}


// MARK:- 设置UI界面
extension MainViewController {
    /// 设置发布按钮
    fileprivate func setupComposeBtn() {
        // 1.将composeBtn添加到tabbar中
        tabBar.addSubview(composeBtn)
        
        // 2.设置位置
        composeBtn.center = CGPoint(x: tabBar.center.x, y: tabBar.bounds.size.height * 0.5)
        
        // 3.监听发布按钮的点击
        composeBtn.addTarget(self, action: #selector(composeBtnClick), for: .touchUpInside)
    }
}


// MARK:- 事件监听
extension MainViewController {
 
    @objc fileprivate func composeBtnClick() {
        // 1.创建发布控制器
        let composeVc = ComposeViewController()
        
        // 2.包装导航控制器
        let composeNav = UINavigationController(rootViewController: composeVc)
        
        // 3.弹出控制器
        present(composeNav, animated: true, completion: nil)
    }
}


//
//  BaseViewController.swift
//  WB
//
//  Created by Page on 2017/12/18.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

class BaseViewController: UITableViewController {

    // MARK:- 懒加载属性
    lazy var visitorView : VisitorView = VisitorView.visitorView()
    
    // MARK:- 定义变量
    var isLogin : Bool = UserAccountViewModel.shareIntance.isLogin
    
    // MARK:- 系统回调函数
    override func loadView() {
        
        isLogin ? super.loadView() : setupVisitorView()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isLogin {
            setupNavigationItems()
        }
    
    }
    
}

// MARK:- 设置UI界面
extension BaseViewController {
    /// 设置访客视图
    fileprivate func setupVisitorView() {
        view = visitorView
        
        // 监听访客视图中`注册`和`登录`按钮的点击
        visitorView.registerBtn.addTarget(self, action: #selector(registerBtnClick), for: .touchUpInside)
        visitorView.loginBtn.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
    }
    
    /// 设置导航栏左右的Item
    fileprivate func setupNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(registerBtnClick))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(loginBtnClick))
    }

}


// MARK:- 事件监听
extension BaseViewController {
    // MARK:- 事件监听
    @objc fileprivate func registerBtnClick() {
        print("registerBtnClick")
    }
    
    @objc fileprivate func loginBtnClick() {
        // 1.创建授权控制器
        let authVc = AuthViewController()
        
        // 2.包装导航栏控制器
        let authNav = UINavigationController(rootViewController: authVc)
        
        // 3.弹出控制器
        present(authNav, animated: true, completion: nil)
    }

}



//
//  AuthViewController.swift
//  WB
//
//  Created by Page on 2017/12/19.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SVProgressHUD

class AuthViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置导航栏的内容
        setupNavigationBar()
        
        // 2.加载网页
        loadPage()
    }
    
}


// MARK:- 设置UI界面相关
extension AuthViewController {
    fileprivate func setupNavigationBar() {
        // 1.设置左侧的item
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeItemClick))
        
        // 2.设置右侧的item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "填充", style: .plain, target: self, action: #selector(fillItemClick))
        
        // 3.设置标题
        title = "登录页面"
    }
    
    fileprivate func loadPage() {
        // 1.获取登录页面的URLString
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(app_key)&redirect_uri=\(redirect_uri)"
        
        // 2.创建对应NSURL
        guard let url = NSURL(string: urlString) else {
            return
        }
        
        // 3.创建NSURLRequest对象
        let request = NSURLRequest(url: url as URL)
        
        // 4.加载request对象
        webView.loadRequest(request as URLRequest)
    }
}



// MARK:- 事件监听函数
extension AuthViewController {
    @objc fileprivate func closeItemClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func fillItemClick() {
        // 1.书写js代码 : javascript / java --> 雷锋和雷峰塔
        let jsCode = "document.getElementById('userId').value='xxx@qq.com';document.getElementById('passwd').value='xxx';"
        
        // 2.执行js代码
        webView.stringByEvaluatingJavaScript(from: jsCode)
    }
}


// MARK:- webView的delegate方法
extension AuthViewController : UIWebViewDelegate {
    
    // webView开始加载网页
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()
    }
    
    // webView网页加载完成
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    // webView加载网页失败
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        SVProgressHUD.dismiss()
    }
    
    
    // 当准备加载某一个页面时,会执行该方法
    // 返回值: true -> 继续加载该页面 false -> 不会加载该页面
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // 1.获取加载网页的NSURL
        guard let url = request.url else {
            return true
        }
        
        // 2.获取url中的字符串
        let urlString = url.absoluteString
        
        
        // 3.判断该字符串中是否包含code
        guard urlString.contains("code=") else {
            return true
        }
        
        // 4.将code截取出来
        let code = urlString.components(separatedBy: "code=").last!
        
        // 5.请求accessToken
        loadAccessToken(code: code)
        
        return false
    }
}


// MARK:- 请求数据
extension AuthViewController {
    /// 请求AccessToken
    fileprivate func loadAccessToken(code : String) {
        NetworkTool.shareInstance.loadAccessToken(code: code) { (result, error) -> () in
            
            // 1.错误校验
            if error != nil {
                print(error!)
                return
            }
            
            // 2.拿到结果
            guard let accountDict = result else {
                print("没有获取授权后的数据")
                return
            }
            print("success")
            
            // 3.将字典转成模型对象
            let account = UserAccountItem(dict: accountDict)
            
            
            // 4.请求用户信息
            self.loadUserInfo(account: account)
        }
    }
    
    
    /// 请求用户信息
    fileprivate func loadUserInfo(account : UserAccountItem) {
        // 1.获取AccessToken
        guard let accessToken = account.access_token else {
            return
        }
        
        // 2.获取uid
        guard let uid = account.uid else {
            return
        }
        
        // 3.发送网络请求
        NetworkTool.shareInstance.loadUserInfo(access_token: accessToken, uid: uid) { (result, error) -> () in
            // 1.错误校验
            if error != nil {
                print(error!)
                return
            }
            
            // 2.拿到用户信息的结果
            guard let userInfoDict = result else {
                return
            }
            
            // 3.从字典中取出昵称和用户头像地址
            account.screen_name = userInfoDict["screen_name"] as? String
            account.avatar_large = userInfoDict["avatar_large"] as? String
            
//            print(account)
            
            // 4.将account对象保存
            NSKeyedArchiver.archiveRootObject(account, toFile: UserAccountViewModel.shareIntance.accountItemPath)
            
            // 5.将account对象设置到单例对象中
            UserAccountViewModel.shareIntance.accountItem = account
            
            // 6.退出当前控制器
            self.dismiss(animated: false, completion: { () -> Void in
                UIApplication.shared.keyWindow?.rootViewController = WelcomeViewController()
            })

        }
    }
}

//
//  NetworkTool.swift
//  WB
//
//  Created by Page on 2017/12/19.
//  Copyright © 2017年 Page. All rights reserved.
//

import AFNetworking
import SVProgressHUD

// 定义枚举类型
enum RequestType : String {
    case GET = "GET"
    case POST = "POST"
}

class NetworkTool: AFHTTPSessionManager {
    
    // 实现单例
    static let shareInstance : NetworkTool = {
        let tools = NetworkTool()
        tools.responseSerializer.acceptableContentTypes?.insert("text/html")
        tools.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        return tools
    }()
}

// MARK:- 封装请求方法
extension NetworkTool {
    

    func request(methodType : RequestType, urlString : String, parameters : [String : AnyObject], finished : @escaping (AnyObject?, NSError?) -> ()) {
        
        if methodType == .GET {
            
            get(urlString, parameters: parameters, progress: nil, success: { (URLSessionDataTask, result) in
                finished(result as AnyObject, nil)
            }, failure: { (URLSessionDataTask, error) in
                finished(nil, error as NSError)
            })
            
        } else {
            post(urlString, parameters: parameters, progress: nil, success: { (URLSessionDataTask, result) in
                finished(result as AnyObject, nil)
            }, failure: { (URLSessionDataTask, error) in
                finished(nil, error as NSError)
            })
        }
        
    }
    
}


// MARK:- 请求AccessToken
extension NetworkTool {
    func loadAccessToken(code : String, finished : @escaping ( [String : AnyObject]?, NSError?) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/oauth2/access_token"
        
        // 2.获取请求的参数
        let parameters = ["client_id" : app_key, "client_secret" : app_secret, "grant_type" : "authorization_code", "redirect_uri" : redirect_uri, "code" : code]
        
        // 3.发送网络请求
        request(methodType: .POST, urlString: urlString, parameters: parameters as [String : AnyObject]) { (result, error) in
            finished(result as? [String : AnyObject], error)
        }
    }
}


// MARK:- 请求用户的信息
extension NetworkTool {
    func loadUserInfo(access_token : String, uid : String, finished : @escaping ([String : AnyObject]?, NSError?) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/2/users/show.json"
        
        // 2.获取请求的参数
        let parameters = ["access_token" : access_token, "uid" : uid]
        
        // 3.发送网络请求
        request(methodType: .GET, urlString: urlString, parameters: parameters as [String : AnyObject]) { (result, error) in
            finished(result as? [String : AnyObject] , error)
        }
 
    }
}

// MARK:- 请求首页数据
extension NetworkTool {
    func loadStatuses(since_id : Int, max_id : Int, finished : @escaping([[String : AnyObject]]?, NSError?) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/2/statuses/home_timeline.json"
        
        // 2.获取请求的参数
        let accessToken = UserAccountViewModel.shareIntance.accountItem?.access_token!
        let parameters = ["access_token" : accessToken, "since_id" : "\(since_id)", "max_id" : "\(max_id)"]
        
        // 3.发送网络请求
        request(methodType: .GET, urlString: urlString, parameters: parameters as [String : AnyObject]) { (result, error) -> () in
            
            // 1.获取字典的数据
            guard let resultDict = result as? [String : AnyObject] else {
                finished(nil, error)
                return
            }
            
            // 2.将数组数据回调给外界控制器
            finished(resultDict["statuses"] as? [[String : AnyObject]], error)
        }
    }
}

// 注意: 新浪开放平台已经把关于发布的接口, 升级切换为新的分享接口: statuses/share (第三方分享链接到微博)
// MARK:- 发送微博
extension NetworkTool {
    func sendStatus(statusText : String, isSuccess : @escaping (Bool) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        
        // 2.获取请求的参数
        guard let accessToken = UserAccountViewModel.shareIntance.accountItem?.access_token else {
            SVProgressHUD.showError(withStatus: "未登录!")
            return
        }
        let parameters = ["access_token" : accessToken, "status" : statusText]
        
        // 3.发送网络请求
        request(methodType: .POST, urlString: urlString, parameters: parameters as [String : AnyObject]) { (result, error) -> () in
            if result != nil {
                isSuccess(true)
            } else {
                isSuccess(false)
            }
        }
    }
}


// MARK:- 发送微博并且携带照片
extension NetworkTool {
    func sendStatus(statusText : String, image : UIImage, isSuccess : @escaping(Bool) -> ()) {
        // 1.获取请求的URLString
        let urlString = "https://api.weibo.com/2/statuses/share.json"
        
        // 2.获取请求的参数
        guard let accessToken = UserAccountViewModel.shareIntance.accountItem?.access_token else {
            SVProgressHUD.showError(withStatus: "未登录!")
            return
        }
        let parameters = ["access_token" : accessToken, "status" : statusText]
        
        // 3.发送网络请求
        post(urlString, parameters: parameters, constructingBodyWith: { (formData) -> Void in
            
            if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                formData.appendPart(withFileData: imageData, name: "pic", fileName: "123.png", mimeType: "image/png")
            }
            
        }, progress: nil, success: { (_, _) -> Void in
            isSuccess(true)
        }) { (_, error) -> Void in
            print(error)
        }
    }
}


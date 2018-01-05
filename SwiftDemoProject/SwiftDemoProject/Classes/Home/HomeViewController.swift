//
//  HomeViewController.swift
//  WB
//
//  Created by Page on 2017/12/15.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SDWebImage
import MJRefresh

class HomeViewController: BaseViewController {

    // MARK:- 懒加载属性
    fileprivate lazy var titleBtn : TitleButton = TitleButton()
    
     // 两个地方需要使用self : 1> 如果在一个函数中出现歧义 2> 在闭包中使用当前对象的属性和方法也需要加self
    fileprivate lazy var popoverAnimator : PLPopoverAnimator = PLPopoverAnimator {[weak self] (presented) -> () in
        self?.titleBtn.isSelected = presented
    }
    
     // 模型数组属性
    fileprivate lazy var viewModels : [StatusViewModel] =
        [StatusViewModel]()
    
    fileprivate lazy var tipLabel : UILabel = UILabel()
    
    fileprivate lazy var photoBrowserAnimator : PhotoBrowserAnimator = PhotoBrowserAnimator()
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.没有登录时, 设置的内容
        if !isLogin {
            
            visitorView.addRotationAnim()
            
            return
        }
        
        // 2.设置导航栏的内容
        setupNavigationItems()
        
        
        // 自动根据子控件调整高度
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        // 3.设置估算高度
        tableView.estimatedRowHeight = 200
        
        // 4.设置刷新控件
        setupHeaderView()
        setupFooterView()
        
        // 5.设置刷新后的tipLabel
        setupTipLabel()
        
        // 6.监听通知
        setupNatifications()
        
        // 7.刷新数据
        tableView.mj_header.beginRefreshing()
    }
}


// MARK:- 设置UI界面
extension HomeViewController {
    
    fileprivate func setupNavigationItems() {
        // 1.设置左侧的Item
        navigationItem.leftBarButtonItem = UIBarButtonItem(imageName: "navigationbar_friendattention")
        
        // 2.设置右侧的Item
        navigationItem.rightBarButtonItem = UIBarButtonItem(imageName: "navigationbar_pop")
        
        // 3.设置titleView
        titleBtn.setTitle("coderPL", for: .normal)

        titleBtn.addTarget(self, action: #selector(titleBtnClick(titleBtn:)), for: .touchUpInside)
        navigationItem.titleView = titleBtn
    }
    
    fileprivate func setupHeaderView() {
        // 1.创建headerView
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadNewStatuses))
        
        // 2.设置header的属性
        header?.setTitle("下拉刷新", for: .idle)
        header?.setTitle("释放更新", for: .pulling)
        header?.setTitle("加载中...", for: .refreshing)
        
        // 3.设置tableView的header
        tableView.mj_header = header
        
    }
    
    fileprivate func setupFooterView() {
        tableView.mj_footer = MJRefreshAutoFooter(refreshingTarget: self, refreshingAction: #selector(loadMoreStatuses))
    }
    
    fileprivate func setupTipLabel() {
        // 1.将tipLabel添加父控件中
        navigationController?.navigationBar.insertSubview(tipLabel, at: 0)
        
        // 2.设置tipLabel的frame
        tipLabel.frame = CGRect(x: 0, y: 10, width: UIScreen.main.bounds.width, height: 32)
        
        // 3.设置tipLabel的属性
        tipLabel.backgroundColor = UIColor.orange
        tipLabel.textColor = UIColor.white
        tipLabel.font = UIFont.systemFont(ofSize: 14)
        tipLabel.textAlignment = .center
        tipLabel.isHidden = true
    }
    
    fileprivate func setupNatifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(showPhotoBrowser(note:)), name: NSNotification.Name(rawValue: ShowPhotoBrowserNote), object: nil)
       
    }
}


// MARK:- 事件监听的函数
extension HomeViewController {
    @objc fileprivate func titleBtnClick(titleBtn : TitleButton) {

        // 按钮的状态 由 PLPopoverAnimator 控制
        
        
        // 1.创建弹出的控制器
        let popoverVc = PopoverViewController()
        
        // 2.设置控制器的modal样式, 设置后, modal之前的view不会被移除
        popoverVc.modalPresentationStyle = .custom
        
        // 3.设置转场的代理
        popoverVc.transitioningDelegate = popoverAnimator
        popoverAnimator.presentedFrame = CGRect(x: 100, y: 55, width: 180, height: 250)
        
        // 4.弹出控制器
        present(popoverVc, animated: true, completion: nil)
    }
    
    @objc fileprivate func showPhotoBrowser(note : Notification) {
        // 0.取出数据
        let indexPath = note.userInfo![ShowPhotoBrowserIndexKey] as! NSIndexPath
        let picURLs = note.userInfo![ShowPhotoBrowserUrlsKey] as! [NSURL]
        let object = note.object as! PicCollectionView
        
        // 1.创建控制器
        let photoBrowserVc = PhotoBrowserController(indexPath: indexPath, picURLs: picURLs)
        
        // 2.设置modal样式
        photoBrowserVc.modalPresentationStyle = .custom
        
        // 3.设置转场的代理
        photoBrowserVc.transitioningDelegate = photoBrowserAnimator
        
        // 4.设置动画的代理
        photoBrowserAnimator.presentedDelegate = object as? AnimatorPresentedDelegate
        photoBrowserAnimator.indexPath = indexPath
        photoBrowserAnimator.dismissDelegate = photoBrowserVc
        
        // 以modal的形式弹出控制器
        present(photoBrowserVc, animated: true, completion: nil)
    }
}

// MARK:- 请求数据
extension HomeViewController {
    
    /// 加载最新数据
    @objc fileprivate func loadNewStatuses() {
        loadStatusesData(isNewData: true)
    }
    
    /// 加载更多数据
    @objc fileprivate func loadMoreStatuses() {
        loadStatusesData(isNewData: false)
    }

    fileprivate func loadStatusesData(isNewData : Bool) {
        
        // 1.获取since_id/max_id
        var since_id = 0
        var max_id = 0
        if isNewData {
            since_id = viewModels.first?.status?.mid ?? 0
        } else {
            max_id = viewModels.last?.status?.mid ?? 0
            max_id = max_id == 0 ? 0 : (max_id - 1)
        }

        // 请求数据
        NetworkTool.shareInstance.loadStatuses(since_id: since_id, max_id: max_id) { (result, error) in
            // 1.错误校验
            if error != nil {
                print(error!)
                return
            }
            
            // 2.获取可选类型中的数据
            guard let resultArray = result else {
                return
            }
            
            // 3.遍历微博对应的字典
            var tempViewModel = [StatusViewModel]()
            
            for statusDict in resultArray {
                let status = StatusItem(dict: statusDict)
                let viewModel = StatusViewModel(status: status)
                tempViewModel.append(viewModel)
            }
            
            // 4.将数据放入到成员变量的数组中
            if isNewData {
                self.viewModels = tempViewModel + self.viewModels
            } else {
                self.viewModels += tempViewModel
            }
            
            // 5.缓存图片
            self.cacheImages(viewModels: tempViewModel)
            
//            self.tableView.reloadData()
        }
        
    }
    
    /// 缓存图片
    fileprivate func cacheImages(viewModels : [StatusViewModel]) {
        // 0.创建group
        let group = DispatchGroup()
        
        // 1.缓存图片
        for viewmodel in viewModels {
            for picURL in viewmodel.picURLs {
                group.enter()
                
                SDWebImageManager.shared().downloadImage(with: picURL as URL!, options: [], progress: nil, completed: { (_, _, _, _, _) -> Void in
                    group.leave()
                    
                })
            }
        }
        
        // 2.图片缓存之后, 回到主线程刷新表格
        group.notify(queue: DispatchQueue.main) { () -> Void in
            
            // 刷新表格
            self.tableView.reloadData()
            
            // 停止刷新
            self.tableView.mj_header.endRefreshing()
            self.tableView.mj_footer.endRefreshing()
            
            // 显示提示的Label
            self.showTipLabel(count: viewModels.count)
        }

    }
    
    
    /// 显示提示的Label
    private func showTipLabel(count : Int) {
        // 1.设置tipLabel的属性
        tipLabel.isHidden = false
        tipLabel.text = count == 0 ? "没有新数据" : "\(count) 条新微博"
        
        // 2.执行动画
        UIView.animate(withDuration: 1.0, animations: { () -> Void in
            self.tipLabel.frame.origin.y = 44
        }) { (_) -> Void in
            UIView.animate(withDuration: 1.0, delay: 1.5, options: [], animations: { () -> Void in
                self.tipLabel.frame.origin.y = 10
            }, completion: { (_) -> Void in
                self.tipLabel.isHidden = true
            })
        }
    }

}


// MARK:- tableView的数据源方法和代理方法
extension HomeViewController {
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 1.创建cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeStatusViewCell") as! HomeStatusViewCell
        
        // 2.给cell设置数据
        cell.viewModel = viewModels[indexPath.row]
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 1.获取模型对象
        let viewModel = viewModels[indexPath.row]
        
        return viewModel.cellHeight
    }
    
}

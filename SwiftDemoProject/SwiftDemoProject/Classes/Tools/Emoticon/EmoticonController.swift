//
//  EmoticonController.swift
//  WB-封装表情键盘
//
//  Created by Page on 2017/12/25.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit

private let EmoticonCell = "EmoticonCell"

class EmoticonController: UIViewController {
    
    // MARK:- 定义属性
    var emoticonCallBack : (_ emoticon : EmoticonItem) -> ()

    // MARK:- 懒加载属性
    fileprivate lazy var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmoticonCollectionViewLayout())
    fileprivate lazy var toolBar : UIToolbar = UIToolbar()
    fileprivate lazy var manager = EmoticonManager()
    
    // MARK:- 自定义构造函数
    init(emoticonCallBack : @escaping (_ emoticon : EmoticonItem) -> ()) {
        self.emoticonCallBack = emoticonCallBack
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // MARK:- 系统回调函数
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
}


// MARK:- 设置UI界面内容
extension EmoticonController {
    fileprivate func setupUI() {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolBar)
        collectionView.backgroundColor = UIColor.gray
        toolBar.backgroundColor = UIColor.darkGray
        
        // 2.设置子控件的frame
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tBar" : toolBar, "cView" : collectionView] as [String : Any]
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tBar]-0-|", options: [], metrics: nil, views: views)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cView]-0-[tBar]-0-|", options: [.alignAllLeft, .alignAllRight], metrics: nil, views: views)
        view.addConstraints(cons)
        
        // 3.准备collectionView
        prepareForCollectionView()
        
        // 4.准备toolBar
        prepareForToolBar()
    }
    
    private func prepareForCollectionView() {
        collectionView.register(EmioticonViewCell.self, forCellWithReuseIdentifier: EmoticonCell)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    private func prepareForToolBar() {
        // 1.定义toolBar中titles
        let titles = ["最近", "默认", "emoji", "浪小花"]
        
        // 2.遍历标题,创建item
        var index = 0
        var tempItems = [UIBarButtonItem]()
        for title in titles {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(itemClick(item:)))
            
            item.tag = index
            index += 1
            
            tempItems.append(item)
            tempItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        }
        
        // 3.设置toolBar的items数组
        tempItems.removeLast()
        toolBar.items = tempItems
        toolBar.tintColor = UIColor.orange
    }
    
    @objc fileprivate func itemClick(item : UIBarButtonItem) {
        // 1.获取点击的item的tag
        let tag = item.tag
        
        // 2.根据tag获取到当前组
        let indexPath = NSIndexPath(item: 0, section: tag)
        
        // 3.滚动到对应的位置
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: true)
    }
}


// MARK:- collectionView的数据源和代理方法
extension EmoticonController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return manager.packages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let package = manager.packages[section]
        
        return package.emoticonItems.count
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.创建cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmoticonCell, for: indexPath) as! EmioticonViewCell
        
        // 2.给cell设置数据
        let package = manager.packages[indexPath.section]
        let emoticonItem = package.emoticonItems[indexPath.item]
        cell.emoticonItem = emoticonItem
        
        return cell

    }
   
    
    /// 代理方法
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 1.取出点击的表情
        let package = manager.packages[indexPath.section]
        let emoticonItem = package.emoticonItems[indexPath.item]
        
        // 2.将点击的表情插入最近分组中
        insertRecentlyEmoticon(emoticonItem: emoticonItem)
        
        // 3.将表情回调给外界控制器
        emoticonCallBack(emoticonItem)
    }

    
    private func insertRecentlyEmoticon(emoticonItem : EmoticonItem) {
        // 1.如果是空白表情或者删除按钮,不需要插入
        if emoticonItem.isRemove || emoticonItem.isEmpty {
            return
        }
        
        // 2.删除一个表情
        if manager.packages.first!.emoticonItems.contains(emoticonItem) { // 原来有该表情
            let index = (manager.packages.first?.emoticonItems.index(of: emoticonItem))!
            manager.packages.first?.emoticonItems.remove(at: index)
        } else { // 原来没有这个表情
            manager.packages.first?.emoticonItems.remove(at: 19)
        }
        
        // 3.将emoticon插入最近分组中
        manager.packages.first?.emoticonItems.insert(emoticonItem, at: 0)
    }
}




class EmoticonCollectionViewLayout : UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        // 1.计算itemWH
        let itemWH = UIScreen.main.bounds.width / 7
        
        // 2.设置layout的属性
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        
        // 3.设置collectionView的属性
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        let insetMargin = (collectionView!.bounds.height - 3 * itemWH) / 2
        collectionView?.contentInset = UIEdgeInsets(top: insetMargin, left: 0, bottom: insetMargin, right: 0)
    }
}

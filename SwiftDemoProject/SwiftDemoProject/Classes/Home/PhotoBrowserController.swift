//
//  PhotoBrowserController.swift
//  WB
//
//  Created by Page on 2017/12/27.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SnapKit
import SVProgressHUD

private let PhotoBrowserCell = "PhotoBrowserCell"

class PhotoBrowserController: UIViewController {
    
    // MARK:- 定义属性
    var indexPath : NSIndexPath
    var picURLs : [NSURL]
    
    // MARK:- 懒加载属性
    fileprivate lazy var collectionView : UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: PhotoBrowserCollectionViewLayout())
    fileprivate lazy var closeBtn : UIButton = UIButton(bgColor: UIColor.darkGray, fontSize: 14, title: "关 闭")
    fileprivate lazy var saveBtn : UIButton = UIButton(bgColor: UIColor.darkGray, fontSize: 14, title: "保 存")
    
    // MARK:- 自定义构造函数
    init(indexPath : NSIndexPath, picURLs : [NSURL]) {
        self.indexPath = indexPath
        self.picURLs = picURLs
        
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- 系统回调函数
    
    override func loadView() {
        super.loadView()
        
        view.frame.size.width += 20
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.设置UI界面
        setupUI()
        
        // 2.滚动到对应的图片
        collectionView.scrollToItem(at: indexPath as IndexPath, at: .left, animated: false)
    }
    
}


// MARK:- 设置UI界面内容
extension PhotoBrowserController {
    fileprivate func setupUI() {
        // 1.添加子控件
        view.addSubview(collectionView)
        view.addSubview(closeBtn)
        view.addSubview(saveBtn)
        
        // 2.设置frame
        collectionView.frame = view.bounds
        closeBtn.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(20)
            make.bottom.equalTo(-20)
            make.size.equalTo(CGSize(width: 90, height: 32))
        }
        saveBtn.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(-40)
            make.bottom.equalTo(closeBtn.snp.bottom)
            make.size.equalTo(closeBtn.snp.size)
        }
        
        // 3.设置collectionView的属性
        collectionView.register(PhotoBrowserViewCell.self, forCellWithReuseIdentifier: PhotoBrowserCell)
        collectionView.dataSource = self
        
        // 4.监听两个按钮的点击
        closeBtn.addTarget(self, action: #selector(closeBtnClick), for: .touchUpInside)
        saveBtn.addTarget(self, action: #selector(saveBtnClick), for: .touchUpInside)
    }
}


// MARK:- 事件监听函数
extension PhotoBrowserController {
    @objc fileprivate func closeBtnClick() {
        SVProgressHUD.dismiss()
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func saveBtnClick() {
        // 1.获取当前正在显示的image
        let cell = collectionView.visibleCells.first as! PhotoBrowserViewCell
        guard let image = cell.imageView.image else {
            return
        }
        
        // 2.将image对象保存相册
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didFinishSavingWithError:contextInfo:)), nil)
    }

    
    @objc fileprivate func image(image : UIImage, didFinishSavingWithError error : NSError?, contextInfo : AnyObject) {
       
        if error != nil {
            
            SVProgressHUD.showInfo(withStatus: "保存失败")
        } else {
           
            SVProgressHUD.showSuccess(withStatus: "保存成功")
        }
    }
}


// MARK:- 实现collectionView的数据源方法
extension PhotoBrowserController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 1.创建cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoBrowserCell, for: indexPath) as! PhotoBrowserViewCell
        
        // 2.给cell设置数据
        cell.picURL = picURLs[indexPath.item]
        cell.delegate = self
        
        return cell
    }

    
}

// MARK:- PhotoBrowserViewCell的代理方法
extension PhotoBrowserController : PhotoBrowserViewCellDelegate {
    func imageViewClick() {
        closeBtnClick()
    }
}


// MARK:- 遵守AnimatorDismissDelegate
extension PhotoBrowserController : AnimatorDismissDelegate {
    
    func indexPathForDimissView() -> NSIndexPath {
        // 1.获取当前正在显示的indexPath
        let cell = collectionView.visibleCells.first!
        
        return collectionView.indexPath(for: cell)! as NSIndexPath
    }
    
    func imageViewForDimissView() -> UIImageView {
        // 1.创建UIImageView对象
        let imageView = UIImageView()
        
        // 2.设置imageView的frame
        let cell = collectionView.visibleCells.first as! PhotoBrowserViewCell
        imageView.frame = cell.imageView.frame
        imageView.image = cell.imageView.image
        
        // 3.设置imageView的属性
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }
}

// MARK:- 自定义布局
class PhotoBrowserCollectionViewLayout : UICollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        
        // 1.设置itemSize
        itemSize = collectionView!.frame.size
        minimumInteritemSpacing = 0
        minimumLineSpacing = 0
        scrollDirection = .horizontal
        
        // 2.设置collectionView的属性
        collectionView?.isPagingEnabled = true
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
    }
}

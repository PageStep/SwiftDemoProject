//
//  HomeStatusViewCell.swift
//  WB
//
//  Created by Page on 2017/12/21.
//  Copyright © 2017年 Page. All rights reserved.
//

import UIKit
import SDWebImage

private let edgeMargin : CGFloat = 15
private let itemMargin : CGFloat = 10

class HomeStatusViewCell: UITableViewCell {
    
    // MARK:- 控件属性
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var verifiedView: UIImageView!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var vipView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var contentLabel: HYLabel!
    
    @IBOutlet weak var retweetedContentLabel: HYLabel!
    @IBOutlet weak var picView: PicCollectionView!
    @IBOutlet weak var retweetedBgView: UIView!
    @IBOutlet weak var bottomToolView: UIView!
    
    // MARK:- 约束的属性
    @IBOutlet weak var contentLabelWCons: NSLayoutConstraint!

    // 根据图片数量或内容 改变 宽高
    @IBOutlet weak var picViewWCons: NSLayoutConstraint!
    @IBOutlet weak var picViewHCons: NSLayoutConstraint!
    
    // 根据是否有转发微博 改变 转发微博的控件的约束
    @IBOutlet weak var picViewBottomCons: NSLayoutConstraint!
    @IBOutlet weak var retweetedContentLabelTopCons: NSLayoutConstraint!
    
    // MARK:- 自定义属性
    var viewModel : StatusViewModel? {
        didSet {
            // 1.nil值校验
            guard let viewModel = viewModel else {
                return
            }
            
            // 2.设置头像
            iconView.sd_setImage(with: viewModel.profileURL! as URL, placeholderImage: UIImage(named: "avatar_default_small"))
            
            // 3.设置认证的图标
            verifiedView.image = viewModel.verifiedImage
            
            // 4.昵称
            screenNameLabel.text = viewModel.status?.user?.screen_name
            
            // 5.会员图标
            vipView.image = viewModel.vipImage
            
            // 6.设置时间的Label
            timeLabel.text = viewModel.createAtText
            
            // 7.设置微博正文
            contentLabel.text = viewModel.status?.text
            
            // 8.设置来源
            if let sourceText = viewModel.sourceText {
                sourceLabel.text = "来自 " + sourceText
            } else {
                sourceLabel.text = nil
            }
            
            // 9.设置昵称的文字颜色
            screenNameLabel.textColor = viewModel.vipImage == nil ? UIColor.black : UIColor.orange
            
            // 10.计算picView的宽度和高度的约束
            let picViewSize = calculatePicViewSize(count: viewModel.picURLs.count)
            picViewWCons.constant = picViewSize.width
            picViewHCons.constant = picViewSize.height
            
            // 11.将picURL数据传递给picView
            picView.picURLs = viewModel.picURLs
            
            // 12.设置转发微博的正文
            if viewModel.status?.retweeted_status != nil {
                // 1.设置转发微博的正文
                if let screenName = viewModel.status?.retweeted_status?.user?.screen_name, let retweetedText = viewModel.status?.retweeted_status?.text {
                    retweetedContentLabel.text = "@" + "\(screenName): " + retweetedText
                    
                    // 设置转发正文距离顶部的约束
                    retweetedContentLabelTopCons.constant = 15
                }
                
                // 2.设置背景显示
                retweetedBgView.isHidden = false
            } else {
                // 1.设置转发微博的正文
                retweetedContentLabel.text = nil
                
                // 2.设置背景显示
                retweetedBgView.isHidden = true
                
                // 3.设置转发正文距离顶部的约束
                retweetedContentLabelTopCons.constant = 0
            }
            
            // 13.计算cell的高度
            if viewModel.cellHeight == 0 {
                // 12.1.强制布局
                layoutIfNeeded()
                
                // 12.2.获取底部工具栏的最大Y值
                viewModel.cellHeight = bottomToolView.frame.maxY
            }
        }
    }
    
    
    // MARK:- 系统回调函数
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 设置微博正文的宽度约束 (在xib中设置可能导致cell根据子控件自动计算高度不准确)
        contentLabelWCons.constant = UIScreen.main.bounds.width - 2 * edgeMargin
        
        // 设置HYLabel的内容
        contentLabel.matchTextColor = UIColor.purple
        retweetedContentLabel.matchTextColor = UIColor.purple
        
        // 监听HYlabel内容的点击
        // 监听@谁谁谁的点击
        contentLabel.userTapHandler = { (label, user, range) in
            print(user)
            print(range)
        }
        
        // 监听链接的点击
        contentLabel.linkTapHandler = { (label, link, range) in
            print(link)
            print(range)
        }
        
        // 监听话题的点击
        contentLabel.topicTapHandler = { (label, topic, range) in
            print(topic)
            print(range)
        }

    }
}

// MARK:- 计算方法
extension HomeStatusViewCell {
    fileprivate func calculatePicViewSize(count : Int) -> CGSize {
        // 1.没有配图
        if count == 0 {
            picViewBottomCons.constant = 0
            return CGSize.zero
        }
        
        // 有配图需要改约束有值
        picViewBottomCons.constant = 10
        
        // 2.取出picView对应的layout
        let layout = picView.collectionViewLayout as! UICollectionViewFlowLayout
        
        // 3.单张配图
        if count == 1 {
            // 1.取出图片
            let urlString = viewModel?.picURLs.last?.absoluteString

            let image = SDWebImageManager.shared().imageCache.imageFromDiskCache(forKey: urlString)
            
            // 2.设置一张图片时layout的itemSize
            let itemSize = CGSize(width: image!.size.width * 2, height: image!.size.height * 2)
            
            layout.itemSize = itemSize
            
            return itemSize
        }
        
        // 4.计算出来imageViewWH
        let imageViewWH = (UIScreen.main.bounds.width - 2 * edgeMargin - 2 * itemMargin) / 3
        
        // 5.设置其他张图片时layout的itemSize
        layout.itemSize = CGSize(width: imageViewWH, height: imageViewWH)
        
        // 6.四张配图
        if count == 4 {
            let picViewWH = imageViewWH * 2 + itemMargin + 1
           
            return CGSize(width: picViewWH, height: picViewWH)
        }
        
        // 7.其他张配图
        // 7.1.计算行数
        let rows = CGFloat((count - 1) / 3 + 1)
        
        // 7.2.计算picView的高度
        let picViewH = rows * imageViewWH + (rows - 1) * itemMargin
        
        // 7.3.计算picView的宽度
        let picViewW = UIScreen.main.bounds.width - 2 * edgeMargin
        
        return CGSize(width: picViewW, height: picViewH)
    }
}


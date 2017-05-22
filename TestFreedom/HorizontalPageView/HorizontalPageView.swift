//
//  HorizontalPageView.swift
//  TestFreedom
//
//  Created by zzzsw on 2017/5/19.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import Foundation
import UIKit

let pageCellIdentifier = "pageCellIdentifier"




var HorizontalPageViewScrollContext = "HorizontalPageViewScrollContext"
var HorizontalPageViewInsetContext = "HorizontalPageViewInsetContext"
var HorizontalPageViewPanContext = "HorizontalPageViewPanContext"
var pageButtonTag = 1000;
var pageScrollViewTag = 2000;




@objc protocol HorizontalPageViewDelegate {

    /*下方左右滑UIScrollView设置*/
    func numberOfSectionsInPageView(pageView:HorizontalPageView)->Int;


    func pageView(pageView:HorizontalPageView,viewAtIdx:Int) -> UIScrollView;

    //headerView设置
    func headerHeightInPageView(pageView:HorizontalPageView)->CGFloat;

    func headerViewInPageView(pageView:HorizontalPageView)->UIView;


    //segmentButtons
    func segmentHeightInPageView(pageView:HorizontalPageView) -> CGFloat;

    func segmentButtonsPageView(pageView:HorizontalPageView)->[UIButton];


    /*非当前页面点击segment*/
    @objc optional func pageView(pageView:HorizontalPageView,segmentDidSelected item:UIButton,atIndex seledIndex:Int)
    /*当前页面点击Segment*/
    @objc optional func pageView(pageView:HorizontalPageView,segmentDidSelectedSameItem item:UIButton,atIdx seledIdx:Int)
    /*视图切换完成时调用 从哪里切换到哪里*/
    @objc optional func pageView(pageView:HorizontalPageView,didSwitchIdx aIdx:Int,toIdx:Int)

    @objc optional func pageViewScrollTop(pageView:HorizontalPageView,offset:CGFloat)




}




var kHorizontalScrollViewRefreshStartNotification = "kHorizontalScrollViewRefreshStartNotification"
var kHorizontalScrollViewRefreshEndNotification = "kHorizontalScrollViewRefreshEndNotification"

class HorizontalPageView: UIView,UIScrollViewDelegate{


    /*segment距离顶部的距离*/
    public var segmentTopSpace: CGFloat! = 0
    /* 是否使用模拟手势 默认为NO*/
    var isGestureSimulate: Bool! = false

    /**/
    
    var segmentButtons : NSArray! = NSArray()



    var currentSelectedBtn : Int! = 0
    /*代理*/
    var delegate : HorizontalPageViewDelegate! = nil

    var horizontalCollectionView : UICollectionView! = nil

    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    

    convenience init(frame: CGRect,delegate:HorizontalPageViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate;

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        self.horizontalCollectionView = UICollectionView.init(frame: frame, collectionViewLayout: layout)
        //应当为每一个ScrollVIew 注册一个唯一的Cell
        let section = self.delegate.numberOfSectionsInPageView(pageView: self)
        
        
        
        self.registCell(form: 0, to: section)

        self.horizontalCollectionView.backgroundColor = UIColor.clear
        self.horizontalCollectionView.dataSource = self
        self.horizontalCollectionView.delegate = self
        
        self.horizontalCollectionView.isPagingEnabled = true;
        self.horizontalCollectionView.showsHorizontalScrollIndicator = false
        self.horizontalCollectionView.scrollsToTop = false


        //iOS10  上将该属性设置为false 就会欲取cell了
        self.horizontalCollectionView.isPrefetchingEnabled = false


        let tempLayout : UICollectionViewFlowLayout = self.horizontalCollectionView.collectionViewLayout as! UICollectionViewFlowLayout;
        tempLayout.itemSize = self.horizontalCollectionView.frame.size;
        self.addSubview(self.horizontalCollectionView)
        self.configureHeaderView()
        self.configureSegmentView()
        NotificationCenter.default.addObserver(self, selector: #selector(releaseCache), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStart(notification:)), name: NSNotification.Name(rawValue: kHorizontalScrollViewRefreshStartNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshEnd(notification:)), name: NSNotification.Name.init(kHorizontalScrollViewRefreshEndNotification), object: nil)

    }
    
    func refreshEnd(notification:Notification){
        let obj : UIScrollView! = notification.object as! UIScrollView
        for scrollView in self.contentViewArray {
            if obj == (scrollView as! UIScrollView) {
                (scrollView as! UIScrollView).setH_startRefresh(h_startRefresh: false)
                (scrollView as! UIScrollView).setH_isRefresh(h_isRefresh: false)
                (scrollView as! UIScrollView).setDragging(dragging: false)
                break;
            }
        }
    }
    
    
    
    func refreshStart(notification:Notification){
        let obj : UIScrollView! = notification.object as! UIScrollView
        for scrollView in self.contentViewArray {
            if obj == (scrollView as! UIScrollView) {
                (scrollView as! UIScrollView).setH_startRefresh(h_startRefresh: true)
                (scrollView as! UIScrollView).setH_isRefresh(h_isRefresh: true)
                break;
            }
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }




    /*注册cell*/
    func registCell(form:Int,to:Int){
        for idx in form..<to {
            self.horizontalCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "\(pageCellIdentifier)_\(idx)")
        }
    }


    var headerView : UIView! = nil
    var headerOriginYConstraint : NSLayoutConstraint! = nil
    var headerSizeHeightConstraint : NSLayoutConstraint! = nil
    var headerViewHeight : CGFloat! = 0

    func configureHeaderView(){
        
        if self.headerView != nil {
            self.headerView.removeFromSuperview()
        }

        if self.headerView != nil {
            self.headerView.translatesAutoresizingMaskIntoConstraints = false;
            self.addSubview(self.headerView);
            self.addConstraint(NSLayoutConstraint.init(item: self.headerView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))

            self.addConstraint(NSLayoutConstraint.init(item: self.headerView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))

            self.headerOriginYConstraint = NSLayoutConstraint.init(item: self.headerView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)

            self.addConstraint(self.headerOriginYConstraint)

            self.headerSizeHeightConstraint = NSLayoutConstraint.init(item: self.headerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.init(rawValue: 0)!, multiplier: 1, constant: self.headerViewHeight)

            self.headerView.addConstraint(self.headerSizeHeightConstraint)
            self.addGestureRecognizerAtHeaderView()
        }
    }


    func addGestureRecognizerAtHeaderView(){

        if self.isGestureSimulate == false {
            return;
        }
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(HorizontalPageView.pan(pan:)))
        pan.delegate = self;
        self.headerView.addGestureRecognizer(pan)

    }
    
    
    func scrollToIndex(pageIdx:Int){
        self.segmentBtnEvent(segmentBtn: self.segmentButtons[pageIdx] as! UIButton)
    }
    
    func reload(){

        self.headerView = self.delegate.headerViewInPageView(pageView: self)
        self.headerViewHeight = self.delegate.headerHeightInPageView(pageView: self)

        self.segmentButtons = self.delegate.segmentButtonsPageView(pageView: self) as NSArray



        self.segmentBarHeight = self.delegate.segmentHeightInPageView(pageView: self)


        self.configureHeaderView()
        self.configureSegmentView()
        //防止该section 是计算得出会改变导致后面崩溃
        let section = self.delegate.numberOfSectionsInPageView(pageView: self)
        self.registCell(form: 0, to: section)
        self.horizontalCollectionView.reloadData()
    }
    
    
    
    
    var pullOffset : CGFloat! = 0
    func getThePullOffset()->CGFloat{
        if self.pullOffset == 0 {
            pullOffset = self.delegate.headerHeightInPageView(pageView: self) + self.delegate.segmentHeightInPageView(pageView: self)
        }
        return self.pullOffset;
    }
    


    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer is UIPanGestureRecognizer {
            let pan : UIPanGestureRecognizer = gestureRecognizer as! UIPanGestureRecognizer
            let point = pan.translation(in: self.headerView)
            if fabs(point.y) <= fabs(point.x) {
                return false
            }

        }
        return true;
    }


    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true;
    }


    var currentScrollView : UIScrollView! = nil

    var isDragging : Bool! = false


    func pan(pan:UIPanGestureRecognizer){

        //如果处于刷新中 作用在headerView上的手势不响应
        if self.currentScrollView.h_isRefresh(){
            return;
        }

        //手势模拟 兼容整体下拉刷新
        self.isDragging = !(pan.state == .ended || pan.state == .failed)
        self.currentScrollView.setDragging(dragging: self.isDragging)

        //偏移计算
        var point = pan.translation(in: self.headerView)
        var contentOffset = self.currentScrollView.contentOffset;
        var border = -self.headerViewHeight - self.delegate.segmentHeightInPageView(pageView: self)
        var offsety = contentOffset.y - point.y * (1/contentOffset.y*border*0.8)
        self.currentScrollView.contentOffset = CGPoint.init(x: contentOffset.x, y: offsety)


        if pan.state == .ended || pan.state == .failed {

            if contentOffset.y <= border {
                //如果处于刷新
                if self.currentScrollView.h_isRefresh() {
                    return;
                }

                //模拟弹回效果
                UIView.animate(withDuration: 0.35, animations: { 

                    self.currentScrollView.contentOffset = CGPoint.init(x: contentOffset.x, y: border)
                    self.layoutIfNeeded()

                }, completion: { (isFinish) in

                })



            }else{
                //模拟减速滚动效果
                var velocity = pan.velocity(in: self.headerView).y
                self.deceleratingAnimator(velocity: velocity)
            }
        }
        pan.setTranslation(.zero, in: self.headerView)
    }


    //var animator : UIDynamicAnimator! = nil
    lazy var animator : UIDynamicAnimator = {
        let animatorNow = UIDynamicAnimator()
        return animatorNow;
    }()
    
    
    var inertialBehavior : UIDynamicItemBehavior! = nil

    func deceleratingAnimator(velocity:CGFloat){

        if self.inertialBehavior != nil {
            self.animator.removeBehavior(self.inertialBehavior)
        }

        let item = DynamicItem()
        item.center = CGPoint.zero
        //velocity是在手势结束的时候获取的竖直方向的手势速度
        let inertialBehavior = UIDynamicItemBehavior.init(items: [item as! UIDynamicItem])
        
        inertialBehavior.addLinearVelocity(CGPoint.init(x: 0, y: velocity*0.025), for: item as! UIDynamicItem)
        //通过尝试2.0比较像系统的效果
        inertialBehavior.resistance = 2;
        var maxOffset = self.currentScrollView.contentSize.height - self.currentScrollView.bounds.size.height
        inertialBehavior.action = { () in

            var contentOffset = self.currentScrollView.contentOffset;
            var speed = self.inertialBehavior.linearVelocity(for: item as! UIDynamicItem).y;

            var offset = contentOffset.y - speed;
            if speed >= -0.2 {

                self.animator.removeBehavior(self.inertialBehavior)
                self.inertialBehavior = nil


            }else if offset >= maxOffset{

                self.animator.removeBehavior(self.inertialBehavior)
                self.inertialBehavior = nil
                offset = maxOffset;
                //模拟减速滚动到scrollView到最底部时 先拉一点再弹回的效果
                UIView.animate(withDuration: 0.2, animations: { 

                    self.currentScrollView.contentOffset = CGPoint.init(x: contentOffset.x, y: offset - speed);
                    self.layoutIfNeeded()

                }, completion: { (isFinish) in
                    UIView.animate(withDuration: 0.25, animations: { 

                        self.currentScrollView.contentOffset = CGPoint.init(x: contentOffset.x, y: offset)
                        self.layoutIfNeeded()
                    })
                })
            }else{
                self.currentScrollView.contentOffset = CGPoint.init(x: contentOffset.x, y: offset)
            }
        }
        self.inertialBehavior = inertialBehavior
        self.animator.addBehavior(inertialBehavior);
    }

    
    
    var currentPage: Int! = 0
    //视图切换时执行代码
    func didSwitchIndex(aIndex:Int,toIdx:Int){
        
        self.currentPage = toIdx;
        self.currentScrollView = self.scrollView(AtIndex: toIdx)
        if aIndex == toIdx {
            return;
        }

        let oldScrollView = self.scrollView(AtIndex: aIndex)

        if oldScrollView.h_isRefresh() {
            oldScrollView.setH_startRefresh(h_startRefresh: false)
            oldScrollView.setH_isRefresh(h_isRefresh: false)
            oldScrollView.setDragging(dragging: false)
        }

        self.setSelectedBtnPage(btnPage: toIdx);
        self.removeCacheScrollView()

        self.delegate.pageView!(pageView: self, didSwitchIdx: aIndex, toIdx: toIdx)

    }
    
    
    
    func scrollView(AtIndex idx:Int)->UIScrollView{
        
        var scrollView : UIScrollView! = nil

        for (_,obj) in self.contentViewArray.enumerated() {

            let totalTag = pageScrollViewTag + idx;
            if (obj as! UIScrollView).tag == totalTag {
                scrollView = obj as! UIScrollView
                break;
            }
        }

        
        if scrollView == nil {
            scrollView = self.delegate.pageView(pageView: self, viewAtIdx: idx)
            self.configureContentView(scrollView: scrollView)
            scrollView.tag = pageScrollViewTag + idx;
            self.contentViewArray.add(scrollView)
        }

        return scrollView;
    }
    
    
    
    
    var _segmentView : UIView! = nil
    var segmentView : UIView! {
        set{
            if _segmentView == nil {
                _segmentView = UIView();
                _segmentView.isUserInteractionEnabled = true;
            }
        }
        get{
            return _segmentView
        }
    }
    
    
    var _segmentButtonSize : CGSize! = CGSize.zero
    var segmentButtonSize : CGSize! {
        set{
            _segmentButtonSize = newValue
            self.configureSegmentButtonLayout()
        }
        get{
            return _segmentButtonSize
        }
    
    }
    
    
    
    
    func configureSegmentView(){
        
        if self.segmentView != nil {
            self.segmentView.removeFromSuperview()
        }
        self.segmentView = nil;
        if self.segmentView != nil{

            self.configureSegmentButtonLayout()

            self.segmentView.translatesAutoresizingMaskIntoConstraints = false;

            self.addSubview(self.segmentView);
            //self.isUserInteractionEnabled = true;

            self.addConstraint(NSLayoutConstraint.init(item: self.segmentView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0))
            
            self.addConstraint(NSLayoutConstraint.init(item: self.segmentView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))

            self.addConstraint(NSLayoutConstraint.init(item: self.segmentView, attribute: .top, relatedBy: .equal, toItem: (self.headerView != nil ? self.headerView: self), attribute: (self.headerView != nil ? .bottom : .top), multiplier: 1, constant: 0))

            self.segmentView.addConstraint(NSLayoutConstraint.init(item: self.segmentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.init(rawValue: 0)!, multiplier: 1, constant: segmentBarHeight))
        }
    }
    
    
    
    
    func configureSegmentButtonLayout(){
        
        
        if  self.segmentButtons.count > 0 {
            
            var btnTop : CGFloat! = 0
            var btnLeft : CGFloat! = 0
            var btnWidth : CGFloat! = 0
            var btnHeight : CGFloat! = 0
            
            if self.segmentButtonSize.equalTo(.zero) {
                btnWidth = UIScreen.main.bounds.size.width / CGFloat(self.segmentButtons.count)
                btnHeight = self.segmentBarHeight
            }else{
                btnWidth = self.segmentButtonSize.width;
                btnHeight = self.segmentButtonSize.height;
                btnTop = (self.segmentBarHeight - btnHeight)/2;
                btnLeft = (UIScreen.main.bounds.size.width - CGFloat(self.segmentButtons.count)*btnWidth)/CGFloat(segmentButtons.count + 1);
            }
            segmentView.removeConstraints(self.segmentButtonConstraintArray as! [NSLayoutConstraint])
            
            for idx in 0..<self.segmentButtons.count {
                
                let segmentBtn : UIButton = self.segmentButtons[idx] as! UIButton;
                segmentBtn.removeConstraints(self.segmentButtonConstraintArray as! [NSLayoutConstraint])
                
                segmentBtn.tag = pageButtonTag+idx;
                segmentBtn.addTarget(self, action: #selector(HorizontalPageView.segmentBtnEvent(segmentBtn:)), for: .touchUpInside)
                segmentView.addSubview(segmentBtn)
                
                if idx == 0 {
                    segmentBtn.isSelected = true;
                    self.currentPage = 0;
                }
                segmentBtn.translatesAutoresizingMaskIntoConstraints = false;
                
                let topConstraint = NSLayoutConstraint.init(item: segmentBtn, attribute: .top, relatedBy: .equal, toItem: segmentView, attribute: .top, multiplier: 1, constant: btnTop)
                let leftConstraint = NSLayoutConstraint.init(item: segmentBtn, attribute: .left, relatedBy: .equal, toItem: segmentView, attribute: .left, multiplier: 1, constant: CGFloat(idx)*btnWidth+btnLeft*CGFloat(idx)+btnLeft)
                let widthConstraint = NSLayoutConstraint.init(item: segmentBtn, attribute: .width, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.init(rawValue: 0)!, multiplier: 1, constant: btnWidth)
                let heightConstraint = NSLayoutConstraint.init(item: segmentBtn, attribute: .height, relatedBy: .equal, toItem: nil, attribute: NSLayoutAttribute.init(rawValue: 0)!, multiplier: 1, constant: btnHeight)
                
                segmentButtonConstraintArray.add(topConstraint)
                segmentButtonConstraintArray.add(leftConstraint)
                segmentButtonConstraintArray.add(widthConstraint)
                segmentButtonConstraintArray.add(heightConstraint)
                
                segmentView.addConstraint(topConstraint)
                segmentView.addConstraint(leftConstraint)
                segmentBtn.addConstraint(widthConstraint)
                segmentBtn.addConstraint(heightConstraint)
                
                
                if segmentBtn.currentImage != nil {
                    let imageWidth = segmentBtn.imageView?.bounds.size.width
                    let labelWidth = segmentBtn.titleLabel?.bounds.size.width
                    segmentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, labelWidth!+5, 0, -labelWidth!)
                    segmentBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth!, 0, imageWidth!)
                }
            }
            
        }
    
    }
    
    
    
    func segmentBtnEvent(segmentBtn:UIButton){
        
        let clickIndex = segmentBtn.tag - pageButtonTag
        if clickIndex >= self.delegate.numberOfSectionsInPageView(pageView: self) {
            self.delegate.pageView!(pageView: self, segmentDidSelected: segmentBtn, atIndex: clickIndex)
            return;
        }
        //当前页面被点击
        if segmentBtn.isSelected {
            self.delegate.pageView!(pageView: self, segmentDidSelectedSameItem: segmentBtn, atIdx: clickIndex)
            return;
        }
        //非当前页被点击
        self.horizontalCollectionView.scrollToItem(at: IndexPath.init(item: clickIndex, section: 0), at: .centeredHorizontally, animated: true)
        
        
        if self.currentScrollView.contentOffset.y < -(self.headerViewHeight+self.segmentBarHeight) {
            self.currentScrollView.setContentOffset(CGPoint.init(x: self.currentScrollView.contentOffset.x, y: -(self.headerViewHeight+self.segmentBarHeight)), animated: true)
        }else{
            self.currentScrollView.setContentOffset(self.currentScrollView.contentOffset, animated: false)
        }
        

        self.delegate.pageView!(pageView: self, segmentDidSelected: segmentBtn, atIndex: clickIndex)
        
        //试图切换时执行的代码
        self.didSwitchIndex(aIndex: self.currentPage, toIdx: clickIndex)
    }
    
    
    
    var isSwitch:Bool! = false
    
    func adjustOffsetContentView(scrollView:UIScrollView){
        
        self.isSwitch = true
        let headerViewDisplayHeight = self.headerViewHeight + self.headerView.frame.origin.y;
        scrollView.layoutIfNeeded()
        
        if headerViewDisplayHeight != self.segmentTopSpace {
            //还原位置
            scrollView.setContentOffset(CGPoint.init(x: 0, y: -headerViewDisplayHeight - self.segmentBarHeight), animated: false)
        }else if(scrollView.contentOffset.y < -self.segmentBarHeight){
            scrollView.setContentOffset(CGPoint.init(x: 0, y: -headerViewDisplayHeight-self.segmentBarHeight), animated: false)
        }else{
            scrollView.setContentOffset(CGPoint.init(x: 0, y: scrollView.contentOffset.y-headerViewDisplayHeight + self.segmentTopSpace), animated: false)
        }
        
        
        if (scrollView.delegate?.responds(to: #selector(scrollView.delegate?.scrollViewDidEndDragging(_:willDecelerate:))))! == true {
            scrollView.delegate?.scrollViewDidEndDragging!(scrollView, willDecelerate: false)
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.isSwitch = false;
        }
    
    }

    
    
    
    
    
    
    var segmentBarHeight:CGFloat! = 40
    func configureContentView(scrollView:UIScrollView!){
        
        scrollView.contentInset = UIEdgeInsetsMake(self.headerViewHeight + self.segmentBarHeight, 0, scrollView.contentInset.bottom, 0)
        scrollView.alwaysBounceVertical = true;
        scrollView.showsVerticalScrollIndicator = false;
        scrollView.contentOffset = CGPoint.init(x: 0, y: -self.headerViewHeight-self.segmentBarHeight)
        scrollView.panGestureRecognizer.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIGestureRecognizer.state)), options: [.new,.old], context: &HorizontalPageViewPanContext)
        
        scrollView.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)), options: [.new,.old], context: &HorizontalPageViewScrollContext)
        
        scrollView.addObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentInset)), options: [.new,.old], context: &HorizontalPageViewInsetContext)
        
        if scrollView == nil {
            self.currentScrollView = scrollView;
        }
        
    }
    
    
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        self.isScroll = true;
        let offsetPage = scrollView.contentOffset.x / UIScreen.main.bounds.size.width
        let py = fabs(CGFloat(Int(offsetPage)) - offsetPage)
        if py <= 0.3 || py >= 0.7 {
            return;
        }
        let currentPage = self.currentSelectedBtn;
        if offsetPage - CGFloat(currentPage!) > 0 {
            if py > 0.55 {
                self.setSelectedBtnPage(btnPage: currentPage!+1)
            }
        }else{
            if py < 0.45 {

                if currentPage == 0 {

                }else{
                    self.setSelectedBtnPage(btnPage: currentPage! - 1)
                }


            }
        }
    }
    
    
    var isScroll : Bool! = false
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if !self.isDragging {//是否左右滚动 防止上下滚动的触发
            return;
        }
        self.isScroll = false;
        let currentPage = scrollView.contentOffset.x/UIScreen.main.bounds.size.width
        
        self.didSwitchIndex(aIndex: self.currentPage, toIdx: Int(currentPage))
    }

    
    func setSelectedBtnPage(btnPage:Int){
        for b in self.segmentButtons {
            if (b as! UIButton).tag - pageButtonTag == btnPage {
                (b as! UIButton).isSelected = true;
            }else{
                (b as! UIButton).isSelected = false;
            }
        }
        self.currentSelectedBtn = btnPage;
    }
    
    
    func removeCacheScrollView(){
        if self.contentViewArray.count <= Int(self.maxCacheCout) {
            return;
        }
        self.releaseCache()
    }
    
    
    func releaseCache(){
        let currentCnt = self.currentScrollView.tag
        for obj in self.contentViewArray {
            if labs((obj as! UIScrollView).tag - currentCnt) > 1 {
                self.removeScrollView(scrollView: (obj as! UIScrollView))
            }
        }
    }
    
    
    func removeScrollView(scrollView:UIScrollView){
        self.removeObserverFor(scrollView: scrollView)
        self.contentViewArray.remove(scrollView)
        let vc = self.viewControllerFor(view: scrollView)
        vc?.view.tag = 0;
        scrollView.superview?.tag = 0;
        vc?.view.superview?.tag = 0;
        scrollView.removeFromSuperview()
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
    }
    
    
    
    func viewControllerFor(view:UIView)->UIViewController!{
        
        
        
        var next : UIView! = view;
        while next != nil {
            let nextResponder = next.next;
            
            if nextResponder is UIViewController  || nextResponder is ArtTabViewVC || nextResponder is ArtChangeNavVC{
                return nextResponder as! UIViewController;
            }
            
            next = next.superview
            
        }
        return nil;
    }
    
    
    
    func removeObserverFor(scrollView:UIScrollView){
        scrollView.panGestureRecognizer.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIGestureRecognizer.state)), context: &HorizontalPageViewPanContext)
        
        scrollView.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentOffset)), context: &HorizontalPageViewScrollContext)
        
        scrollView.removeObserver(self, forKeyPath: NSStringFromSelector(#selector(getter: UIScrollView.contentInset)), context: &HorizontalPageViewInsetContext)
    }
    
    
    
    deinit {
        for obj in self.contentViewArray {
            self.removeObserverFor(scrollView: obj as! UIScrollView)
        }
        NotificationCenter.default.removeObserver(self)
    }

    
    var segmentButtonConstraintArray : NSMutableArray = {
        return NSMutableArray()
    }()
    
    var contentViewArray : NSMutableArray = {
        return NSMutableArray()
    }()
    
    var _maxCacheCout : CGFloat! = nil
    var maxCacheCout : CGFloat{
        set{
            if _maxCacheCout == 0 {
                _maxCacheCout = 3;
            }else{
                _maxCacheCout = newValue;
            }
        }
        get{
            return _maxCacheCout;
        }
    }
    
    
    var currentTouchView : UIView! = nil
    var currentTouchButton : UIButton! = nil
    var currentTouchViewPoint : CGPoint! = nil
    var allowPullToRefresh : Bool! = false
    var contentOffset : CGPoint! = nil
    

}






extension HorizontalPageView: UICollectionViewDelegate,UICollectionViewDataSource{

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.delegate.numberOfSectionsInPageView(pageView: self)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        self.isSwitch = true;
        let key = "\(pageCellIdentifier)_\(indexPath.item)";
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: key, for: indexPath)
        let v : UIScrollView = self.scrollView(AtIndex: indexPath.item)

        //只有在cell未添加scrollView时才添加  让以下代码只在需要时执行
        if cell.contentView.tag != v.tag {

            cell.backgroundColor = UIColor.clear
            for v in cell.contentView.subviews {
                v.removeFromSuperview()
            }
            cell.tag = v.tag;
            let vc = self.viewControllerFor(view: v)
            //如果为空表示 v还没有响应者  在部分机型上出现该问题 情况不明先这么看看
            
            cell.contentView.addSubview((vc?.view)!)
            cell.tag = v.tag;
            vc?.view.translatesAutoresizingMaskIntoConstraints = false;

            cell.contentView.addConstraint(NSLayoutConstraint.init(item: vc!.view, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1, constant: 0))
            cell.contentView.addConstraint(NSLayoutConstraint.init(item: vc!.view, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1, constant: 0))
            cell.contentView.addConstraint(NSLayoutConstraint.init(item: vc!.view, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1, constant: 0))
            cell.contentView.addConstraint(NSLayoutConstraint.init(item: vc!.view, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1, constant: 0))
            
            cell.layoutIfNeeded()
            
        }
        self.currentScrollView = v;
        self.adjustOffsetContentView(scrollView: v)
        return cell;
    }




    
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        
        if context == &HorizontalPageViewPanContext {
            self.isDragging = true;
            self.horizontalCollectionView.isScrollEnabled = true
            let number : NSNumber = change![NSKeyValueChangeKey.newKey] as! NSNumber
            let state = UIGestureRecognizerState.init(rawValue: number.intValue)
            
            //failed说明是点击事件
            if state == UIGestureRecognizerState.failed {
                
                
                if self.currentTouchButton != nil {
         
                    self.segmentBtnEvent(segmentBtn: self.currentTouchButton)
                    
                }else if(self.currentTouchView != nil){
                    self.currentTouchView.viewWasTappedPoint(point: self.currentTouchViewPoint)
                
                }
                self.currentTouchView = nil
                self.currentTouchButton = nil
                
            }else if(state == .cancelled || state == .ended){
                self.isDragging = false;
            }
            
        }else if (context == &HorizontalPageViewScrollContext){
        
            self.currentTouchView = nil
            self.currentTouchButton = nil
            if self.isSwitch {
                return;
            }
            //触发如果不是当前ScrollView不予响应
            if (object as! UIScrollView) != self.currentScrollView {
                return;
            }
            
            
            let oldOffsetY = (change![NSKeyValueChangeKey.oldKey] as!NSValue).cgPointValue.y;
            let newOffsetY = (change![NSKeyValueChangeKey.newKey] as! NSValue).cgPointValue.y;
            let deltaY = newOffsetY - oldOffsetY;
            let headerViewHeight : CGFloat! = self.headerViewHeight;
            let headerDisplayHeight = self.headerViewHeight + self.headerOriginYConstraint.constant
            
            var py : CGFloat! = 0
            
            if deltaY >= 0 {//向上滚动
                
                if headerDisplayHeight - deltaY <= self.segmentTopSpace {
                    py = -headerViewHeight+self.segmentTopSpace
                }else{
                    py = self.headerOriginYConstraint.constant - deltaY;
                }
                
                if headerDisplayHeight <= self.segmentTopSpace {
                    py = -headerViewHeight+self.segmentTopSpace;
                }
                
                
                if self.allowPullToRefresh == false {
                    self.headerOriginYConstraint.constant = py;
                }else if (py < 0 && !self.currentScrollView.h_isRefresh() && !self.currentScrollView.h_isStartRefresh()){
                    
                    self.headerOriginYConstraint.constant = py;
                
                }else{
                    if self.currentScrollView.contentOffset.y >= -headerViewHeight - self.segmentBarHeight {
                        self.currentScrollView.setH_startRefresh(h_startRefresh: false)
                    }
                    self.headerOriginYConstraint.constant = 0
                }
                
            }else{
                //向下滚动
                if headerDisplayHeight+self.segmentBarHeight < -newOffsetY {
                    py = -self.headerViewHeight-self.segmentBarHeight-self.currentScrollView.contentOffset.y;
                    if self.allowPullToRefresh == false {
                        self.headerOriginYConstraint.constant = py;
                    }else if(py < 0){
                    
                        self.headerOriginYConstraint.constant = py;
                    
                    }else{
                        self.currentScrollView.setH_startRefresh(h_startRefresh: true)
                        self.headerOriginYConstraint.constant = 0;
                    }
                }
            }
            
            self.contentOffset = self.currentScrollView.contentOffset;
            self.delegate.pageViewScrollTop!(pageView: self, offset: self.contentOffset.y)
        
        
        }else if(context == &HorizontalPageViewInsetContext){
        
            if self.allowPullToRefresh || self.currentScrollView.contentOffset.y > -self.segmentBarHeight {
                return;
            }
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.headerOriginYConstraint.constant = -self.headerViewHeight-self.segmentBarHeight-self.currentScrollView.contentOffset.y;
                self.layoutIfNeeded()
                self.headerView.layoutIfNeeded()
                self.segmentView.layoutIfNeeded()
                
            })
        
        }
        
        
    }





    //MARK: HitTest

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {

        let view = super.hitTest(point, with: event)
        if (view is UIView) == false {
            return nil
        }
        if self.isGestureSimulate {
            return view;
        }
        //如果处于刷新中  作用在headerView上的手势不响应在currentScrollView上
        if self.currentScrollView.h_isRefresh() {
            return view;
        }

        if (view?.isDescendant(of: self.headerView))! || (view?.isDescendant(of: self.segmentView))! {

            self.horizontalCollectionView.isScrollEnabled = false
            self.currentTouchView = nil
            self.currentTouchButton = nil

            for obj in self.segmentButtons {
                if (obj as! UIButton) == view {
                    self.currentTouchButton = obj as! UIButton;
                }
            }

            if self.currentTouchButton == nil {
                self.currentTouchView = view;
                self.currentTouchViewPoint = self.convert(point, to: self.currentTouchView)
            }else{
                return view;
            }
            return self.currentScrollView;
        }
        return view;
    }





}







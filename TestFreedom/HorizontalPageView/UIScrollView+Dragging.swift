//
//  UIScrollView+Dragging.swift
//  TestFreedom
//
//  Created by zzzsw on 2017/5/18.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import Foundation
import UIKit




let swizzled_isDraggingKey = "swizzled_isDraggingKey"
let h_isRefreshKey = "h_isRefreshKey"
let h_startRefreshKey = "h_startRefreshKey"

extension UIScrollView: SelfAware{



    static func awake() {

        let clazz = UIScrollView.self

        let originalSelector : Selector = #selector(getter: UIScrollView.isDragging)

        let swizzledSelector : Selector = #selector(swizzled_isDragging)


        let originalMethod = class_getInstanceMethod(clazz, originalSelector)
        let swizzledMethod = class_getInstanceMethod(clazz, swizzledSelector)


        let success = class_addMethod(clazz, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

        if success {
            class_replaceMethod(clazz, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
        }else{
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

    }



    func setDragging(dragging:Bool){
        objc_setAssociatedObject(self,swizzled_isDraggingKey, dragging, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    func swizzled_isDragging()->Bool{
        
        var dragging : Bool! = false
        if objc_getAssociatedObject(self, swizzled_isDraggingKey) == nil {
            dragging = false;
        }else{
            dragging = objc_getAssociatedObject(self, swizzled_isDraggingKey) as! Bool
        }
        return dragging || self.swizzled_isDragging()
    }

    func setH_isRefresh(h_isRefresh:Bool){
        objc_setAssociatedObject(self, h_isRefreshKey, h_isRefresh, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    func h_isRefresh()->Bool{
        if objc_getAssociatedObject(self, h_isRefreshKey) == nil {
            return false
        }
        return objc_getAssociatedObject(self, h_isRefreshKey) as! Bool
    }



    func setH_startRefresh(h_startRefresh:Bool){
        objc_setAssociatedObject(self, h_startRefreshKey, h_startRefresh, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }

    func h_isStartRefresh()->Bool{
        return objc_getAssociatedObject(self, h_startRefreshKey) as! Bool
    }


}




/**/
protocol SelfAware: class {
    static func awake()
}

class NothingToSeeHere {

    static func harmlessFunction(){
        let typeCnt = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass>.allocate(capacity: typeCnt)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass?>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCnt))
        for idx in 0 ..< typeCnt {
            (types[idx] as? SelfAware.Type)?.awake()
        }
    }

}



extension UIApplication{

    private static let runOnce: Void = {
        NothingToSeeHere.harmlessFunction()
    }()

    override open var next: UIResponder? {
        UIApplication.runOnce
        return super.next
    }

}













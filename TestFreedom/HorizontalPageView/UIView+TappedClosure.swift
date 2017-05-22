//
//  UIView+TappedClosure.swift
//  TestFreedom
//
//  Created by zzzsw on 2017/5/18.
//  Copyright © 2017年 zzzsw. All rights reserved.
//

import Foundation
import UIKit




let kWhenTappedClosureKey = "kWhenTappedClosureKey"
let kWhenDoubleTappedClosureKey = "kWhenDoubleTappedClosureKey"
let kWhenTwoFingerTappedClosureKey = "kWhenTwoFingerTappedClosureKey"
let kWhenTouchedDownClosureKey = "kWhenTouchedDownClosureKey"
let kWhenTouchedUpClosureKey = "kWhenTouchedUpClosureKey"





typealias WhenTappedClosure = ()->Void


extension UIView:UIGestureRecognizerDelegate{

    func closure()->WhenTappedClosure!{
        return objc_getAssociatedObject(self, kWhenTappedClosureKey) as! WhenTappedClosure
    }

    func runClosureForKey(closureKey:String){
        let closure = objc_getAssociatedObject(self, closureKey) as? WhenTappedClosure
        if (closure != nil) {
            closure!()
        }
    }


    func setClosure(closure:WhenTappedClosure,forKey closureKey:String){
        self.isUserInteractionEnabled = true;
        objc_setAssociatedObject(self, closureKey, closure, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY_NONATOMIC)
    }

    //MARK:whenTapped
    func whenTapped(closure:WhenTappedClosure){
        let gesture = self.addTapGestureRecognizer(taps: 1, touches: 1, selector: #selector(UIView.viewWasTappedPoint(point:)));
        self.addRequiredToDoubleTapsRecognizer(recognizer: gesture)
        self.setClosure(closure: closure, forKey: kWhenTappedClosureKey)
    }

    func whenDoubleTapped(closure:WhenTappedClosure){
        let gesture = self.addTapGestureRecognizer(taps: 2, touches: 1, selector: #selector(viewWasDoubleTapped))
        self.addRequirementToSingleTapsRecognizer(recognizer: gesture)
        self.setClosure(closure: closure, forKey: kWhenDoubleTappedClosureKey)
    }


    func whenTwoFingerTapped(closure:WhenTappedClosure){
        let _ = self.addTapGestureRecognizer(taps: 1, touches: 2, selector: #selector(UIView.viewWasTwoFingerTapped))
        self.setClosure(closure: closure, forKey: kWhenTwoFingerTappedClosureKey)
    }

    func whenTouchedDown(closure:WhenTappedClosure){
        self.setClosure(closure: closure, forKey: kWhenTouchedDownClosureKey)
    }

    func whenTouchedUp(closure:WhenTappedClosure){
        self.setClosure(closure: closure, forKey: kWhenTouchedUpClosureKey)
    }



    //MARK: mark Callbacks
    func viewWasTapped(){
        self.runClosureForKey(closureKey: kWhenTappedClosureKey)
    }

    func viewWasDoubleTapped(){
        self.runClosureForKey(closureKey: kWhenDoubleTappedClosureKey)
    }

    func viewWasTwoFingerTapped(){
        self.runClosureForKey(closureKey: kWhenTwoFingerTappedClosureKey)
    }

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.runClosureForKey(closureKey: kWhenTouchedDownClosureKey)
    }


    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.runClosureForKey(closureKey: kWhenTouchedUpClosureKey)
    }





    //MARK: 
    func addTapGestureRecognizer(taps:Int,touches:Int,selector:Selector)->UITapGestureRecognizer{

        let tapGesture = UITapGestureRecognizer.init(target: self, action: selector)
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = taps;
        tapGesture.numberOfTouchesRequired = touches;
        self.addGestureRecognizer(tapGesture);

        return tapGesture;
    }



    func addRequirementToSingleTapsRecognizer(recognizer:UIGestureRecognizer){


        for gesture in self.gestureRecognizers! {

            if gesture is UITapGestureRecognizer {

                let tapGesture = gesture as! UITapGestureRecognizer
                if tapGesture.numberOfTouchesRequired == 1 && tapGesture.numberOfTapsRequired == 1 {
                    tapGesture.require(toFail: recognizer)
                }
            }
        }

    }


    func addRequiredToDoubleTapsRecognizer(recognizer:UIGestureRecognizer){
        for gesture in self.gestureRecognizers! {
            if gesture is UITapGestureRecognizer {
                let tapGesture = gesture as! UITapGestureRecognizer
                if tapGesture.numberOfTouchesRequired == 2 && tapGesture.numberOfTapsRequired == 1 {
                    recognizer.require(toFail: tapGesture)
                }
            }
        }

    }



    //MARK: 模拟响应者链条 又被触发的View 向它的兄弟控件 父控件 延伸查找响应


    func viewWasTappedPoint(point:CGPoint){
        let _ = self.clickOnThePoint(point: point);
    }


    func clickOnThePoint(point:CGPoint)->Bool{

        if self.superview is UIWindow {
            return false;
        }
        if self.closure() != nil {
            self.closure()();return true;
        }

        var click = false;

        for obj in (self.superview?.subviews)! {
            let objPoint = obj.convert(point, from: self)
            if obj.frame.contains(objPoint) {
                continue;
            }
            if self.closure() != nil {
                self.closure()();
                click = true;
                break;
            }
        }

        if !click {
            return (self.superview?.clickOnThePoint(point:point))!
        }
        return click;
    }






}

//
//  DUISwitch.swift
//  Derecho
//
//  Created by Niranjan Ravichandran on 8/2/17.
//  Copyright © 2017 Aviato. All rights reserved.
//

import UIKit

class DUISwicth: UISwitch, CAAnimationDelegate {
    
    struct AnimationConstants {
        static let scale = "transform.scale"
        static let up    = "scaleUp"
        static let down  = "scaleDown"
    }
    
    open var duration: Double = 0.35
    
    // Closuer call when animation start
    open var animationDidStartClosure = {(onAnimation: Bool) -> Void in }
    
    // Closuer call when animation finish
    open var animationDidStopClosure  = {(onAnimation: Bool, finished: Bool) -> Void in }
    
    fileprivate var shape: CAShapeLayer! = CAShapeLayer()
    fileprivate var radius: CGFloat      = 0.0
    fileprivate var oldState             = false
    
    fileprivate var defaultTintColor: UIColor?
    
    open var parentView: UIView? {
        didSet {
            defaultTintColor = parentView?.backgroundColor
        }
    }
    
    // MARK: - Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public required init(view: UIView?, color: UIColor?) {
        super.init(frame: CGRect.zero)
        onTintColor = color
        self.configureView(parentView: view)
        
    }
    
    //MARK: - Helper functions
    
    fileprivate func configureView(parentView: UIView?) {
        guard let _ = self.onTintColor else {
            fatalError("Set onTintColor")
        }
        
        self.parentView = parentView
        self.defaultTintColor = self.parentView?.backgroundColor
        
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1.0).cgColor
        layer.cornerRadius = frame.size.height / 2
        
        self.shape.fillColor     = onTintColor?.cgColor
        self.shape.masksToBounds = true
        
        parentView?.layer.insertSublayer(shape, at: 0)
        parentView?.layer.masksToBounds = true
        
        self.showShapeIfNeed()
        
        self.addTarget(self, action: #selector(DUISwicth.switchChanged), for: .valueChanged)
        
    }
    
    override open func layoutSubviews() {
        
        if let parentView = self.parentView {
            let x:CGFloat = max(center.x, parentView.frame.size.width - frame.midX)
            let y:CGFloat = max(center.y, parentView.frame.size.height - frame.midY)
            self.radius = sqrt(x*x + y*y)
        }
        
        let additional = parentView == superview ? CGPoint.zero : (superview?.frame.origin ?? CGPoint.zero)
        
        self.shape.frame = CGRect(x: center.x - radius + additional.x - 2, y: center.y - radius + additional.y, width: radius * 2, height: radius * 2)
        self.shape.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.shape.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)).cgPath
    }
    
    // MARK: - Public
    open override func setOn(_ on: Bool, animated: Bool) {
        let changed: Bool = on != self.isOn
        
        super.setOn(on, animated: animated)
        
        if changed {
            switchChangeWithAnimation(animated)
        }
    }
    
    // MARK: - Private
    fileprivate func showShapeIfNeed() {
        self.shape.transform = self.isOn ? CATransform3DMakeScale(1.0, 1.0, 1.0) : CATransform3DMakeScale(0.0001, 0.0001, 0.0001)
    }
    
    fileprivate func animateKeyPath(_ keyPath: String, fromValue from: CGFloat?, toValue to: CGFloat, timing timingFunction: String) -> CABasicAnimation {
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: keyPath)
        
        animation.fromValue             = from
        animation.toValue               = to
        animation.repeatCount           = 1
        animation.timingFunction        = CAMediaTimingFunction(name: timingFunction)
        animation.isRemovedOnCompletion = false
        animation.fillMode              = kCAFillModeForwards
        animation.duration              = duration
        animation.delegate              = self
        
        return animation
    }
    
    func switchChangeWithAnimation(_ animtion: Bool) {
        guard let onTintColor = self.onTintColor else {
            return
        }
        
        shape.fillColor = onTintColor.cgColor
        
        if self.isOn {
            let scaleAnimation: CABasicAnimation = animateKeyPath(AnimationConstants.scale, fromValue: 0.01, toValue: 1.0, timing: kCAMediaTimingFunctionEaseIn)
            if !animtion {
                scaleAnimation.duration = 0.0001
            }
            self.shape.add(scaleAnimation, forKey: AnimationConstants.up)
        }else {
            let scaleAnimation: CABasicAnimation = animateKeyPath(AnimationConstants.scale, fromValue: 1.0, toValue: 0.01, timing: kCAMediaTimingFunctionEaseIn)
            if !animtion {
                scaleAnimation.duration = 0.0001
            }
            self.shape.add(scaleAnimation, forKey: AnimationConstants.down)
        }
        
    }
    
    func switchChanged() {
        switchChangeWithAnimation(true)
    }
    
    //MARK: - CAAnimation Delegate
    open func animationDidStart(_ anim: CAAnimation) {
        parentView?.backgroundColor = defaultTintColor
        animationDidStartClosure(isOn)
    }
    
    open func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag == true {
            parentView?.backgroundColor = isOn == true ? onTintColor : defaultTintColor
        }
        
        animationDidStopClosure(isOn, flag)
    }
}

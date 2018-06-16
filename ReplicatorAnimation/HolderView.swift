//
//  HolderView.swift
//  ReplicatorAnimation
//
//  Created by joan mazo on 6/15/18.
//  Copyright © 2018 joan mazo. All rights reserved.
//

import UIKit

class HolderView: UIView {
    
    let ovalLayer = OvalLayer()
    let ovalLayerBackground = OvalLayer()
    let internOvalLayer = OvalLayer()
    let waterLayer = WaterLayer()
    let countingLabel = Countinglabel()
    let checkMarkLayer = CheckMarkLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupLayers() {
        
        addOvalBackground()
        
        ovalLayer.setupOval(with: bounds)
        layer.addSublayer(ovalLayer)
        
        internOvalLayer.setupInternOval(with: bounds)
        layer.addSublayer(internOvalLayer)
        
        waterLayer.setup(frame: bounds)
        setupCounterLabel()
        
        internOvalLayer.addSublayer(countingLabel)
        internOvalLayer.addSublayer(waterLayer)
        countingLabel.frame = CGRect(x: (internOvalLayer.frame.width / 2) - 60,
                                     y: (internOvalLayer.frame.height / 2) - 35,
                                     width: 120,
                                     height: 70)
        
        
        checkMarkLayer.frame = CGRect(x: (frame.width / 2) - 50,
                                      y: (frame.height / 2) - 50,
                                      width: 100,
                                      height: 100)
        checkMarkLayer.setup(frame: bounds)
        layer.addSublayer(checkMarkLayer)
    }
    
    func startAnimations() {
        let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 0.0
        scaleAnimation.toValue = 1.0
        scaleAnimation.damping = 12.0
        scaleAnimation.duration = scaleAnimation.settlingDuration
        scaleAnimation.fillMode = kCAFillModeForwards
        scaleAnimation.isRemovedOnCompletion = false
        
        layer.add(scaleAnimation, forKey: nil)
        
        self.waterLayer.initialAnimation()
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.animateOval), userInfo: nil, repeats: false)
    }
    
    @objc func animateOval() {
        ovalLayer.animate()
        waterLayer.loadingAnimation()
        countingLabel.count(from: 0, to: 99, period: 4.0)
        
        Timer.scheduledTimer(timeInterval: 4.2, target: self, selector: #selector(hideCountingLabel), userInfo: nil, repeats: false)
    }
    
    @objc func hideCountingLabel() {
        countingLabel.animate()
        
        Timer.scheduledTimer(timeInterval: 0.4, target: self, selector: #selector(animateCheckMark), userInfo: nil, repeats: false)
    }
    
    @objc func animateCheckMark() {
        checkMarkLayer.animate()
        
        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { (_) in
            let animation = CABasicAnimation(keyPath: "transform.scale")
            animation.toValue = 0.0
            animation.duration = 0.4
            animation.fillMode = kCAFillModeForwards
            animation.isRemovedOnCompletion = false
            
            self.layer.add(animation, forKey: nil)
        }
    }
    
    func addOvalBackground() {
        ovalLayerBackground.setupOvalBackground(with: bounds)
        layer.addSublayer(ovalLayerBackground)
    }
    
    func setupCounterLabel() {
        countingLabel.string = "0%"
        countingLabel.fontSize = 50
        countingLabel.foregroundColor = UIColor.white.cgColor
        countingLabel.alignmentMode = kCAAlignmentCenter
    }
    
}

class OvalLayer: CAShapeLayer {
    
    let animationDuration: Double = 4.1
    var parentFrame = CGRect.zero
    
    var ovalPath: UIBezierPath {
        return UIBezierPath(arcCenter: .zero, radius: parentFrame.width / 2, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
    }
    
    func setupOval(with frame: CGRect) {
        parentFrame = frame
        fillColor = UIColor.clear.cgColor
        strokeColor = Colors.lightBlue.cgColor
        lineWidth = 5
        path = ovalPath.cgPath
        strokeEnd = 0
        position = CGPoint(x: parentFrame.width / 2, y: parentFrame.height / 2)
        
        //round borders
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        
        transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
    }
    
    func setupOvalBackground(with frame: CGRect) {
        parentFrame = frame
        fillColor = UIColor.clear.cgColor
        strokeColor = Colors.ovalGray.cgColor
        lineWidth = 5
        path = ovalPath.cgPath
        strokeEnd = 1
        position = CGPoint(x: parentFrame.width / 2, y: parentFrame.height / 2)
    }
    
    func setupInternOval(with frame: CGRect) {
        self.frame = CGRect(x: 0, y: 0, width: frame.width - 20, height: frame.height - 20)
        position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        backgroundColor = UIColor.gray.cgColor
        cornerRadius = self.frame.width / 2
        masksToBounds = true
    }
    
    func animate() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        self.add(animation, forKey: nil)
    }
    
}

class WaterLayer: CAShapeLayer {
    
    var parentFrame = CGRect.zero

    lazy var leftWavePath: UIBezierPath = {
        return generatePath(positionY: 0.8, controlPoint1: (width: 0.3, height: 0.7), controlPoint2: (width: 0.5, height: 0.9))
    }()
    
    var arcPathStarting: UIBezierPath {
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: parentFrame.minX, y: parentFrame.height))
        arcPath.addLine(to: CGPoint(x: parentFrame.minX, y: parentFrame.height * 0.8))
        arcPath.addLine(to: CGPoint(x: parentFrame.width, y: parentFrame.height * 0.8))
        arcPath.addLine(to: CGPoint(x: parentFrame.width, y: parentFrame.height))
        arcPath.close()
        
        return arcPath
    }
    
    var arcPathComplete: UIBezierPath {
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: parentFrame.minX, y: parentFrame.height))
        arcPath.addLine(to: CGPoint(x: parentFrame.minX, y: -0.5))
        arcPath.addLine(to: CGPoint(x: parentFrame.width, y: -0.5))
        arcPath.addLine(to: CGPoint(x: parentFrame.width, y: parentFrame.height))
        arcPath.close()
        
        return arcPath
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup(frame: CGRect) {
        parentFrame = frame
        fillColor = Colors.lightBlue.withAlphaComponent(0.84).cgColor
        strokeColor = Colors.lightBlue.cgColor
        path = leftWavePath.cgPath
    }
    
    func initialAnimation() {
    
        let rightWavePath = generatePath(positionY: 0.8, controlPoint1: (width: 0.3, height: 0.9), controlPoint2: (width: 0.6, height: 0.6))
        let rightWaveCompletePath = generatePath(positionY: 0.8, controlPoint1: (width: 0.6, height: 0.8), controlPoint2: (width: 0.8, height: 0.8))
        
        let arcAnimation1 = CABasicAnimation(keyPath: "path")
        arcAnimation1.fromValue = leftWavePath.cgPath
        arcAnimation1.toValue = rightWavePath.cgPath
        arcAnimation1.beginTime = 0.0
        arcAnimation1.duration = 0.75
        
        let arcAnimation2 = CABasicAnimation(keyPath: "path")
        arcAnimation2.fromValue = rightWavePath.cgPath
        arcAnimation2.toValue = rightWaveCompletePath.cgPath
        arcAnimation2.beginTime = arcAnimation1.beginTime + arcAnimation1.duration
        arcAnimation2.duration = 0.75
        
        let arcAnimation3 = CABasicAnimation(keyPath: "path")
        arcAnimation3.fromValue = arcPathStarting.cgPath
        arcAnimation3.toValue = rightWavePath.cgPath
        arcAnimation3.beginTime = arcAnimation2.beginTime + arcAnimation2.duration
        arcAnimation3.duration = 0.75
        
        let arcAnimation4 = CABasicAnimation(keyPath: "path")
        arcAnimation4.fromValue = rightWavePath.cgPath
        arcAnimation4.toValue = rightWaveCompletePath.cgPath
        arcAnimation4.beginTime = arcAnimation3.beginTime + arcAnimation3.duration
        arcAnimation4.duration = 0.75
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [arcAnimation1, arcAnimation2, arcAnimation3, arcAnimation4]
        animationGroup.duration = arcAnimation4.beginTime + arcAnimation4.duration
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.isRemovedOnCompletion = false
        
        add(animationGroup, forKey: nil)
    }
    
    func loadingAnimation() {
        
        let arcPathLow = generatePath(positionY: 0.7, controlPoint1: (width: 0.3, height: 0.8), controlPoint2: (width: 0.5, height: 0.6))
        let arcPathLowComplete = generatePath(positionY: 0.7, controlPoint1: (width: 0.6, height: 0.7), controlPoint2: (width: 0.8, height: 0.5))
        
        let arcPathMid = generatePath(positionY: 0.5, controlPoint1: (width: 0.3, height: 0.3), controlPoint2: (width: 0.6, height: 0.6))
        let arcPathMidComplete = generatePath(positionY: 0.5, controlPoint1: (width: 0.05, height: 0.5), controlPoint2: (width: 0.3, height: 0.5))
        
        let arcPathHigh = generatePath(positionY: 0.25, controlPoint1: (width: 0.4, height: 0.4), controlPoint2: (width: 0.6, height: 0.1))
        let arcPathHighComplete = generatePath(positionY: 0.25, controlPoint1: (width: 0.4, height: 0.10), controlPoint2: (width: 0.7, height: 0.4))
        
        let arcAnimationLow = CABasicAnimation(keyPath: "path")
        arcAnimationLow.toValue = arcPathLow.cgPath
        arcAnimationLow.beginTime = 0.0
        arcAnimationLow.duration = 0.5
        arcAnimationLow.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let arcAnimationLowComplete = CABasicAnimation(keyPath: "path")
        arcAnimationLowComplete.fromValue = arcPathLow.cgPath
        arcAnimationLowComplete.toValue = arcPathLowComplete.cgPath
        arcAnimationLowComplete.beginTime = arcAnimationLow.beginTime + arcAnimationLow.duration
        arcAnimationLowComplete.duration = 0.5
        
        let arcAnimationMid = CABasicAnimation(keyPath: "path")
        arcAnimationMid.fromValue = arcPathLowComplete.cgPath
        arcAnimationMid.toValue = arcPathMid.cgPath
        arcAnimationMid.beginTime = arcAnimationLowComplete.beginTime + arcAnimationLowComplete.duration
        arcAnimationMid.duration = 0.5
        
        let arcAnimationMidComplete = CABasicAnimation(keyPath: "path")
        arcAnimationMidComplete.fromValue = arcPathMid.cgPath
        arcAnimationMidComplete.toValue = arcPathMidComplete.cgPath
        arcAnimationMidComplete.beginTime = arcAnimationMid.beginTime + arcAnimationMid.duration
        arcAnimationMidComplete.duration = 0.5
        
        let arcAnimationHigh = CABasicAnimation(keyPath: "path")
        arcAnimationHigh.fromValue = arcPathMidComplete.cgPath
        arcAnimationHigh.toValue = arcPathHigh.cgPath
        arcAnimationHigh.beginTime = arcAnimationMidComplete.beginTime + arcAnimationMidComplete.duration
        arcAnimationHigh.duration = 0.7
        arcAnimationHigh.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let arcAnimationHighComplete = CABasicAnimation(keyPath: "path")
        arcAnimationHighComplete.fromValue = arcPathHigh.cgPath
        arcAnimationHighComplete.toValue = arcPathHighComplete.cgPath
        arcAnimationHighComplete.beginTime = arcAnimationHigh.beginTime + arcAnimationHigh.duration
        arcAnimationHighComplete.duration = 0.8
        
        let arcAnimationComplete = CABasicAnimation(keyPath: "path")
        arcAnimationComplete.fromValue = arcPathHighComplete.cgPath
        arcAnimationComplete.toValue = arcPathComplete.cgPath
        arcAnimationComplete.beginTime = arcAnimationHighComplete.beginTime + arcAnimationHighComplete.duration
        arcAnimationComplete.duration = 0.5
        
        let arcAnimationGroup = CAAnimationGroup()
        arcAnimationGroup.animations = [arcAnimationLow, arcAnimationLowComplete, arcAnimationMid, arcAnimationMidComplete, arcAnimationHigh, arcAnimationHighComplete, arcAnimationComplete]
        arcAnimationGroup.duration = arcAnimationComplete.beginTime + arcAnimationComplete.duration
        arcAnimationGroup.fillMode = kCAFillModeForwards
        arcAnimationGroup.isRemovedOnCompletion = false
        
        add(arcAnimationGroup, forKey: nil)
    }
    
    func generatePath(positionY: CGFloat, controlPoint1: (width: CGFloat, height: CGFloat), controlPoint2: (width: CGFloat, height: CGFloat)) -> UIBezierPath {
        
        let arcPath = UIBezierPath()
        arcPath.move(to: CGPoint(x: parentFrame.minX, y: parentFrame.height))
        arcPath.addLine(to: CGPoint(x: parentFrame.minX, y: parentFrame.height * positionY))
        
        let endpoint = CGPoint(x: parentFrame.width, y: parentFrame.height * positionY)
        let ctrlPoint1 = CGPoint(x: parentFrame.width * controlPoint1.width, y: parentFrame.height * controlPoint1.height)
        let ctrlPoint2 = CGPoint(x: parentFrame.width * controlPoint2.width, y: parentFrame.height * controlPoint2.height)
        
        arcPath.addCurve(to: endpoint, controlPoint1: ctrlPoint1, controlPoint2: ctrlPoint2)
        arcPath.addLine(to: CGPoint(x: parentFrame.width, y: parentFrame.height))
        arcPath.close()
        
        return arcPath
    }
    
}

class CheckMarkLayer: CAShapeLayer {
    
    var parentFrame = CGRect.zero
    
    var checkMarkPath: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: frame.width * 0.1, y: frame.height * 0.45))
        path.addLine(to: CGPoint(x: frame.width * 0.3, y: frame.height * 0.7))
        path.addLine(to: CGPoint(x: frame.width * 0.85, y: frame.height * 0.15))
        
        return path
    }
    
    func setup(frame: CGRect) {
        parentFrame = frame
        fillColor = UIColor.clear.cgColor
        strokeColor = UIColor.white.cgColor
        lineWidth = 8
        path = checkMarkPath.cgPath
        
        transform = CATransform3DMakeScale(0.0, 0, 0)
    }
    
    func animate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 0.6
        animation.damping = 8.0
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: nil)
    }
    
}

struct Colors {
    static let lightBlue = UIColor.rgb(r: 58, g: 140, b: 236)
    static let ovalGray = UIColor.rgb(r: 242, g: 243, b: 242)
}

extension UIColor {
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}

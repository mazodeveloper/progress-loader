//
//  CountingLabel.swift
//  ReplicatorAnimation
//
//  Created by joan mazo on 6/16/18.
//  Copyright © 2018 joan mazo. All rights reserved.
//

import UIKit

class Countinglabel: CATextLayer {
    
    var startNumber: Float = 0.0
    var endNumber: Float = 0.0
    
    var period: TimeInterval!
    var progress: TimeInterval!
    var lastUpdate: TimeInterval!
    
    var timer: Timer?
    
    var counterValue: Float {
        if progress >= period {
            return endNumber
        }
        
        let percentage = Float(progress / period)
        let counter = 1.0 - powf(1.0 - percentage, 3)
        
        return startNumber + (counter * (endNumber - startNumber) )
    }
    
    func count(from fromValue: Float, to toValue: Float, period: TimeInterval) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.period = period
        
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate
        
        invalidateTimer()
        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(updateValue), userInfo: nil , repeats: true)
    }
    
    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now
        
        if progress >= period {
            invalidateTimer()
            progress = period
        }
        
        
        self.string = "\(Int(counterValue))%"
    }
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func animate() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 0.0
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        add(animation, forKey: nil)
    }
    
}

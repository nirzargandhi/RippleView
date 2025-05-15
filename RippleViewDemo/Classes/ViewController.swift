//
//  ViewController.swift
//  RippleViewDemo
//
//  Created by Nirzar Gandhi on 30/01/24.
//

import UIKit
import CommonCrypto

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var rippleView: UIView!
    
    
    // MARK: -
    // MARK: - View init Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rippleView.layer.cornerRadius = self.rippleView.frame.size.width / 2
        self.addRipple(rView: self.rippleView)
    }
}


// MARK: - Call Back
extension ViewController {
    
    fileprivate func addRipple(rView: UIView) {
        
        let path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: rView.bounds.size.width, height: rView.bounds.size.height))
        
        let shapePosition = CGPoint(x: rView.bounds.size.width / 2.0, y: rView.bounds.size.height / 2.0)
        let rippleShape = CAShapeLayer()
        rippleShape.bounds = CGRect(x: 0, y: 0, width: rView.bounds.size.width, height: rView.bounds.size.height)
        rippleShape.path = path.cgPath
        rippleShape.fillColor = UIColor.clear.cgColor
        rippleShape.strokeColor = UIColor(red: 86.0/255.0, green: 198.0/255.0, blue: 98.0/255.0, alpha: 1.0).cgColor
        rippleShape.lineWidth = 1
        rippleShape.position = shapePosition
        rippleShape.opacity = 0
        
        rView.layer.addSublayer(rippleShape)
        
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = NSValue(caTransform3D: CATransform3DIdentity)
        scaleAnim.toValue = NSValue(caTransform3D: CATransform3DMakeScale(2, 2, 1))
        
        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1
        opacityAnim.toValue = nil
        
        let animation = CAAnimationGroup()
        animation.animations = [scaleAnim, opacityAnim]
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.duration = 1
        animation.repeatCount = Float.infinity
        animation.isRemovedOnCompletion = false
        rippleShape.add(animation, forKey: "rippleEffect")
    }
}

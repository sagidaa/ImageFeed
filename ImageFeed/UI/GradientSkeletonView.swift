//
//  GradientSkeletonView.swift
//  ImageFeed
//
//  Created by Sagida on 10.08.2026.
//

import UIKit

final class GradientSkeletonView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    private let animationKey = "locationsChange"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    @available(*, unavailable)
      required init?(coder: NSCoder) {
          nil
      }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = layer.cornerRadius
    }
    
    func startAnimating() {
        guard gradientLayer.animation(forKey: animationKey) == nil else { return }
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.duration = 1.0
        animation.repeatCount = .infinity
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        
        gradientLayer.add(animation, forKey: animationKey)
    }
    
    func stopAnimating() {
        gradientLayer.removeAnimation(forKey: animationKey)
    }
    
    private func setupGradient() {
        gradientLayer.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        
        gradientLayer.locations = [0, 0.1, 0.3]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        isUserInteractionEnabled = false
        layer.addSublayer(gradientLayer)
        layer.masksToBounds = true
    }
}

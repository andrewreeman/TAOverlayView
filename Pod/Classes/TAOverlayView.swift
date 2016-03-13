//
//  TobOverlayView.swift
//  Mind > Matter
//
//  Created by Nick Yap on 3/5/16.
//  Copyright © 2016 Toboggan Apps LLC. All rights reserved.
//

import UIKit

/// View with a black, semi-transparent overlay that can have subtracted "holes" to view behind the overlay. 
/// Optionally add ``subtractedPaths`` to initialize the overlay with holes. More paths can be subtracted later using ``subtractFromView``.
public class TAOverlayView: UIView {
    
    /// The paths that have been subtracted from the view.
    private var subtractions: [UIBezierPath] = []
    
    /// Use to init the overlay.
    ///
    /// - parameter frame: The frame to use for the semi-transparent overlay.
    /// - parameter subtractedPaths: The paths to subtract from the overlay initially. These are optional (not adding them creates a plain overlay). More paths can be subtracted later using ``subtractFromView``.
    ///
    public init(frame: CGRect, subtractedPaths: [TABaseSubtractionPath]? = nil) {
        super.init(frame: frame)
        
        // Set a semi-transparent, black background.
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.85)
        
        // Create the initial layer from the view bounds.
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.fillColor = UIColor.blackColor().CGColor
        
        let path = UIBezierPath(rect: self.bounds)
        maskLayer.path = path.CGPath
        maskLayer.fillRule = kCAFillRuleEvenOdd
        
        // Set the mask of the view.
        self.layer.mask = maskLayer
        
        if let paths = subtractedPaths {
            // Subtract any given paths.
            self.subtractFromView(paths)
        }
    }


    override public func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        // Allow touches in "holes" of the overlay to be sent to the views behind it.
        for path in self.subtractions {
            if path.containsPoint(point) {
                return false
            }
        }
        return true
    }
    
    /// Subtracts the given ``paths`` from the view.
    public func subtractFromView(paths: [TABaseSubtractionPath]) {
        if let layer = self.layer.mask as? CAShapeLayer, oldPath = layer.path {
            // Start off with the old/current path.
            let newPath = UIBezierPath(CGPath: oldPath)
            
            // Subtract each of the new paths.
            for path in paths {
                self.subtractions.append(path.bezierPath)
                newPath.appendPath(path.bezierPath)
            }
            
            // Update the layer.
            layer.path = newPath.CGPath
            self.layer.mask = layer
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

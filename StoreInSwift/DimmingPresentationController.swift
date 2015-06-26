//
//  DimmingPresentationController.swift
//  StoreInSwift
//
//  Created by thienle on 6/25/15.
//  Copyright (c) 2015 thienle. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    lazy var dimmingView = GradientView(frame: CGRect.zeroRect)
    
    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView.bounds
        containerView.insertSubview(dimmingView, atIndex: 0)
        
        dimmingView.alpha = 0
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (_) -> Void in
                self.dimmingView.alpha = 1
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = presentedViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (_) -> Void in
                self.dimmingView.alpha = 0
                }, completion: nil)
        }
    }
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}

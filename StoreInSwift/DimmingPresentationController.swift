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
    }
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}

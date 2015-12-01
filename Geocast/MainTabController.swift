//
//  MainTabController.swift
//  Geocast
//
//  Created by Andrew Brown on 11/5/15.
//  Copyright (c) 2015 Andrew Brown. All rights reserved.
//

import UIKit

class MainTabController : UITabBarController {
    
    var shouldDismissPlayer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    enum TabIndex: Int {
        case mapIndex = 1
        case podcastIndex = 0
        case playerIndex = 2
    }
    
}

extension MainTabController : UITabBarControllerDelegate{
    func tabBarController(tabBarController: UITabBarController, animationControllerForTransitionFromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let destinationVC = toVC as? PlayerViewController {
            shouldDismissPlayer = false
            return self
        } else if let sourceVC = fromVC as? PlayerViewController {
            shouldDismissPlayer = true
            return self
        } else {
            return nil
        }
    }
}

extension MainTabController: UIViewControllerAnimatedTransitioning {
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView()!
        let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
        let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenBottom = CGAffineTransformMakeTranslation(0, container.frame.height)
        let duration = self.transitionDuration(transitionContext)
        
        if !shouldDismissPlayer {
            // start the toView to the right of the screen
            toView.transform = offScreenBottom
            fromView.transform = CGAffineTransformIdentity
            // add the both views to our view controller
            
            container.addSubview(fromView)
            container.addSubview(toView)
            
            
            UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: {
                
                //            fromView.transform = offScreenLeft
                toView.transform = CGAffineTransformIdentity
                self.tabBar.alpha = 0
                self.navigationController?.navigationBar.alpha = 0.0
                
                }, completion: { finished in
                    
                    // tell our transitionContext object that we've finished animating
                    transitionContext.completeTransition(true)
                    self.shouldDismissPlayer = false
            })
        } else {
            toView.transform = CGAffineTransformIdentity
            fromView.transform = CGAffineTransformIdentity
            
            container.addSubview(toView)
            container.addSubview(fromView)
            navigationController?.navigationBar.alpha = 0.0
            UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseInOut, animations: {
                fromView.transform = offScreenBottom
                self.tabBar.alpha = 1
                self.navigationController?.navigationBar.alpha = 1.0
                }, completion: { finished in
                    
                    transitionContext.completeTransition(true)
                    self.shouldDismissPlayer = false
                    fromView.transform = CGAffineTransformIdentity
                    
            })
        }
        
       
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
}
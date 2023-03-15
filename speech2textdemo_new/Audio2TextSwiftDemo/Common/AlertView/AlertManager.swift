//
//  AlertManager.swift
//  Audio2TextSwiftDemo
//
//  Created by admin on 2023/2/8.
//

import UIKit
import AVFoundation

public let cl_screenWidht = UIScreen.main.bounds.width
public let cl_screenHeight = UIScreen.main.bounds.height

class AlertManager: NSObject {
    
    private struct AlertViewCache {
        var view: UIView?
        var index: Int = 0
    }
    enum AlertPosition {
        case center
        case bottom
    }
    
    private static var vc: UIViewController?
    private static var containerView: UIView?
    private static var currentPosition: AlertPosition = .center
    private static var viewCache: [AlertViewCache] = []
    private static var bottomAnchor: NSLayoutConstraint?
    
    public static func show(view: UIView,
                            alertPostion: AlertPosition = .center,
                            didCoverDismiss: Bool = true) {
        let index = viewCache.isEmpty ? 0 : viewCache.count
        viewCache.append(AlertViewCache(view: view, index: index))
        currentPosition = alertPostion
        if vc == nil {
            containerView = UIButton(frame: CGRect(x: 0, y: 0, width: cl_screenWidht, height: cl_screenHeight))
            containerView?.backgroundColor = UIColor(red: 0.0/255, green: 0.0/255, blue: 0.0/255, alpha: 0.0)
        }
        if didCoverDismiss {
            (containerView as? UIButton)?.addTarget(self, action: #selector(tapView), for: .touchUpInside)
        }
        guard let containerView = containerView else { return }
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0
        if alertPostion == .center {
            view.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            view.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        }else{
            bottomAnchor = view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        }
        if vc == nil {
            vc = UIViewController()
            vc?.view.backgroundColor = UIColor.clear
            vc?.view.addSubview(containerView)
            vc?.modalPresentationStyle = .custom
            UIViewController.cl_topViewController()?.present(vc!, animated: false) {
                showAlertPostion(alertPostion: alertPostion, view: view)
            }
        } else {
            showAlertPostion(alertPostion: alertPostion, view: view)
        }
    }

    private static func showAlertPostion(alertPostion: AlertPosition, view: UIView) {
        containerView?.layoutIfNeeded()
        if alertPostion == .center {
            showCenterView(view: view)
        }else{
            bottomAnchor?.constant = view.frame.height
            bottomAnchor?.isActive = true
            containerView?.layoutIfNeeded()
            showBottomView(view: view)
        }
    }
    
    private static func showCenterView(view: UIView){
        if !viewCache.isEmpty {
            viewCache.forEach({ $0.view?.alpha = 0 })
        }
        UIView.animate(withDuration: 0.25, animations: {
            containerView?.backgroundColor = UIColor(red: 0.0/255,
                                                     green: 0.0/255,
                                                     blue: 0.0/255,
                                                     alpha: 0.5)
            view.alpha = 1.0
        })
    }
    
    private static func showBottomView(view: UIView){
        if !viewCache.isEmpty {
            viewCache.forEach({ $0.view?.alpha = 0 })
        }
        view.alpha = 1.0
        bottomAnchor?.constant = 0
        bottomAnchor?.isActive = true
        UIView.animate(withDuration: 0.25, animations: {
            containerView?.backgroundColor = UIColor(red: 0.0/255,
                                                    green: 0.0/255,
                                                    blue: 0.0/255,
                                                    alpha: 0.5)
            containerView?.superview?.layoutIfNeeded()
        })
    }
    
    static func hiddenView(all: Bool = true, completion: (() -> Void)? = nil){
        if currentPosition == .bottom {
            guard let lastView = viewCache.last?.view else { return }
            bottomAnchor?.constant = lastView.frame.height
            bottomAnchor?.isActive = true
        }
        UIView.animate(withDuration: 0.25, animations: {
            if all || viewCache.isEmpty {
                containerView?.backgroundColor = UIColor(red: 255.0/255,
                                                         green: 255.0/255,
                                                         blue: 255.0/255,
                                                         alpha: 0.0)
                containerView?.layoutIfNeeded()
            }
            if currentPosition == .center {
                viewCache.last?.view?.alpha = 0
            }
        }, completion: { (_) in
            if all || viewCache.isEmpty {
                vc?.dismiss(animated: false, completion: completion)
                vc = nil
            } else {
                viewCache.removeLast()
                viewCache.last?.view?.alpha = 1
            }
        })
    }
    
    @objc
    private static func tapView(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.1))) {
            self.hiddenView()
        }
    }
    
}

extension UIViewController {
    
    static func cl_topViewController(_ viewController: UIViewController? = nil) -> UIViewController? {
        let viewController = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = viewController as? UINavigationController,
            !navigationController.viewControllers.isEmpty
        {
            return self.cl_topViewController(navigationController.viewControllers.last)
            
        } else if let tabBarController = viewController as? UITabBarController,
            let selectedController = tabBarController.selectedViewController
        {
            return self.cl_topViewController(selectedController)
            
        } else if let presentedController = viewController?.presentedViewController {
            return self.cl_topViewController(presentedController)
            
        }
        return viewController
    }
    
}

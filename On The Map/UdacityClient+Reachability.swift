//
//  UdacityClient+Reachability.swift
//  On The Map
//
//  Created by Abhishek Agarwal on 19/05/17.
//  Copyright © 2017 Abhishek. All rights reserved.
//

import Foundation
import ReachabilitySwift

extension UdacityClient {
    
    func addObserverForReachability() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged),name: ReachabilityChangedNotification,object: reachability)
        do{
            try reachability.startNotifier()
        } catch {
            print("could not start reachability notifier")
        }
    }
    
    func removeObserverForReachability() {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        if reachability.isReachable {
            if let alertVc = self.alertController {
                DispatchQueue.main.async {
                    alertVc.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            DispatchQueue.main.async {
                if let topVc = self.topVc() {
                    self.presentAlertForNetworkUnreachable(vc: topVc)
                }
            }
        }
    }
    
    func presentAlertForNetworkUnreachable(vc: UIViewController) {
        if alertController != nil {
        } else {
            alertController = UIAlertController(title: "Oops!", message: "Network not reachable! Please check your connection and try again", preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .cancel, handler: { (_) in
                if self.reachability.isReachable {
                    self.alertController?.dismiss(animated: true, completion: nil)
                } else {
                    self.presentAlertForNetworkUnreachable(vc: vc)
                }
            })
            alertController?.addAction(retryAction)
        }
        vc.present(alertController!, animated: true, completion: nil)
    }
    
    func topVc() -> UIViewController? {
        if let delegate = UIApplication.shared.delegate, let window = delegate.window {
            var topVc = window?.rootViewController
            while let presentedVc = topVc?.presentedViewController {
                print(presentedVc)
                topVc = presentedVc
            }
            return topVc
        } else {
            return nil
        }
    }
}

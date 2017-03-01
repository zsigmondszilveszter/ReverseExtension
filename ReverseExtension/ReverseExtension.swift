//
//  ReverseExtension.swift
//  ReverseExtension
//
//  Created by marty-suzuki on 2017/03/01.
//
//

import UIKit

extension UITableView {
    private struct AssociatedKey {
        static var re: UInt8 = 0
    }
    
    public var re: ReverseExtension {
        guard let re = objc_getAssociatedObject(self, &AssociatedKey.re) as? ReverseExtension else {
            let re = ReverseExtension(self)
            objc_setAssociatedObject(self, &AssociatedKey.re, re, .OBJC_ASSOCIATION_RETAIN)
            return re
        }
        return re
    }
}

extension UITableView {
    public final class ReverseExtension: NSObject {
        private(set) weak var base: UITableView?
        
        //MARK: Delegate
        private var delegateTransporter: UITableViewDelegateTransporter? {
            didSet { base?.delegate = delegateTransporter }
        }
        public weak var delegate: UITableViewDelegate? {
            didSet {
                guard let delegate = delegate else {
                    delegateTransporter = nil
                    return
                }
                delegateTransporter = UITableViewDelegateTransporter(delegates: [delegate, self])
            }
        }
        
        //MARK: - reachedBottom
        private lazy var _reachedBottom: Bool = {
            guard let base = self.base else { return false }
            return base.contentOffset.y <= 0
        }()
        fileprivate(set) var reachedBottom: Bool {
            set {
                let oldValue = _reachedBottom
                _reachedBottom = newValue
                if _reachedBottom == oldValue { return }
                guard let base = base, _reachedBottom else { return }
                scrollViewDidReachBottom?(base)
            }
            get {
                return _reachedBottom
            }
        }
        public var scrollViewDidReachBottom: ((UIScrollView) -> ())?
        
        //MARK: - reachedTop
        private lazy var _reachedTop: Bool = {
            guard let base = self.base else { return false }
            let maxScrollDistance = max(0, base.contentSize.height - base.bounds.size.height)
            return base.contentOffset.y >= maxScrollDistance
        }()
        fileprivate(set) var reachedTop: Bool {
            set {
                let oldValue = _reachedTop
                _reachedTop = newValue
                if _reachedTop == oldValue { return }
                guard let base = base, _reachedTop else { return }
                scrollViewDidReachTop?(base)
            }
            get {
                return _reachedTop
            }
        }
        public var scrollViewDidReachTop: ((UIScrollView) -> ())?
        
        deinit {}
        
        //MARK: - Initializer
        fileprivate init(_ base: UITableView) {
            self.base = base
            super.init()
            configureTableView()
        }
        
        private func configureTableView() {
            guard let base = self.base else { return }
            if base.transform == CGAffineTransform.identity {
                base.transform = CGAffineTransform.identity.rotated(by: .pi)
            }
        }
    }
}

extension UITableView.ReverseExtension: UITableViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let hasContent = scrollView.contentSize.height > 0
        reachedBottom = scrollView.contentOffset.y <= 0 && hasContent
        let maxScrollDistance = max(0, scrollView.contentSize.height - scrollView.bounds.size.height)
        reachedTop = scrollView.contentOffset.y >= maxScrollDistance && hasContent
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.transform == CGAffineTransform.identity {
            UIView.setAnimationsEnabled(false)
            cell.transform = CGAffineTransform.identity.rotated(by: .pi)
            UIView.setAnimationsEnabled(true)
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if view.transform == CGAffineTransform.identity {
            UIView.setAnimationsEnabled(false)
            view.transform = CGAffineTransform.identity.rotated(by: .pi)
            UIView.setAnimationsEnabled(true)
        }
    }
}

//
//  SynchronizedScrollView.swift
//  Pods Updater
//
//  Created by Kizito Nwose on 01/02/2018.
//  Copyright © 2018 Kizito Nwose. All rights reserved.
//

import Cocoa

// A subclass of NSScrollView that can scroll alongside another NSScrollView
// https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/SynchroScroll.html
class SynchronizedScrollView: NSScrollView {
    
    weak var synchronizedScrollView: NSScrollView?
    
    func setSynchronizedScrollView(_ scrollview: NSScrollView) {
        var synchronizedContentView: NSView
        // stop an existing scroll view synchronizing
        stopSynchronizing()
        // don't retain the watched view, because we assume that it will
        // be retained by the view hierarchy for as long as we're around.
        synchronizedScrollView = scrollview
        // get the content view of the
        synchronizedContentView = synchronizedScrollView!.contentView
        // Make sure the watched view is sending bounds changed
        // notifications (which is probably does anyway, but calling
        // this again won't hurt).
        synchronizedContentView.postsBoundsChangedNotifications = true
        // a register for those notifications on the synchronized content view.
        NotificationCenter.default.addObserver(self, selector: #selector(synchronizedViewContentBoundsDidChange(_:)),
                                               name: NSView.boundsDidChangeNotification, object: synchronizedContentView)
    }
    
    @objc private func synchronizedViewContentBoundsDidChange(_ notification: NSNotification) {
        // get the changed content view from the notification
        guard let changedContentView = notification.object as? NSClipView else { return }
        // get the origin of the NSClipView of
        // the scroll view that we're watching
        let changedBoundsOrigin = changedContentView.documentVisibleRect.origin
        
        // get our current origin
        let curOffset = contentView.bounds.origin
        var newOffset = curOffset
        // scrolling is synchronized in the vertical plane
        // so only modify the y component of the offset
        newOffset.y = changedBoundsOrigin.y
        // if our synced position is different from our current
        // position, reposition our content view
        if !NSEqualPoints(curOffset, changedBoundsOrigin) {
            // note that a scroll view watching this one will
            // get notified here
            contentView.scroll(to: newOffset)
            // we have to tell the NSScrollView to update its
            // scrollers
            reflectScrolledClipView(contentView)
        }
    }
    
    private func stopSynchronizing() {
        if let synchronizedScrollView = synchronizedScrollView {
            let synchronizedContentView = synchronizedScrollView.contentView
            // remove any existing notification registration
            NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification,
                                                      object: synchronizedContentView)
            // set synchronizedScrollView to nil
            self.synchronizedScrollView = nil
        }
    }
}

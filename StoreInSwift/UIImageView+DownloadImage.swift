//
//  UIImageView+DownloadImage.swift
//  StoreInSwift
//
//  Created by thienle on 6/25/15.
//  Copyright (c) 2015 thienle. All rights reserved.
//

import UIKit

extension UIImageView {
    func loadImageWithURL(url: NSURL) -> NSURLSessionDownloadTask {
        let session = NSURLSession.sharedSession()
        
        // 1
        let downloadTask = session.downloadTaskWithURL(url, completionHandler: { (url, response, error) -> Void in
            // 2
            if error == nil && url != nil {
                // 3
                if let data = NSData(contentsOfURL: url) {
                    if let image = UIImage(data: data) {
                        // 4
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.image = image
                        })
                    }
                }
            }
        })
        downloadTask.resume()  //After creating the download task you call resume() to start it, and then return the NSURLSessionDownloadTask object to the caller. Why return it? That gives the app the opportunity to call cancel() on the download task. You’ll see how that works in a minute.
        return downloadTask
    }
}

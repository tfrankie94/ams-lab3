//
//  Download.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 22/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import Foundation

class Download {
    
    var photo: Photo
    init(photo: Photo) {
        self.photo = photo
    }
    
    // Download service sets these values:
    var task: URLSessionDownloadTask?
    var isDownloading = false
    var resumeData: Data?
    
}

//
//  Photo.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import Foundation

class Photo {
    
    var url: String
    var progress: Float
    
    init(url: String, progress: Float = 0) {
        self.url = url
        self.progress = progress
    }
    
}

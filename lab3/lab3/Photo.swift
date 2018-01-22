//
//  Photo.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import Foundation

class Photo {
    
    var url: URL
    let index: Int
    var progress: Float = 0;
    var downloaded = false
    
    init(url: URL, index: Int) {
        self.url = url
        self.index = index
    }
    
}

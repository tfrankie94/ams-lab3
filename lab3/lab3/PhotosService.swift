//
//  PhotosService.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import Foundation

class PhotosService {
    
    var photos = [
        Photo(url: "https://upload.wikimedia.org/wikipedia/commons/0/04/Dyck,_Anthony_van_-_Family_Portrait.jpg")
//        "https://upload.wikimedia.org/wikipedia/commons/0/06/Master_of_Flémalle_-_Portrait_of_a_Fat_Man_-_Google_Art_Project_(331318).jpg",
//        "https://upload.wikimedia.org/wikipedia/commons/c/ce/Petrus_Christus_-_Portrait_of_a_Young_Woman_-_Google_Art_Project.jpg",
//        "https://upload.wikimedia.org/wikipedia/commons/3/36/Quentin_Matsys_-_A_Grotesque_old_woman.jpg",
//        "https://upload.wikimedia.org/wikipedia/commons/c/c8/Valmy_Battle_painting.jpg"
    ]
    
    
    func getPhotos() -> [Photo] {
        return photos;
    }
    
    func downloadPhoto(url: String, controller: PhotosViewController) {
//        controller.photoDownload(url: url)
        
        print("URL: \(url)")
        
        let imageURL: URL = URL(string: url)!
        let config = URLSessionConfiguration.background(withIdentifier: "pl.edu.agh.kis.bgDownload")
        config.sessionSendsLaunchEvents = true
        config.isDiscretionary = true
        let session = URLSession(configuration: config, delegate: controller, delegateQueue: OperationQueue.main)
        let task = session.downloadTask(with: imageURL)
        task.resume()
    }
    
    
}

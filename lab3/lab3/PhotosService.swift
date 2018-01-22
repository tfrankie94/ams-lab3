//
//  PhotosService.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import Foundation

class PhotosService {
    
    var activeDownloads: [URL: Download] = [:]
    var downloadsSession: URLSession?
        
    var photos = [
        Photo(url: URL.init(string: "https://upload.wikimedia.org/wikipedia/commons/0/04/Dyck,_Anthony_van_-_Family_Portrait.jpg")!, index: 0),
//        Photo("https://upload.wikimedia.org/wikipedia/commons/0/06/Master_of_Flémalle_-_Portrait_of_a_Fat_Man_-_Google_Art_Project_(331318).jpg"),
//        Photo("https://upload.wikimedia.org/wikipedia/commons/c/ce/Petrus_Christus_-_Portrait_of_a_Young_Woman_-_Google_Art_Project.jpg"),
//        Photo("https://upload.wikimedia.org/wikipedia/commons/3/36/Quentin_Matsys_-_A_Grotesque_old_woman.jpg"),
//        Photo("https://upload.wikimedia.org/wikipedia/commons/c/c8/Valmy_Battle_painting.jpg"),
    ]
    
    func startDownload(_ photo: Photo) {
        let download = Download(photo: photo)
        download.task = downloadsSession?.downloadTask(with: photo.url)
        download.task!.resume()
        download.isDownloading = true
        activeDownloads[download.photo.url] = download
    }
    
//    func cancelDownload(_ photo: Photo) {
//        if let download = activeDownloads[photo.url] {
//            download.task?.cancel()
//            activeDownloads[photo.url] = nil
//        }
//    }
    
    func pauseDownload(_ photo: Photo) {
        guard let download = activeDownloads[photo.url] else { return }
        if download.isDownloading {
            download.task?.cancel(byProducingResumeData: { data in
                download.resumeData = data
            })
            download.isDownloading = false
        }
    }
    
    func resumeDownload(_ photo: Photo) {
        guard let download = activeDownloads[photo.url] else { return }
        if let resumeData = download.resumeData {
            download.task = downloadsSession?.downloadTask(withResumeData: resumeData)
        } else {
            download.task = downloadsSession?.downloadTask(with: download.photo.url)
        }
        download.task!.resume()
        download.isDownloading = true
    }
    
//    func downloadPhoto(url: String, controller: PhotosViewController) {
//        let imageURL: URL = URL(string: url)!
//        let config = URLSessionConfiguration.background(withIdentifier: "pl.edu.agh.kis.bgDownload")
//        config.sessionSendsLaunchEvents = true
//        config.isDiscretionary = true
//        let session = URLSession(configuration: config, delegate: controller, delegateQueue: OperationQueue.main)
//        let task = session.downloadTask(with: imageURL)
//        task.resume()
//    }
    
    
}

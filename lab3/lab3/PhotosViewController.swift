//
//  PhotosViewController.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import UIKit

class PhotosViewController : UITableViewController, URLSessionDelegate, URLSessionDownloadDelegate {

    var photos : [Photo]?
    var photosService: PhotosService?
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "pl.edu.agh.kis.bgDownload")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosService = PhotosService();
        photosService?.downloadsSession = downloadsSession
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.photos = photosService?.photos
        
        for photo in photos! {
            photosService?.startDownload(photo)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        TODO: IMPLEMENT STOP
//        DownloadManager.shared.onProgress = nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if photos != nil {
            return photos!.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        
        let photo = photos![indexPath.row]
        
        cell.textLabel?.text = "\(photo.url)"
        if (photo.progress == 1) {
            cell.detailTextLabel?.text = "Downloaded."
        } else {
            cell.detailTextLabel?.text = "Progress \(photo.progress*100)%"
        }
        return cell
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let download = photosService?.activeDownloads[url]
        download?.photo.progress = 1
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: (download?.photo.index)!, section: 0)], with: .none)
        }
        
        photosService?.activeDownloads[url] = nil
//
//        var destinationURL = URL.init(string: "eh");
//        let fileManager = FileManager.default
//        try? fileManager.removeItem(at: destinationURL!)
//        do {
//            try fileManager.copyItem(at: location, to: destinationURL!)
//            download?.photo.downloaded = true
//        } catch let error {
//            print("Could not copy file to disk: \(error.localizedDescription)")
//        }
//        if let index = download?.photo.index {
//            DispatchQueue.main.async {
//                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//            }
//        }
        

        print("TODO: ")
        //        you can check if a file exists using the file manager's fileExists(atPath:) method
        //        to delete a file, use removeItem(atPath:)
        //        to copy a file, use copyItem(atPath:toPath:)
        //        File manipulation functions throw exceptions. The easiest way to deal with them is to use try? (which results in an optional) or try! (if you are sure what you're doing). More info on error handling
        //            If the download completes when the app is inactive, the application(_:handleEventsForBackgroundURLSession:completionHandler:) will be called instead. Handle that event appropriately as well.
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,                  totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let download = photosService?.activeDownloads[url]
        download?.photo.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: (download?.photo.index)!, section: 0)], with: .none)
        }
    }
    
    private func getPhotoByUrl(url: String) -> Photo? {
        return photos![0];
    }
    
}

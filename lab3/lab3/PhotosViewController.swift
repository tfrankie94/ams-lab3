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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosService = PhotosService();
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.photos = photosService?.getPhotos();
        
        for photo in photos! {
            print("started downloading: \(photo)")
            photosService?.downloadPhoto(url: photo.url, controller: self)
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
    
    func photoDownload(url: String) {
        print("DOWNLOADED \(url)")
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath)
        
        let photo = photos![indexPath.row]
        
        cell.textLabel?.text = "\(photo.url)"
        if (photo.progress == 1) {
            cell.detailTextLabel?.text = "Downloaded."
        } else {
            cell.detailTextLabel?.text = "Progress \(photo.progress)"
        }
        return cell
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let url = downloadTask.originalRequest?.url,
            let photo = self.getPhotoByUrl(url: url.path)  else { return }
        photo.progress = 1;
        self.tableView.reloadData();
        
        
        print("well, looks like it's already downloaded to:")
        print(location)
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        
        print("TODO: ")
        //        you can check if a file exists using the file manager's fileExists(atPath:) method
        //        to delete a file, use removeItem(atPath:)
        //        to copy a file, use copyItem(atPath:toPath:)
        //        File manipulation functions throw exceptions. The easiest way to deal with them is to use try? (which results in an optional) or try! (if you are sure what you're doing). More info on error handling
        //            If the download completes when the app is inactive, the application(_:handleEventsForBackgroundURLSession:completionHandler:) will be called instead. Handle that event appropriately as well.
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,                  totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url,
            let photo = self.getPhotoByUrl(url: url.path)  else { return }
        photo.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        self.tableView.reloadData();
    }
    
    private func getPhotoByUrl(url: String) -> Photo? {
        return photos![0];
    }
    
    private func calculateProgress(session : URLSession, completionHandler : @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let progress = downloads.map({ (task) -> Float in
                if task.countOfBytesExpectedToReceive > 0 {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                } else {
                    return 0.0
                }
            })
            completionHandler(progress.reduce(0.0, +))
        }
    }


}

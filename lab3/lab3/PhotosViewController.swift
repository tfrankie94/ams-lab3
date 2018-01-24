//
//  PhotosViewController.swift
//  lab3
//
//  Created by Tomasz Frankiewicz on 21/01/2018.
//  Copyright © 2018 Tomasz Frankiewicz. All rights reserved.
//

import UIKit

class PhotoCell: UITableViewCell {
    @IBOutlet weak var photoName: UILabel!
    @IBOutlet weak var photoProgress: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
}

class PhotosViewController : UITableViewController, URLSessionDelegate, URLSessionDownloadDelegate {

    var photos : [Photo]?
    var photosService: PhotosService?
    var start: NSDate?
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "pl.edu.agh.kis.bgDownload")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photosService = PhotosService();
        photosService?.downloadsSession = downloadsSession
        
        tableView.rowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        self.photos = photosService?.photos
        self.start = NSDate()
        
        for photo in photos! {
            print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) started download of \(photo.url)")
            photosService?.startDownload(photo)
        }
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let photo = photos![indexPath.row]
        
        cell.photoName?.text = "\(photo.url.lastPathComponent)"
        cell.photoProgress?.text = "Progress \(photo.progress*100)%"

        if (photo.downloaded) {
            cell.photoImage.image = loadImage(filePath: photo.location!)
        }
        
        if (photo.facesDetected != -1) {
            cell.photoProgress?.text = "Faces detected: \(photo.facesDetected)"
        }
        return cell
    }
    
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let download = photosService?.activeDownloads[url]
        photosService?.activeDownloads[url] = nil

        print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) finished download of \(download!.photo.url) to \(location.path)")
        
        //SAVE FILE TO DOCUMENTS
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let destinationFile = NSURL(fileURLWithPath: docDir).appendingPathComponent(url.lastPathComponent)?.path
        let fileManager = FileManager.default
        if (fileManager.fileExists(atPath: destinationFile!)) {
            try?  fileManager.removeItem(atPath: destinationFile!)
        }
        do {
            try fileManager.copyItem(atPath: location.path, toPath: destinationFile!)
            print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) copied \(download!.photo.url) to \(destinationFile!)")
            download?.photo.downloaded = true
            download?.photo.location = destinationFile;
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        reloadCell(photo: (download?.photo)!, progress: 1)
        
        print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) started faces detection of \(download!.photo.url)")
        DispatchQueue.global(qos: .background).async {
            self.detectFaces(photo: (download?.photo)!, filePath: destinationFile!)
        }
    }
    
    func detectFaces(photo: Photo, filePath: String) {
        guard let image = CIImage(image: loadImage(filePath: filePath)!) else {
            return
        }
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let faces = faceDetector?.features(in: image)
        
        photo.facesDetected = (faces?.count)!;
        print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) found \(photo.facesDetected) faces detection in \(photo.url)")
        reloadCell(photo: photo, progress: 1)
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,                  totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        guard let url = downloadTask.originalRequest?.url else { return }
        let download = photosService?.activeDownloads[url]
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        if(progress>0.5 && !(download?.progressSaved)!){
            print("\(String(describing: NSDate().timeIntervalSince(start! as Date))) 50% of \(download!.photo.url)")
            download?.progressSaved = true;
        }

        reloadCell(photo: (download?.photo)!, progress: progress)
    }
    
    private func reloadCell(photo: Photo, progress: Float) {
        photo.progress = progress
        let index = photo.index;
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    private func loadImage(filePath: String) -> UIImage? {
        let fileUrl = NSURL(fileURLWithPath: filePath)
        do {
            let imageData = try Data(contentsOf: fileUrl as URL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
}

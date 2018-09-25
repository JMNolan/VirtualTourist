//
//  VTConvenience.swift
//  VirtualTourist
//
//  Created by John Nolan on 7/1/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//
import Foundation

extension virtualTouristModel {
    
    // MARK: pull photos for the location of the pin selected
    func getPhotosForLocation (latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ dataArray: [URL], _ imageCount: Int, _ totalPages: Int, _ currentPage: Int) -> Void ) {
        let urlString = "\(virtualTouristModel.Constants.Methods.photoSearchUrl)&lat=\(latitude)&lon=\(longitude)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(false, "An error occured with the URL request: \(error!)", [], 0, 0, 0)
                return
            }
            
            guard let data = data else {
                completionHandler(false, "Unable to locate data in request", [], 0, 0, 0)
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            guard statusCode! <= 299 && statusCode! >= 200 else {
                completionHandler(false, "Request failed. Status code \(statusCode!). Please try again later.", [], 0, 0, 0)
                return
            }
            
            do {
                let parsedResults = try JSONDecoder().decode(virtualTouristModel.Constants.PhotoResults.self, from: data)
                var photoURL: [URL] = []
                var photoId: [String] = []
                for photo in (parsedResults.photos?.photo!)! {
                    let imageURL = self.pinPhotoToURL(photo: photo)
                    photoURL.append(imageURL)
                    photoId.append(photo.id!)
                }
                completionHandler(true, nil, photoURL, Int((parsedResults.photos?.photo?.count)!), (parsedResults.photos?.pages)!, (parsedResults.photos?.page)!)
                return
            } catch {
                completionHandler(false, "Data parse failed:\(error)", [], 0, 0, 0)
                return
            }
        }
        task.resume()
    }
    
    //takes in a pinPhoto object and returns a url to be used as image data
    func pinPhotoToURL (photo: virtualTouristModel.Constants.pinPhoto) -> URL {
        return URL(string: "https://farm\(photo.farm!).staticflickr.com/\(photo.server!)/\(photo.id!)_\(photo.secret!).jpg")!
    }
}

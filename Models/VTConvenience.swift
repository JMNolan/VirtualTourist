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
    func getPhotosForLocation (latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?, _ dataArray: [Data]) -> Void ) {
        let urlString = "\(virtualTouristModel.Constants.Methods.photoSearchUrl)&lat=\(latitude)&lon=\(longitude)&per_page=50"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(false, "An error occured with the URL request: \(error!)", [])
                return
            }
            
            guard let data = data else {
                completionHandler(false, "Unable to locate data in request", [])
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            guard statusCode! <= 299 && statusCode! >= 200 else {
                completionHandler(false, "Request failed. Status code \(statusCode!). Please try again later.", [])
                return
            }
            
            do {
                let parsedResults = try JSONDecoder().decode(virtualTouristModel.Constants.PhotoResults.self, from: data)
                var photoData: [Data] = []
                for photo in (parsedResults.photos?.photo!)! {
                    let imageData = try? Data(contentsOf: self.pinPhotoToURL(photo: photo))
                    photoData.append(imageData!)
                }
                //TODO: return the data array to be used to create photo array
                completionHandler(true, nil, photoData)
                print("This many properties are being passed: \(photoData.count)")
                return
                
            } catch {
                completionHandler(false, "Data parse failed:\(error)", [])
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

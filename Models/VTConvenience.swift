//
//  VTConvenience.swift
//  VirtualTourist
//
//  Created by John Nolan on 7/1/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//
import Foundation

extension virtualTouristModel {
    
    // MARK: getPhotosForLocation function
    func getPhotosForLocation (latitude: Double, longitude: Double, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void ) {
        let urlString = "\(virtualTouristModel.Constants.Methods.baseURL)\(virtualTouristModel.Constants.Methods.photosForLocation)&\(virtualTouristModel.Constants.FlickrParameterKeys.apiKey)=\(virtualTouristModel.Constants.FlickrParameterValues.apiKey)&\(virtualTouristModel.Constants.FlickrParameterKeys.latitude)=\(latitude)&\(virtualTouristModel.Constants.FlickrParameterKeys.longitude)=\(longitude)"
        let request = URLRequest(url: URL(string: urlString)!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                completionHandler(false, "An error occured with the URL request")
                return
            }
            
            guard let data = data else {
                completionHandler(false, "Unable to locate data in request")
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode
            guard statusCode! <= 299 && statusCode! >= 200 else {
                completionHandler(false, "Request failed. Status code \(statusCode!). Please try again later.")
                return
            }
            
            do {
                // TODO: Parse data
            } catch {
                completionHandler(false, "Data parse failed:\(error)")
                return
            }
        }
        task.resume()
    }
}

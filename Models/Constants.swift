//
//  Constants.swift
//  VirtualTourist
//
//  Created by John Nolan on 7/2/18.
//  Copyright © 2018 John Nolan. All rights reserved.
//

import Foundation

extension virtualTouristModel {
    //MARK: Constants
    struct Constants {
        // MARK: Flickr Parameter Keys
        struct FlickrParameterKeys {
            static let method = "method"
            static let apiKey = "api_key"
            static let format = "format"
            static let authToken = "auth_token"
            static let apiSig = "api_sig"
            static let latitude = "lat"
            static let longitude = "lon"
        }
        
        // MARK: Flickr Parameter Values
        struct FlickrParameterValues {
            static let apiKey = "6279cbb3e07c7ffd7a9bf9fa3018a9a2"
            static let responseFormat = "json"
        }
        
        // MARK: Codable structs to be used in parsing json data
        struct PhotoResults: Codable {
            static var photos: Photos!
        }
        
        struct Photos: Codable {
            static var page: String = ""
            static var pages: String = ""
            static var perpage: String = ""
            static var total: String = ""
            static var photo: [Photo]!
        }
        
        struct Photo: Codable {
            static var id: String = ""
            static var owner: String = ""
            static var secret: String = ""
            static var server: String = ""
            static var farm: String = ""
            static var title: String = ""
            static var ispublic: String = ""
            static var isfriend: String = ""
            static var isfamily: String = ""
        }
        
        // TODO: Delete the response keys below if not needed due to using JSONDecoder
        // MARK: Flickr Response Keys photosForLocation
        struct FlickrPhotosForLocationResponseKeys: Decodable {
            static let photos = "photos"
            
            // Response keys for the photo objects in the array
            static let photo = "photo"
            static let id = "id"
            static let owner = "owner"
            static let secret = "secret"
            static let server = "server"
            static let farm = "farm"
            static let title = "title"
            static let isPublic = "ispublic"
            static let isFriend = "isfriend"
            static let isFamily = "isfamily"
        }
        
        struct FlickrPhotosForLocationResponseKeysPhotos: Decodable {
            static let page = "page"
            static let pages = "pages"
            static let perPage = "perpage"
            static let total = "total"
        }
        
        
        //MARK: Flickr API Key
        static let ApiKey = "6279cbb3e07c7ffd7a9bf9fa3018a9a2"
        
        //MARK: Methods
        struct Methods {
            static let baseURL = "http://api.flickr.com/services/rest/"
            static let photosForLocation = "flickr.photos.geo.photosForLocation"
        }
    }
    
    // MARK: Singleton
    class func sharedInstance() -> virtualTouristModel {
        struct Singleton {
            static var sharedInstance = virtualTouristModel()
        }
        return Singleton.sharedInstance
    }
}

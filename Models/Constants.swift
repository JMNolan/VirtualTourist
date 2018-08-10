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
        struct PhotoResults: Decodable {
            var photos: Photos?
            var stat: String?
        }
        
        struct Photos: Decodable {
            var page: Int?
            var pages: Int?
            var perpage: Int?
            var total: String?
            var photo: [pinPhoto]?
        }
        
        struct pinPhoto: Decodable {
            var id: String?
            var owner: String?
            var secret: String?
            var server: String?
            var farm: Int?
            var title: String?
            var ispublic: Int?
            var isfriend: Int?
            var isfamily: Int?
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
            static let photoSearchUrl = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(virtualTouristModel.Constants.ApiKey)&format=json&nojsoncallback=1"
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

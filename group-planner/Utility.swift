//
//  Utility.swift
//  group-planner
//
//  Created by Hoang on 4/24/18.
//  Copyright © 2018 Christopher Guan. All rights reserved.
//

import Parse
import Alamofire

class ParseUtility {
    static func getPFFileFromImage(_ image: UIImage) -> PFFile {
        let imageData = UIImagePNGRepresentation(image)!
        return PFFile(name: "profile.png", data: imageData)!
    }
}

class NetworkUtility {
    static func downloadImage(url: URL, completion: @escaping (UIImage?, Error?) -> Void) {
        Alamofire.request(url).response {
            response in
            if let data = response.data {
                if let img = UIImage(data: data) {
                    completion(img, nil)
                }
            }
            else if let error = response.error {
                completion(nil, error)
            }
        }
    }
    
    static func request(url: URL, completion: @escaping ([String:Any]?, Error?) -> Void) {
        Alamofire.request(url)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    completion(nil, error)
                    break;
                case .success:
                    guard let userDictionary = response.result.value as? [String: Any] else {
                        print("Can't parse json")
                        completion(nil, nil)
                        return
                    }
                    
                    completion(userDictionary, nil)
                }
        }
    }
}

//
//  Translate.swift
//  Travel Buds
//
//  Created by Yongkang Lin on 12/2/23.
//

import Foundation

struct Translate {
    
    let headers = [
        "content-type": "application/x-www-form-urlencoded",
        "X-RapidAPI-Key": "2662f16475mshccad9833a635480p1ee279jsn44ebbb180417",
        "X-RapidAPI-Host": "google-translate113.p.rapidapi.com"
    ]
    
    func translate(text: String, targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        var postData = Data()
        if let fromData = "from=auto".data(using: .utf8),
           let toData = "&to=\(targetLanguage)".data(using: .utf8),
           let textData = "&text=\(text)".data(using: .utf8) {
            postData.append(fromData)
            postData.append(toData)
            postData.append(textData)
            let request = NSMutableURLRequest(url: NSURL(string: "https://google-translate113.p.rapidapi.com/api/v1/translator/text")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if let error = error {
                    completion(.failure(error))
                } else {
                    if let httpResponse = response as? HTTPURLResponse, let data = data {
                        let translatedText = String(data: data, encoding: .utf8)
                        print(translatedText)
                        completion(.success(translatedText ?? ""))
                    } else {
                        completion(.failure(NSError(domain: "TranslationError", code: 0, userInfo: nil)))
                    }
                }
            })
            
            dataTask.resume()
        }
    }
}

struct TranslationInfo: Decodable{
    let trans: String
    let source_language: String
}


//
//  HttpRequestToMedsenger.swift
//  spirometer
//
//  Created by Tikhon Petrishchev on 05.09.2022.
//

import Foundation




func postRequest(jsonData: [String: Any], url: String) {
    let jsonData = try? JSONSerialization.data(withJSONObject: jsonData)
    guard let url = URL(string: url) else {
        print("Invalid url!")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("\(String(describing: jsonData?.count))", forHTTPHeaderField: "Content-Length")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = jsonData
    
    URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
        guard error != nil else {
            print(error?.localizedDescription ?? "No data")
            return
        }
        print("Done")
    }).resume()
}

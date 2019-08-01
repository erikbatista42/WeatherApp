//
//  ViewController.swift
//  WeatherApp
//
//  Created by luxury on 7/31/19.
//  Copyright © 2019 luxury. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let key = "ae2660cbfb15ae919e944f013ed49449"
    let zipCode = "94108"
    var weatherType:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        fetchData()
        
    }

    func fetchData() {
        // 1 - make a request with URLSession
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?zip=\(zipCode),us&APPID=\(key)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("omg something went wrong: \(err)")
            }
            guard let data = data else { return }
            print(String(data: data, encoding: .utf8))
//            print("That data: \(data)")
            print("Response: \(response!)")
            
            // 2 - parse the response (json)
            do {
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.sync {
                    let currentWeather = weatherData.weather[0]?.description
//                    print("Works: \(currentWeather)")
                    self.weatherType = currentWeather
                    if let weatherT = self.weatherType {
                        print(weatherT)
                    } else {
                        print("something went wrong")
                    }
//                    print(self.weatherType)
                }
            } catch let jsonError {
                print("something went wrong while fetching json: \(jsonError.localizedDescription)")
            }
        }.resume()
    }
}


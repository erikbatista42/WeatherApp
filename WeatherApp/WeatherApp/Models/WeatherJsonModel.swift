//
//  WeatherModel.swift
//  WeatherApp
//
//  Created by luxury on 7/31/19.
//  Copyright © 2019 luxury. All rights reserved.
//

import Foundation

struct WeatherJsonModel: Decodable {
    let coord: Coord?
    
    let weather: [Weather?]
    let base: String?
    
    let main: Main?
    let visibility: Int?
    
    let wind: Wind?
    
    let clouds: Clouds?
    let dt: Int?
    
    let sys: Sys?
    let timezone: Int?
    let id: Int?
    let name: String?
    let cod: Int?
}

struct Coord: Decodable {
    let lon: Double?
    let lat: Double?
}

struct Weather: Decodable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

struct Main: Decodable {
    let temp: Double?
    let pressure: Double?
    let humidity: Double?
    let temp_min: Double?
    let temp_max: Double?
}

struct Wind: Decodable {
    let speed: Double?
    
    let deg: Int?
}

struct Clouds: Decodable {
    let all: Int?
}

struct Sys: Decodable {
    let type: Int?
    let id: Int?
    let message: Double?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

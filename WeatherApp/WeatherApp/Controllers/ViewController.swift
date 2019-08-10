//
//  ViewController.swift
//  WeatherApp
//
//  Created by luxury on 7/31/19.
//  Copyright © 2019 luxury. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let key = "ae2660cbfb15ae919e944f013ed49449"
    var zipCode: String?
    var currentWeatherType: String?
    var cityName: String?
    var userFeeling: String?
    let isFirstLaunch = UserDefaults.isFirstLaunch()
    let tableView = UITableView()
    let cellId = "cellId"
    let items = [Item]?.self
    
    let weatherDataObject = WeatherData()
    var storedWeatherDataObject: Results<WeatherData>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setupTableView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        promptZipcode()
    }
    
    func promptZipcode() {
        if isFirstLaunch {
            let group = DispatchGroup()
            let alert = UIAlertController(title: "Enter zip code", message: nil, preferredStyle: .alert)
            
            alert.addTextField { (textField) in
                textField.placeholder = "94108"
                textField.keyboardType = .numberPad
            }
            group.enter()
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                guard let textFieldText = alert?.textFields?[0].text else { return }
                print("our text",textFieldText)
                self.fetchData(textFieldInput: textFieldText, firstLaunch: true)
//                if textFieldText == "" {
//                    print("ERR: Text field empty!")
//                } else {
//                    DispatchQueue.main.async {
//                        print("tf:",textFieldText)
//                        self.zipCode = textFieldText
//                        self.weatherDataObject.zipcode = textFieldText
//                        group.leave()
//                    }
//                    self.fetchData()
//                }
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("Not first time launching")
            let storedObjects = self.realm.objects(WeatherData.self)
            let storedZipcode = storedObjects[0].zipcode
            self.fetchData(textFieldInput: storedZipcode, firstLaunch: false)
        }
    }
    
    func fetchData(textFieldInput: String, firstLaunch: Bool) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?zip=\(textFieldInput),us&APPID=\(key)")!
        _ = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("omg something went wrong: \(err)")
            }
            guard let data = data else { return }
            guard let response = response else { return }
            let detailData = String(data: data, encoding: .utf8) as Any
            print("Data: \(detailData)")
            print("Response: \(response)")
            do { // parse the response into json
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.sync {
                    guard let currentWeather = weatherData.weather[0]?.description else { return }
                    guard let city = weatherData.name else { return }
                    print("Current Weather: \(currentWeather)")
                    print("City: \(city)")
                    self.cityName = city
                    self.currentWeatherType = currentWeather
                    self.weatherDataObject.zipcode = textFieldInput
                    self.weatherDataObject.cityName = city
                    self.weatherDataObject.weatherType = currentWeather
                    let storedObjects = self.realm.objects(WeatherData.self)
                    
                    if firstLaunch == true {
                        try! self.realm.write {
                            self.realm.add(self.weatherDataObject)
                            print("Stored weather object: ", storedObjects as Any)
                        }
                        let storedWeatherData = storedObjects[0]
                        self.cityName = storedWeatherData.cityName
                    }
                    self.title = self.cityName
                }
            } catch let jsonError {
                print("Something went wrong while fetching json: \(jsonError.localizedDescription)")
            }
        }.resume()
    }
    
    @objc func addButtonDidClick() {
        let weatherDataRealObjects = self.realm.objects(WeatherData.self)
        //1. Create the alert controller.
        let alert = UIAlertController(title: "The weather today is \(weatherDataRealObjects[0].weatherType)!", message: "How are you feeling today?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Example: Really Happy"
            textField.keyboardType = .numberPad
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            self.userFeeling = textField!.text
            print("Text field: \(self.userFeeling ?? "nil")")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.frame = self.view.frame
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return items.count
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
//        let item = items[indexPath.row]
        cell.textLabel?.text = "ok"
        return cell
    }
    
    

    
}


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
    var weatherType: String?
    var cityName: String?
    var userFeeling: String?
    let isFirstLaunch = UserDefaults.isFirstLaunch()
    let tableView = UITableView()
    let cellId = "cellId"
    let items = [Item]?.self
    let weatherDataObject = WeatherData()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        setupTableView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidClick))
        let weatherDataRealObjects = realm.objects(WeatherData.self)
        print("Realm WeatherData objects: \(weatherDataRealObjects)")
        self.title = weatherDataRealObjects[0].cityName
    }
    
    @objc func addButtonDidClick() {
        print(123)
        //1. Create the alert controller.
        let alert = UIAlertController(title: "The weather today is \(weatherType!)!", message: "How are you feeling today?", preferredStyle: .alert)
        
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
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        promptZipcode()
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
    
    func promptZipcode() {
        if isFirstLaunch {
            print("This is the first launch")
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Enter zip code", message: nil, preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.placeholder = "94108"
                textField.keyboardType = .numberPad
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                self.zipCode = textField!.text
                self.weatherDataObject.zipcode = textField!.text!
                self.fetchData()
            }))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("Not first time launching")
        }
    }

    func fetchData() {
        // 1 - make a request with URLSession
        
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?zip=\(self.zipCode!),us&APPID=\(key)")!
        _ = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let err = error {
                print("omg something went wrong: \(err)")
            }
            guard let data = data else { return }
//            print(String(data: data, encoding: .utf8))
//            print("That data: \(data)")
            print("Response: \(response!)")
            
            // 2 - parse the response (json)
            do {
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                DispatchQueue.main.sync {
                    let currentWeather = weatherData.weather[0]?.description
                    let city = weatherData.name
                    self.cityName = city
                    self.weatherType = currentWeather
                    
                    self.weatherDataObject.cityName = city!
                    // store the zipcode
                    try! self.realm.write {
                        self.realm.add(self.weatherDataObject)
                    }
                    if let weatherType = self.weatherType {
                        print("Weather Type: \(weatherType)")
                    } else {
                        print("something went wrong")
                    }
                }
            } catch let jsonError {
                print("something went wrong while fetching json: \(jsonError.localizedDescription)")
            }
        }.resume()
    }
}


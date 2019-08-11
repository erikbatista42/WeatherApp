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
//    let userLogs = [WeatherItem]?.self
//    var items = LogsInventory()
//    var userLogs = List<WeatherLog>()
    var logList = List<WeatherLogItem>()
    var logsInventory = LogsInventory()
    
    let weatherDataObject = WeatherItemData()
    var storedWeatherDataObject: Results<WeatherItemData>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.logList = self.logList.realm.
        let storedLogObjects = self.realm.objects(WeatherLogItem.self)
        print("intersting", storedLogObjects)
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
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                guard let textFieldText = alert?.textFields?[0].text else { return }
                self.fetchData(textFieldInput: textFieldText, firstLaunch: true)
                //TODO: error handling when user inputs non existing zipcode/ empty textfield
            }))
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            print("Not first time launching")
            let storedObjects = self.realm.objects(WeatherItemData.self)
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
                    let storedObjects = self.realm.objects(WeatherItemData.self)
                    
                    
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
        let storedWeatherObject = self.realm.objects(WeatherItemData.self)
        //1. Create the alert controller.
        let alert = UIAlertController(title: "The weather today is \(storedWeatherObject[0].weatherType)!", message: "How are you feeling today?", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Example: Relaxed"
        }
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textFieldText = alert?.textFields![0].text // Force unwrapping because we know it exists.

            let date = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            let result = formatter.string(from: date)
            
            let item = WeatherLogItem()
            let logText = "\(result) - Feeling \(textFieldText ?? "") | \(storedWeatherObject[0].weatherType)."
            item.userLog = logText
            
            try! self.realm.write {
                self.logList.append(item)
                self.realm.add(self.logList, update: true)
            }
            self.tableView.reloadData()
            print("list: \(self.logList.isEmpty)")
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
        let storedLogObjects = self.realm.objects(WeatherLogItem.self)
        return storedLogObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let storedLogObjects = self.realm.objects(WeatherLogItem.self)[indexPath.row]
        cell.textLabel?.text = storedLogObjects.userLog
        return cell
    }
    
    

    
}


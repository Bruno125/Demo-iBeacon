//
//  ListViewController.swift
//  iBeacons
//
//  Created by developer on 10/7/16.
//  Copyright © 2016 developer. All rights reserved.
//

import UIKit

let cellIdentifier = "messageCell"

class ListViewController: UITableViewController {
    
    var beacons = [OwnBeacon]()
    var beaconsToSend: OwnBeacon? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.loadData()
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
        self.title = "iBeacons"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add iBeacon", style: .plain, target: self, action: #selector(createBeacon))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numbersOfBeacons = self.beacons.count
        return numbersOfBeacons
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        let entry = self.beacons[indexPath.row]
        
        cell.textLabel?.text = entry.name
        
        return cell
    }
    
    func createBeacon() {
        let alert = UIAlertController(title: "Add a name!!!", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
            textField.placeholder = "Name"
        })
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = ""
            textField.placeholder = "UUID"
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let name = alert.textFields![0] as UITextField
            let uuid = alert.textFields![1] as UITextField
            
            let beacon = OwnBeacon(uuid: uuid.text!, name: name.text!)
            
            self.beacons.append(beacon)
            self.saveData()
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.beaconsToSend = self.beacons[indexPath.row]
        self.performSegue(withIdentifier: "ownBeaconDetail", sender: self)
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ownBeaconDetail" {
            if self.beaconsToSend == nil {
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ownBeaconDetail" {
            let viewController: DetailViewController = segue.destination as! DetailViewController
            viewController.beacon = self.beaconsToSend
        }
    }

    func saveData() {
        let placesData = NSKeyedArchiver.archivedData(withRootObject: self.beacons)
        UserDefaults.standard.set(placesData, forKey: "mybeacons")
    }
    
    func loadData(){
        let data = UserDefaults.standard.object(forKey: "mybeacons") as? NSData
        
        if let arreglo = data {
            let beaconsArray = NSKeyedUnarchiver.unarchiveObject(with: arreglo as Data) as? [OwnBeacon]
            
            if let beaconsArray = beaconsArray {
                self.beacons = beaconsArray
            }
        }
    }
}

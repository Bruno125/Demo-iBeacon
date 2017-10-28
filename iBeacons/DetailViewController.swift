//
//  DetailViewController.swift
//  iBeacons
//
//  Created by developer on 10/7/16.
//  Copyright © 2016 developer. All rights reserved.
//

import UIKit
import CoreLocation

class DetailViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var lastProximity: CLProximity?
    
    var beacon: OwnBeacon? = nil
    
    @IBOutlet weak var lblBeacon: UILabel!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblUbicacion: UILabel!
    
    @IBOutlet weak var lblMajor: UILabel!
    
    @IBOutlet weak var lblMinor: UILabel!
    
    @IBOutlet weak var lblPresicion: UILabel!
    
    @IBOutlet weak var lblRssi: UILabel!
    
    @IBOutlet weak var btnBeacon: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.lblName.text = beacon!.name
        self.lblBeacon.text = beacon!.uuid
    }
    
    func initBeacon() {
        let uuid = beacon!.uuid
        let regionIdentifier = "pe.edu.upc"
        let uuidBeacon: UUID = UUID(uuidString: uuid)!
        
        let beaconRegion: CLBeaconRegion = CLBeaconRegion(proximityUUID: uuidBeacon, identifier: regionIdentifier)
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyOnEntry = true
        
        locationManager = CLLocationManager()
        
        locationManager!.requestAlwaysAuthorization()
        
        locationManager!.delegate = self
        
        locationManager!.pausesLocationUpdatesAutomatically = false
        
        locationManager!.startMonitoring(for: beaconRegion)
        
        locationManager!.startRangingBeacons(in: beaconRegion)
        
        locationManager!.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startStopBeacon(_ sender: UIButton) {
        if self.btnBeacon.titleLabel?.text == "Found it!!!" {
            initBeacon()
            self.btnBeacon.setTitle("Stop", for: .normal)
        } else {
            self.locationManager = nil
            self.btnBeacon.setTitle("Found it!!!", for: .normal)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        print(beacons.count)
        
        for item in beacons {
         
         lblMinor.text = String(describing: item.minor)
         lblMajor.text = String(describing: item.major)
         lblRssi.text = String(item.rssi)
         lblPresicion.text = String(item.accuracy)
         
         switch item.proximity {
            case CLProximity.unknown:
                lblUbicacion.text = "Unknown"
                break
            case CLProximity.far:
                lblUbicacion.text = "Far"
                break
            case CLProximity.near:
                lblUbicacion.text = "Near"
                break
            case CLProximity.immediate:
                lblUbicacion.text = "Immediate"
                break
            }
         }
    }
    
}

//
//  OwnBeacon.swift
//  iBeacons
//
//  Created by developer on 10/7/16.
//  Copyright © 2016 developer. All rights reserved.
//

import Foundation

class OwnBeacon: NSObject, NSCoding {

    var uuid: String = ""
    var name: String = ""
    
    init(uuid: String, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    convenience required init?(coder aDecoder: NSCoder) {
        guard
            let uuid = aDecoder.decodeObject(forKey: "uuid") as? String,
            let name    = aDecoder.decodeObject(forKey: "name") as? String
            else {
                return nil
        }
        self.init(uuid: uuid, name: name)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(name, forKey: "name")
    }
}

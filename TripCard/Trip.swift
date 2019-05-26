//
//  File.swift
//  TripCard
//
//  Created by Makan fofana on 5/24/19.
//  Copyright © 2019 MakanFofana. All rights reserved.
//


import UIKit
import Parse


struct Trip {
    var tripId = ""
    var city = ""
    var country = ""
    var featuredImage: PFFile? //UIImage?
    var price: Int = 0
    var totalDays: Int = 0
    var isLiked: Bool = false
    
    init(tripId: String, city: String, country: String, featuredImage: PFFile!, price: Int, totalDays: Int , isLiked: Bool) {
        self.tripId = tripId
        self.city = city
        self.country = country
        self.featuredImage = featuredImage
        self.price = price
        self.totalDays = totalDays
        self.isLiked = isLiked
    }
    
    //Creating the initalizing parse object template
    init(pfObject: PFObject) {
        self.tripId = pfObject.objectId!
        self.city = pfObject["city"] as! String
        self.country = pfObject["country"] as! String
        self.featuredImage = pfObject["featuredImage"] as? PFFile
        self.price = pfObject["price"] as! Int
        self.totalDays = pfObject["city"] as! Int
        self.isLiked = pfObject["isLiked"] as! Bool
    }
    
    func toPFObject() -> PFObject {
        let tripObject = PFObject(className: "Trip")
        tripObject.objectId = tripId
        tripObject["city"] = city
        tripObject["country"] = country
        tripObject["featuredImage"] = featuredImage
        tripObject["price"] = price
        tripObject["totalDays"] = totalDays
        tripObject["isLiked"] = isLiked
        
        return tripObject
    }
}

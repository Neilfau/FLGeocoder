//
//  ViewController.swift
//  FLGeoderExample
//
//  Created by Neil Faulkner on 08/11/2017.
//  Copyright © 2017 Faulkner Labs. All rights reserved.
//

import UIKit
import CoreLocation
import FLGeocoder

class ViewController: UIViewController {

    var geocoder = FLGeocoder.shared
    var allLocations: [CLLocation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Test Locations
        let testLocation1 = CLLocation(latitude: 50.148746, longitude: 8.657227) //Frankfurt
        let testLocation2 = CLLocation(latitude: 59.933000, longitude: 10.898438) //Oslo
        let testLocation3 = CLLocation(latitude: 39.825413, longitude: -104.985352) //Denver
        let testLocation4 = CLLocation(latitude: -20.107523, longitude: 28.630371) //Bulawayo
        
        //Add To An Array
        allLocations = [testLocation1, testLocation2, testLocation3, testLocation4]
        
        //Batch Reverse Geocode
        performBatchReverseGeocode()
        
        //Single Reverse Geocode
        performReverseGeocode()
        
        //Offline Reverse Geocode
        performOfflineReverseGeocode()
        
        //Forward Geocoding
        performForwardGeocoding()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func performBatchReverseGeocode(){
        
        geocoder.geocodeInterval = 0.5
        
        geocoder.batchReverseGeocode(locations: allLocations) { (results, failed, errors) in
         
            //Perform error handling & handle results data
            
            print("\n[ONLINE] Batch Reverse Geocode Results:")
            print("Sucessful: \(results.count)")
            print("Errors: \(errors.count)")
            print("Failed Locations: \(failed.count)\n")
            
             for placemark in results{
                print("City: \(placemark.locality ?? "N/A")")
                print("Region: \(placemark.administrativeArea ?? "N/A")")
                print("Country: \(placemark.country ?? "N/A")")
                print("Country Code: \(placemark.isoCountryCode ?? "N/A") \n")
             }
         
        }
      
    }
    
    func performReverseGeocode(){
        
        let testLocation = CLLocation(latitude: 50.148746, longitude: 8.657227) //Frankfurt
        
        geocoder.reverserGeocode(location: testLocation) { (result, error) in
            
            //Perform error handling & handle results data
            
            if let error = error{
                print("Error Geocoding: \(error)")
            }
            
            guard let placemark = result else{
                return
            }
            
            print("\n[ONLINE] Reverse Geocode Result:")
            print("City: \(placemark.locality ?? "N/A")")
            print("Region: \(placemark.administrativeArea ?? "N/A")")
            print("Country: \(placemark.country ?? "N/A")")
            print("Country Code: \(placemark.isoCountryCode ?? "N/A") \n")
            
        }
        
    }
    
    func performOfflineReverseGeocode(){
        
        let testLocation = CLLocation(latitude: 39.825413, longitude: -104.985352) //Denver
        
        if let countryName = geocoder.fetchCountryOfflineFor(location: testLocation, format: .Name){
            //Handle results data
            print("[Offline] Country Name: \(countryName)\n")
        }
        
    }
    
    func performForwardGeocoding(){
        
        let address = "55 Oxford Street, London, United Kingdom"
        
        geocoder.forwardGeocode(address: address) { (result, error) in
            
            //Perform error handling & handle results data
            
            if let error = error{
                print("Error Geocoding: \(error)")
            }
            
            guard let placemark = result else{
                return
            }
            
            print("\n[ONLINE] Forward Geocode Result:")
            print("Coordinates Lat:\(placemark.location?.coordinate.latitude ?? 0.0) Lng:\(placemark.location?.coordinate.longitude ?? 0.0)")
            print("City: \(placemark.locality ?? "N/A")")
            print("Region: \(placemark.administrativeArea ?? "N/A")")
            print("Country: \(placemark.country ?? "N/A")")
            print("Country Code: \(placemark.isoCountryCode ?? "N/A") \n")
            
        }
        
    }


}


//
//  FLGeocoder.swift
//  Rove
//
//  Created by Neil Faulkner on 01/11/2017.
//  Copyright © 2017 Faulkner Labs. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit

public class FLGeocoder: NSObject{
    
    //Singleton
    public static let shared = FLGeocoder()
    
    //This sets the interval between each reverse geocode, if the interval is too small it can lead to the geocoder  producing an error because Apple limit the amount of requests to their servers. Default is 1.0 second.
    public var geocodeInterval = 1.0
    
    private var geodata: [[String: Any]]!
    
    public override init() {
        
        //Load JSON country data when FLGecoder is initialised
        do {
            //Load bundle from class
            let frameworkBundle = Bundle(for: FLGeocoder.self)
           
            //Load JSON file from correct bundle
            if let file = frameworkBundle.url(forResource: "country_data", withExtension: "json") {
                let data = try Data(contentsOf: file)
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let object = json as? [[String: Any]] {
                    geodata = object
                } else {
                    print("JSON is corrupted")
                }
            } else {
                print("No Country Data File Found")
            }
        } catch {
            print(error.localizedDescription)
        }
    
    }
    
    
    public func reverserGeocode(location: CLLocation, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> Void){
        //Init geocoder then reverser geocode coordinates, use completion handle to pass back results.
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (results, error) in
            
            //Check there is a placemark or return
            guard let placemark = results?.first else{
                completion(nil, error)
                return
            }
    
            //Completion handler with results
            completion(placemark, nil)
        }
    }
    
   public func forwardGeocode(address: String, completion: @escaping (_ placemark: CLPlacemark?, _ error: Error?) -> Void){
        
        //Init geocoder then turn an address into a placemark, use completion handle to pass back results.
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (results, error) in
            
            //Check there is a placemark or return
            guard let placemark = results?.first else{
                completion(nil, error)
                return
            }
            
            //Completion handler with results
            completion(placemark, nil)
         
        }
    }
    
    public func batchReverseGeocode(locations: [CLLocation], completion: @escaping (_ placemarks: [CLPlacemark], _ failedLocations:[CLLocation], _ errors: [Error]) -> Void){
        
        //Add to background thread
        DispatchQueue.global(qos: .userInteractive).async {
        
            //Create a queue for each reverse geocode to be added to.
            let operationQueue = OperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            
            //Setup arrays to contain results and init geocoder object
            var allPlacemarks: [CLPlacemark] = []
            var failedLocations: [CLLocation] = []
            var errors: [Error] = []
            let geocoder = CLGeocoder()
            let tasks = locations.count
            var count = 0
            
            //Loop through the locations
            for location in locations{
                
                //Create a new operation for the operations queue
                let blockOperation = BlockOperation(block: {
                    //Create semaphore to control each operation
                    let semaphore = DispatchSemaphore(value: 0)
                    
                        //Reverse geocode location
                        geocoder.reverseGeocodeLocation(location, completionHandler: { (result, error) in
                            
                            //Set the interval between each reverse geocode
                            var interval = self.geocodeInterval
                            
                            //Add any errors to error array & failed locations
                            if error != nil{
                                print("Error: \(error!.localizedDescription)")
                                interval += 2.0
                                errors.append(error!)
                                failedLocations.append(location)
                            }
                            
                            //Add placemark to results array
                            if let placemark = result?.first{
                                allPlacemarks.append(placemark)
                            }
                           
                            //Add Failed locations to failed array
                            else{
                                failedLocations.append(location)
                            }
                            
                            //Timer to signal next loop iliteration using the semaphore
                            Timer.scheduledTimer(withTimeInterval: interval, repeats: false){ timer in
                                semaphore.signal()
                            }
                            
                        })
                    
                        //Pause operation to allow interval between each reverse geocode
                        semaphore.wait()
                })
                
                //Increment count & add operation to queue
                count += 1
                operationQueue.addOperations([blockOperation], waitUntilFinished: true)
                
                //If all locations have been processed call completion block
                if count == tasks{
                    //Completion handler with results
                    completion(allPlacemarks, failedLocations, errors)
                }
            }
            
        }
    }
}


extension FLGeocoder{
    
    //Offline Geocoding
    
    public enum FLCountryCodeFormat: String{
        case ISOA2 = "iso_a2"
        case ISOA3 = "iso_a3"
        case Name = "name"
    }
    
    public func fetchCountryOfflineFor(location: CLLocation, format: FLCountryCodeFormat) -> String?{
        //Loop through JSON country data
        for country in geodata{
            
            if let geometry = country["geometry"] as? [String:Any]{
                
                let type = geometry["type"] as? String
                
                //Check if its a single polygone or multiple polygons
                if type == "Polygon"{
                    
                    //Check if location is contained within the shape
                    let polygon = geometry["coordinates"] as! [[[Double]]]
                    let match = self.isPointInPolygon(location: location, polygon: polygon[0])
                    if match{
                        //If polygon contains location then return string in selected format
                        if let result = country[format.rawValue] as? String{
                            return result
                        }
                    }
                }
                
                else if type == "MultiPolygon"{
                    
                    let multiPolygon = geometry["coordinates"] as! [[[[Double]]]]
                    
                    //Loop through each of the polygons & check if location is contained within the shape
                    for polygon in multiPolygon{
                        
                        let match = self.isPointInPolygon(location: location, polygon: polygon[0])
                        if match{
                            //If polygon contains location then return string in selected format
                            if let result = country[format.rawValue] as? String{
                                return result
                            }
                        }
                        
                    }
                    
                }
                
            }
        }
    
        return nil
    }
    
    
private func isPointInPolygon(location: CLLocation, polygon: [[Double]]) -> Bool{
        
    var polyCoordinates: [CLLocationCoordinate2D] = []
    
        //Convert points too coordinates
        for object in polygon{
            let longitude = object[0]
            let latiude = object[1]
            let coordinate = CLLocationCoordinate2DMake(latiude, longitude)
            polyCoordinates.append(coordinate)
        }
    
        //Create polygon from array of coordinates
        let poly = MKPolygon(coordinates: polyCoordinates, count: polyCoordinates.count)
    
        //Use contains extension to check if location is inside polygone
        return poly.contains(coordinates: location.coordinate)
    }
    
}

extension MKPolygon {
    
    //Convert coordinates to mappoint and check if polygon contains point
     func contains(coordinates: CLLocationCoordinate2D) -> Bool {
        let polygonRenderer = MKPolygonRenderer(polygon: self)
        let currentMapPoint: MKMapPoint = MKMapPointForCoordinate(coordinates)
        let polygonViewPoint: CGPoint = polygonRenderer.point(for: currentMapPoint)
        return polygonRenderer.path.contains(polygonViewPoint)
    }
}

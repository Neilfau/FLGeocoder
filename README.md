# FLGeocoder
[![Version](https://img.shields.io/cocoapods/v/FLGeocoder.svg?style=flat)](http://cocoapods.org/pods/FLGeocoder)
[![Platform](https://img.shields.io/cocoapods/p/FLGeocoder.svg?style=flat)](http://cocoapods.org/pods/FLGeocoder)
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift-4.0-4BC51D.svg?style=flat" alt="Language: Swift" /></a>
[![License](https://img.shields.io/cocoapods/l/FLGeocoder.svg?style=flat)](http://cocoapods.org/pods/FLGeocoder)

FLGeocoder is an easy to use geocoder for iOS that can perform simple offline reverse geocoding as well as batch online reverse geocoding.

### Requirements
 - iOS 11.0+
 - Xcode 9.0+

### Installation

FLGeocoder is available through Cocoapods. To install it, simply add the following line to your Podfile:
```sh
pod 'FLGeocoder'
```

### How To Use

#### Offline Reverse Geocoding

If you only need to find out which country a set of coordinates is in, you can perform an offline reverse geocode by doing the following:

```sh
    var geocoder = FLGeocoder.shared
    let testLocation = CLLocation(latitude: 39.825413, longitude: -104.985352) //Denver
        
    if let countryName = geocoder.fetchCountryOfflineFor(location: testLocation, format: .Name){
        //Handle results data
        print("[Offline] Country Name: \(countryName)\n")
    }     
```

You can also specify the return format:

Name of the country eg; Australia
```sh
.Name
```

Country code return in the ISOA2 format eg; AU
```sh
.ISOA2
```

Country code return in the ISOA3 format eg; AUS
```sh
.ISOA3
```

#### Batch Reverse Geocoding

If you need to reverse geocode a large number of coordinates you can simply do the following:

```sh
  //Initialise FLGeocoder
  var geocoder = FLGeocoder.shared
  
  // Test Locations
  let testLocation1 = CLLocation(latitude: 50.148746, longitude: 8.657227) //Frankfurt
  let testLocation2 = CLLocation(latitude: 59.933000, longitude: 10.898438) //Oslo
  let testLocation3 = CLLocation(latitude: 39.825413, longitude: -104.985352) //Denver
  let testLocation4 = CLLocation(latitude: -20.107523, longitude: 28.630371) //Bulawayo
        
  //Add To An Array
  allLocations = [testLocation1, testLocation2, testLocation3, testLocation4]

  //The interval between each geocode
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
```

You can adjust the speed of the batch reverse geocoding by setting:

```sh
.geocodeInterval = 1.5
```

If you to do many requests too quickly you will get an error as Apple restrict the amount of requests you can perform. We recommend keeping this interval at least 1.0 seconds, but if your are only performing a small amount of reverse geocoding requests then you can reduce this. 

#### Reverse Geocoding

You can also perform normal single reverse geocoding similar to apples own CLGeocoder:
```sh
  //Initialise FLGeocoder
  var geocoder = FLGeocoder.shared
  
  //Location
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
```

#### Forward Geocoding

You can also perform forward geocoding, just provide an address as a string:
```sh

  //Initialise FLGeocoder
  var geocoder = FLGeocoder.shared
  
  //Address String
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

```


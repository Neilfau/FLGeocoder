Pod::Spec.new do |s|

  s.name         = "FLGeocoder"
  s.version      = "1.0.2"
  s.summary      = "Offline Geocoder & Online Batch Geocoder."
  s.description  = "FLGeocoder allows you to perform basic geocoding offline & to perform batch geocoding online using Apples geocoder class."
  s.homepage     = "http://www.faulknerlabs.io"
  s.license      = "Apache License, Version 2.0"
  s.author             = { "Neil Faulkner" => "info@faulknerlabs.io" }
  s.social_media_url   = "http://twitter.com/Neilfau"
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/Neilfau/FLGeocoder.git", :tag => "#{s.version}" }
  s.source_files  = "FLGeocoder", "FLGeocoder/**/*.{h,m,swift}"
  s.resources  = "FLGeocoder/*.json"
 
end

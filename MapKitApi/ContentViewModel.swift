//
//  ContentViewModel.swift
//  MapKitDemo
//
//  Created by 羅子淵 on 2024/7/16.
//

import MapKit

enum MapDetails{
    static let startinglocation = CLLocationCoordinate2D(latitude: 25.034180117331413, longitude: 121.56449598068548)
}

final class ContentViewModel :NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var  region = MKCoordinateRegion(center:MapDetails.startinglocation, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    var locationManager:CLLocationManager?
    
    func checkIfLocationServiceIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.delegate = self
        }else{
            print("turn it on")
        }
    }
    
    private  func checkLocationAuthorization(){
        guard let locationManager = locationManager else{return}
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted")
        case .denied:
            print("Your location is denied")
            
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate,span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

//
//  MapVC.swift
//  Incidencias
//
//  Created by Sebastian TC on 10/19/15.
//  Copyright © 2015 PICIE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    // MARK: - IBOUtlets
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - Variables
    var locationManager: CLLocationManager!
    var reports = [Reporte]()
    
    // MARK: Variables of Model
    var managedObjectContext: NSManagedObjectContext!
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Init Location Manager and map
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        
        // Get Core Data Manager Context
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Get Reports
        getReports()
        
        // Add Annotation in Map
        addAnnotationInMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Start Location if service is Enable and if we can Autorized
        whenStartSetAndGetUserLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Private Methods
    
    fileprivate func getReports(){
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reporte");
        do{
            let objects = try managedObjectContext.fetch(fetchRequest) as! [Reporte]
            reports = objects
        } catch {
            print("Fetch failed in Reort, with error: \(error)")
        }
    }
    
    fileprivate func addAnnotationInMap(){
        if !reports.isEmpty{
            for report in reports{
                
                let annnotation = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: (report.latitud?.doubleValue)!, longitude: (report.longitud?.doubleValue)!)
                let descripcion = report.descripcion!

                annnotation.title = descripcion
                annnotation.coordinate = coordinate
                
                mapView.addAnnotation(annnotation)
            }
        }
    }
    
    fileprivate func showAlertToEnableServiceLocation(){
        
        let message = "Ve a Configuraciones > Privacidad > Y habilitar Localización"
        let alert = UIAlertController(title: "Localización inactiva", message: message, preferredStyle: .alert)
        let actionSettings = UIAlertAction(title: "Config.", style: .default) { (actionSettings) -> Void in
            UIApplication.shared.openURL(URL(string:UIApplicationOpenSettingsURLString)!)
        }
        let actionCancel = UIAlertAction(title: "Cancelar", style: .default) { (actionCancel) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(actionSettings)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func whenStartSetAndGetUserLocation(){
        
        if CLLocationManager.locationServicesEnabled() {
            let status = CLLocationManager.authorizationStatus()
            if status != CLAuthorizationStatus.denied {
                
                if status == .authorizedWhenInUse {
                    locationManager.startUpdatingLocation()
                }
                else if status == .notDetermined {
                    print("LOCATION IS NOT DETERMINED")
                    locationManager.requestWhenInUseAuthorization()
                }
            }
            else{
                print("LOCATION IS NOT AUTHORIZATION")
                showAlertToEnableServiceLocation()
            }
        }
        else{
            print("LOCATION SERVICE IS DISABLE")
            // Automaticamente muestra
            showAlertToEnableServiceLocation()
        }
    }

    
    //MARK: - Location Delegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location Manager - DidUpdateLocations:")
        
        if let location = locations.last{
            print("value: " + location.description)
            
            // Set Region
            let center = CLLocationCoordinate2D(latitude: locations.last!.coordinate.latitude, longitude: locations.last!.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) )
            mapView.setRegion(region, animated: true)
            
            // Stop Updating Location
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //print("Location Manager - DidChangeAuthorizationStatus: \(status.rawValue)")
        
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Faild With Error: " + error.localizedDescription)
    }
    
    
}

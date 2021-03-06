//
//  MapViewController.swift
//  PeoplemonSKC
//
//  Created by Sean Crowl on 11/7/16.
//  Copyright © 2016 Interapt. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    var updatingLocation = true
    let latitudeDelta = 0.0025
    let longitudeDelta = 0.0025
    
    var annotations: [MapPin] = []
    var overlay: MKOverlay?
    var firstLocation = true
    
    var timer: Timer?
    
    var nearbyView: UIView!
    var nearbyCollectionView: UICollectionView!
    var nearbyPeoplemon: [Person] = []
    var userOverlay: MKOverlay?
    
    var personOverlay: MKOverlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        mapView.showsUserLocation = true
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = false
        locationManager.startUpdatingLocation()
        
        mapView.delegate = self
        
        UserStore.shared.delegate = self
        
        showNearby()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !WebServices.shared.userAuthTokenExists() || WebServices.shared.userAuthTokenExpired() {
            performSegue(withIdentifier: "PresentLoginNoAnimation", sender: self)
        } else {
            let infoUser = User()
            WebServices.shared.getObject(infoUser, completion: { (user, error) in
                if let user = user {
                    UserStore.shared.user = user
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        stopTimer()
    }
    
    func loadMap() {
        if let coordinate = locationManager.location?.coordinate {
            let checkIn = Person(coordinate: coordinate)
            WebServices.shared.postObject(checkIn, completion: { (object, error) in
                
            })
        }
        
        let nearby = Person(radiusInMeters: Double(Constants.radiusInMeters))
        WebServices.shared.getObjects(nearby) { (objects, error) in
            if let objects = objects {
                let oldAnnotations = self.annotations
                self.annotations = []
                for person in objects {
                    let pin = MapPin(person: person)
                    self.annotations.append(pin)
                }
                self.mapView.addAnnotations(self.annotations)
                self.mapView.removeAnnotations(oldAnnotations)
            }
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(loadMap), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    
    // MARK: - IBActions
    @IBAction func logoutClicked(sender: AnyObject) {
        UserStore.shared.logout {
            self.performSegue(withIdentifier: "PresentLogin", sender: self)
        }
    }
    
    @IBAction func showNearbyClicked(_ sender: Any) {
        let person = Person(radiusInMeters: Double(Constants.nearbyRadius))
        WebServices.shared.getObjects(person) { (objects, error) in
            if let objects = objects {
                self.nearbyPeoplemon = objects
                for person in objects {
                    if let latitude = person.latitude, let longitude = person.longitude {
                        person.distance = self.locationManager.location?.distance(from: CLLocation(latitude: latitude, longitude: longitude))
                    }
                }
                self.nearbyPeoplemon = objects.sorted(by: { (person1, person2) -> Bool in
                    switch (person1.distance, person2.distance) {
                    case let (distance1?, distance2?):
                        return distance1 < distance2
                    case (nil, _?):
                        return true
                    default:
                        return false
                    }
                })
                self.nearbyCollectionView.reloadData()
            }
        }
        UIView.animate(withDuration: 0.8, animations: {
            self.nearbyView.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
    
    @IBAction func closeNearby(_ sender: Any) {
        UIView.animate(withDuration: 0.8, animations: {
            self.nearbyView.transform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
        }, completion: nil)
}

// MARK: - Nearby stuff
func showNearby() {
    let bounds = UIScreen.main.bounds
    let width: CGFloat = 196
    let height: CGFloat = 240
    
    nearbyView = UIView(frame: CGRect(x: (bounds.width - width) / 2.0, y: (bounds.height - height) / 2.0, width: width, height: height))
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 60, height: 60)
    layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    layout.minimumLineSpacing = 0
    layout.minimumInteritemSpacing = 0
    nearbyCollectionView = UICollectionView(frame: CGRect(x: 8, y: 8, width: 180, height: 180), collectionViewLayout: layout)
    nearbyCollectionView.dataSource = self
    nearbyCollectionView.delegate = self
    nearbyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
    nearbyCollectionView.isScrollEnabled = false
    nearbyView.addSubview(nearbyCollectionView)
    nearbyView.backgroundColor = UIColor.white
    nearbyCollectionView.backgroundColor = UIColor.clear
    self.view.addSubview(nearbyView)
    
    let translateTransform = CGAffineTransform(translationX: 0, y: bounds.height)
    nearbyView.transform = translateTransform
}
    
    func removePersonOverlay() {
        if let personOverlay = personOverlay {
            mapView.remove(personOverlay)
            self.personOverlay = nil
        }
    }

}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(latitudeDelta, longitudeDelta))
        mapView.setRegion(region, animated: true)
        updatingLocation = true
        
        if let userOverlay = userOverlay {
            mapView.remove(userOverlay)
        }
        userOverlay = MKCircle(center: center, radius: CLLocationDistance(Constants.radiusInMeters))
        mapView.add(userOverlay!)
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            let userPin = "userLocation"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: userPin)
            if pinView == nil {
                pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: userPin)
                pinView?.canShowCallout = false
            } else {
                pinView?.annotation = annotation
            }
            if let image = Utils.imageFromString(imageString: UserStore.shared.user?.avatar) {
                let resizedImage = Utils.resizeImage(image: image, maxSize: 26)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = 20
                pinView?.contentMode = .scaleAspectFill
                pinView?.clipsToBounds = true
                pinView?.layer.borderWidth = 4
                pinView?.layer.borderColor = UIColor(red: 255, green: 0, blue: 0, alpha: 1).cgColor
            } else {
                pinView?.image = nil
            }
            return pinView
        }
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = false
        } else {
            pinView?.annotation = annotation
        }
        
        if let mapPin = annotation as? MapPin {
            if let image = Utils.imageFromString(imageString: mapPin.person?.avatarBase64) {
                let resizedImage = Utils.resizeImage(image: image, maxSize: Constants.pinImageSize)
                pinView?.image = resizedImage
                pinView?.layer.cornerRadius = Constants.pinImageSize / 2.0
                pinView?.contentMode = .scaleAspectFill
                pinView?.clipsToBounds = true
            } else {
                pinView?.image = nil
            }
        }
    
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let mapPin = view.annotation as? MapPin, let person = mapPin.person, let name = person.userName, let userId = person.userId {
            let alert = UIAlertController(title: "Catch Peoplemon", message: "Do you with to catch \(name)?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Catch", style: .default, handler: { (action) in
                let catchPerson = Person(userId: userId, radiusInMeters: Double(Constants.radiusInMeters))
                WebServices.shared.postObject(catchPerson, completion: { (object, error) in
                    if let error = error {
                        self.present(Utils.createAlert(title: "Error", message: error), animated: true, completion: nil)
                    } else {
                        self.present(Utils.createAlert(title: "Caught!", message: "\(name) caught!"), animated: true, completion: nil)
                    }
                })
            }))
            alert.addAction(UIAlertAction(title: "Do Not Catch", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = MKCircleRenderer(overlay: overlay)
        if let userOverlay = userOverlay, userOverlay.coordinate.latitude == overlay.coordinate.latitude && userOverlay.coordinate.longitude == overlay.coordinate.longitude {
            circleOverlay.lineWidth = 1
            circleOverlay.strokeColor = UIColor.blue
            circleOverlay.fillColor = UIColor.blue.withAlphaComponent(0.5)
        } else {
            circleOverlay.lineWidth = 0
            circleOverlay.fillColor = UIColor.blue.withAlphaComponent(0.25)
        }
        return circleOverlay
    }
}

// MARK: - UserStoreDelegate
extension MapViewController: UserStoreDelegate {
    func userLoggedIn() {
        NotificationCenter.default.addObserver(self, selector: #selector(stopTimer), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(startTimer), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        stopTimer()
        startTimer()
    }
}

// MARK: - CollectionView
extension MapViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(nearbyPeoplemon.count, 9)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath)
        
        let person = nearbyPeoplemon[indexPath.row];
        let imageView = ImageSetup(frame: CGRect(x: 5, y: 5, width: 30, height: 30))
        imageView.contentMode = .scaleAspectFill
        imageView.image = Utils.imageFromString(imageString: person.avatarBase64)
        cell.addSubview(imageView)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = nearbyPeoplemon[indexPath.row]
        if let lat = person.latitude, let long = person.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            if let selectedOverlay = personOverlay {
                mapView.remove(selectedOverlay)
            }
            personOverlay = MKCircle(center: coordinate, radius: 50)
            mapView.add(personOverlay!)
            let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(removePersonOverlay), userInfo: nil, repeats: false)
            closeNearby(sender: self)
        }
    }
}

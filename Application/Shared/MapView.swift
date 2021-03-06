import MapKit

class MapView:MKMapView, MKMapViewDelegate, CLLocationManagerDelegate {
    let location = CLLocationManager()
    private var lastLocation:CLLocation?
    private var indicator = UIImageView(image:#imageLiteral(resourceName: "iconHeading.pdf"))
    
    init() {
        super.init(frame:.zero)
        translatesAutoresizingMaskIntoConstraints = false
        isRotateEnabled = false
        isPitchEnabled = false
        showsBuildings = true
        showsPointsOfInterest = true
        showsCompass = true
        showsScale = false
        showsTraffic = false
        showsUserLocation = true
        layer.cornerRadius = 20
        mapType = .standard
        delegate = self
        var region = MKCoordinateRegion()
        region.center = userLocation.coordinate
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        setRegion(region, animated:false)
        indicator.clipsToBounds = true
        indicator.contentMode = .center
        indicator.translatesAutoresizingMaskIntoConstraints = false
        location.delegate = self
        location.startUpdatingHeading()
        setUserTrackingMode(.followWithHeading, animated:true)
    }
    
    deinit {
        location.stopUpdatingHeading()
    }
    
    required init?(coder:NSCoder) { return nil }
    @objc func centreUser() { centre(coordinate:userLocation.coordinate) }
    func mapView(_:MKMapView, didSelect view:MKAnnotationView) { updateDistance(view:view) }
    
    func centre(coordinate:CLLocationCoordinate2D) {
        var region = MKCoordinateRegion()
        region.span = self.region.span
        region.center = coordinate
        setRegion(region, animated:true)
    }
    
    func updateDistance(view:MKAnnotationView) {
        guard
            let mark = view.annotation as? MKPointAnnotation,
            let distance = userLocation.location?.distance(from:CLLocation(latitude:mark.coordinate.latitude,
                                                                           longitude:mark.coordinate.longitude))
        else { return }
        if #available(iOS 10.0, *) {
            let formatter = MeasurementFormatter()
            formatter.unitStyle = .long
            formatter.unitOptions = .naturalScale
            formatter.numberFormatter.maximumFractionDigits = 1
            mark.subtitle = formatter.string(from:Measurement(value:distance, unit:UnitLength.meters)) as String
        }
    }
    
    func mapView(_:MKMapView, didUpdate location:MKUserLocation) {
        if let selected = selectedAnnotations.first as? MKPointAnnotation,
            let view = view(for:selected) {
            updateDistance(view:view)
        } else {
            updateUser(location:location)
        }
    }
    
    func mapView(_:MKMapView, viewFor annotation:MKAnnotation) -> MKAnnotationView? {
        guard let mark = annotation as? MKPointAnnotation else { return view(for:annotation) }
        var point:MKAnnotationView!
        if let reuse = dequeueReusableAnnotationView(withIdentifier:"mark") {
            reuse.annotation = mark
            point = reuse
        } else {
            if #available(iOS 11.0, *) {
                let marker = MKMarkerAnnotationView(annotation:mark, reuseIdentifier:"mark")
                marker.markerTintColor = .black
                marker.animatesWhenAdded = true
                point = marker
            } else {
                let marker = MKPinAnnotationView(annotation:mark, reuseIdentifier:"mark")
                marker.pinTintColor = .black
                marker.animatesDrop = true
                point = marker
            }
            point.canShowCallout = true
            point.leftCalloutAccessoryView = UIImageView(image:#imageLiteral(resourceName: "iconLocation.pdf"))
        }
        return point
    }
    
    func mapView(_:MKMapView, rendererFor overlay:MKOverlay) -> MKOverlayRenderer {
        if let tiler = overlay as? MKTileOverlay {
            return MKTileOverlayRenderer(tileOverlay:tiler)
        } else if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline:polyline)
            renderer.lineWidth = 3
            renderer.strokeColor = .black
            renderer.lineCap = .round
            return renderer
        } else {
            return MKOverlayRenderer()
        }
    }
    
    func mapView(_:MKMapView, didAdd views:[MKAnnotationView]) {
        if  let user = views.first(where: { view in view.annotation is MKUserLocation }) {
            user.addSubview(indicator)
            indicator.topAnchor.constraint(equalTo:user.topAnchor).isActive = true
            indicator.bottomAnchor.constraint(equalTo:user.bottomAnchor).isActive = true
            indicator.leftAnchor.constraint(equalTo:user.leftAnchor).isActive = true
            indicator.rightAnchor.constraint(equalTo:user.rightAnchor).isActive = true
        }
    }
    
    func locationManager(_:CLLocationManager, didUpdateHeading newHeading:CLHeading) {
        if newHeading.headingAccuracy > 0 {
            let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
            let transform = CGAffineTransform(rotationAngle:CGFloat((heading / 180) * Double.pi))
            UIView.animate(withDuration:0.3) { [weak self] in self?.indicator.transform = transform }
        }
    }
    
    private func updateUser(location:MKUserLocation) {
        if let lastLocation = self.lastLocation {
            if let newLocation = location.location,
                lastLocation.distance(from:newLocation) > 35 {
                self.lastLocation = newLocation
                centre(coordinate:newLocation.coordinate)
            }
        } else {
            self.lastLocation = location.location
            centre(coordinate:location.coordinate)
        }
    }
}

//
//  ViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/08.
//

import UIKit
import NMapsMap
import CoreLocation
import BLTNBoard
import Network

class MapViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var naverMapView: NMFNaverMapView!
    lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        return manager
    }()
    
    var boardManager: BLTNItemManager?
    
    // MARK: - Methods
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    
                }
            } else {
                DispatchQueue.main.async {
                    guard let mainVC = self?.storyboard?.instantiateViewController(withIdentifier: "MainViewController") else { return }
                    mainVC.modalPresentationStyle = .fullScreen
                    self?.present(mainVC, animated: true)
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    @objc func getMarker(noti: Notification) {
        guard let markers = noti.userInfo?["markers"] as? [NMFMarker] else { return }
        
        for i in 0..<markers.count {
            markers[i].touchHandler = { overlay in
                // 모달 열기
                if let marker = overlay as? NMFMarker {
                    guard let info = marker.userInfo["info"] as? Item else { return false }
                    
                    let pageItem = BLTNPageItem(title: info.mtlty)
                    // pageItem.image = UIImage(systemName: "checkmark.circle.fill")
                    pageItem.actionButtonTitle = "자세히"
                    pageItem.alternativeButtonTitle = info.frcsTelno == "044-000-0000" ? nil : info.frcsTelno
                    pageItem.descriptionText =  """
                                                \(info.roadNmAddr)
                                                
                                                운영시간(평일) 👉 \(info.wkdayOperBgngTm) ~ \(info.wkdayOperEndTm)
                                                
                                                관리기관 👉 \(info.mngInstNm)
                                                """
                    
                    pageItem.actionHandler = { pageItem in
                        self.didTapBoardContinue(item: info)
                    }
                    
                    pageItem.alternativeHandler = { pageItem in
                        self.didTapBoardSkip(tel: pageItem.alternativeButtonTitle ?? "")
                    }
                    
                    pageItem.dismissalHandler = { _ in
                        self.didTapDismiss()
                    }
                    
                    pageItem.appearance.titleFontSize = 24
                    pageItem.appearance.titleTextColor = .label
                    pageItem.appearance.descriptionFontSize = 16
                    pageItem.appearance.alternativeButtonTitleColor = .systemGreen
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tabBarController?.tabBar.isHidden = true
                    }, completion: nil)
                    
                    self.boardManager = BLTNItemManager(rootItem: pageItem)
                    self.boardManager?.backgroundColor = .tertiarySystemBackground
                    self.boardManager?.showBulletin(above: self)
                }
                
                return true
            }
            
            markers[i].mapView = naverMapView.mapView
        }
        
        spinner.stopAnimating()
    }
    
    func didTapBoardContinue(item: Item) {
        boardManager?.dismissBulletin()
        
        if let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "detailVC") as? DetailViewController {
            detailVC.item = item
            present(detailVC, animated: true)
        }
    }
    
    func didTapBoardSkip(tel: String) {
        if let url = NSURL(string: "tel://\(tel)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    func didTapDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBarController?.tabBar.isHidden = false
        }, completion: nil)
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitorNetwork()
        
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        locationManager.requestWhenInUseAuthorization()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getMarker(noti:)),
                                               name: .didGetMarkerDataNotification,
                                               object: nil)
        
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("위치 권한 허용")
            locationManager.startUpdatingLocation()
            guard let lat = locationManager.location?.coordinate.latitude else { return }
            guard let lng = locationManager.location?.coordinate.longitude else { return }
            
            // 지도 초기 설정
            naverMapView.showLocationButton = true
            naverMapView.mapView.touchDelegate = self
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: lat, lng: lng))
            naverMapView.mapView.moveCamera(cameraUpdate, completion: nil)
            naverMapView.mapView.positionMode = .direction
            
            // 마커 셋팅
            getMarkerData()
            
        case .restricted, .notDetermined:
            print("위치 권한 설정되지 않음")
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            print("위치 권한 거부")
            locationManager.requestWhenInUseAuthorization()
        default:
            print("위치 권한 default")
        }
    }
    
}

extension MapViewController: NMFMapViewTouchDelegate {
    
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print(#function)
    }
    
}

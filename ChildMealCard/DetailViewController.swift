//
//  DetailViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/08.
//

import UIKit
import Alamofire
import NMapsMap

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var nMapView: NMFMapView!
    @IBOutlet weak var storeNameLabel: UILabel!
    @IBOutlet weak var storeAddrLabel: UILabel!
    @IBOutlet weak var openHourButton: UIButton!
    @IBOutlet weak var openHourLabel: UILabel!
    @IBOutlet weak var manageInfoLabel: UILabel!
    
    var item: Item?
    var apiResponse: API?
    
    let animation: CATransition = {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.subtype = .fromTop
        animation.duration = 0.3
        
        return animation
    }()
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }
    
    // MARK: - Methods
    func setOpenHourButton() {
        guard let item = item else { return }
        
        let weekday = UIAction(title: "평일", state: .on) { action in
            self.openHourLabel.text = "👉 \(item.wkdayOperBgngTm) ~ \(item.wkdayOperEndTm)"
            self.openHourLabel.layer.add(self.animation, forKey: CATransitionType.fade.rawValue)
        }
        
        let weekend = UIAction(title: "토요일", state: .off) { action in
            self.openHourLabel.text = "👉 \(item.satOperBgngTm) ~ \(item.satOperEndTm)"
            self.openHourLabel.layer.add(self.animation, forKey: CATransitionType.fade.rawValue)
        }
        
        let holiday = UIAction(title: "공휴일", state: .off) { action in
            self.openHourLabel.text = "👉 \(item.hldyOperBgngTm) ~ \(item.hldyOperEndTm)"
            self.openHourLabel.layer.add(self.animation, forKey: CATransitionType.fade.rawValue)
        }
        
        openHourButton.translatesAutoresizingMaskIntoConstraints = false
        openHourButton.menu = UIMenu(title: "🕰",
                                     image: UIImage(systemName: "arrow.down.circle.fill"),
                                     identifier: nil,
                                     options: .singleSelection,
                                     children: [holiday, weekend, weekday])
        
        openHourButton.showsMenuAsPrimaryAction = true
        openHourButton.changesSelectionAsPrimaryAction = true
    }
    
    @IBAction func didTapCallButton(_ sender: UIButton) {
        guard let item = item else { return }

        if let url = NSURL(string: "tel://\(item.frcsTelno)"), UIApplication.shared.canOpenURL(url as URL) {
            UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func didTapOpenNaverMapButton(_ sender: UIButton) {
        guard let item = item else { return }

        var search = ""
        if let encodedString = (item.mtlty).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let queryURL = URL(string: encodedString)!
            search = "nmap://search?&query=\(queryURL)&appname=com.b33rmac.ChildMealCard"
        } else {
            search = "nmap://map?&appname=com.b33rmac.ChildMealCard"
        }
        
        let url = URL(string: search)!
        let appStoreUrl = URL(string: "http://itunes.apple.com/app/id311867728?mt=8")!
        
        print(UIApplication.shared.canOpenURL(url))
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreUrl)
        }
    }
    
    @IBAction func didTapOpenAppleMapButton(_ sender: UIButton) {
        guard let item = item else { return }
        
        guard let address = (item.addr).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let la = String(item.la).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let lo = String(item.lo).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        guard let q = (item.mtlty).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        
        // let appleMapURL = "https://maps.apple.com/?ll=\(item.la),\(item.lo)"
        let appleMapURL = "https://maps.apple.com/?address=\(address)&ll=\(la),\(lo)&q=\(q)"
        print(appleMapURL)
        
        let url = URL(string: appleMapURL)!
        let appStoreUrl = URL(string: "http://itunes.apple.com/app/id915056765?mt=8")!
        
        print(UIApplication.shared.canOpenURL(url))
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open(appStoreUrl)
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let item = item else { return }
        storeNameLabel.text = item.mtlty
        storeAddrLabel.text = item.roadNmAddr
        openHourLabel.text = "👉 \(item.wkdayOperBgngTm) ~ \(item.wkdayOperEndTm)"
        manageInfoLabel.text = "\(item.mngInstNm) \(item.telno)"
        setOpenHourButton()
        
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: item.la, lng: item.lo)
        marker.captionText = item.mtlty
        marker.captionOffset = 5
        marker.mapView = nMapView
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: item.la, lng: item.lo))
        cameraUpdate.animation = .fly
        nMapView.moveCamera(cameraUpdate)
        
//        let param = [
//            "serviceKey" : apiServiceKey,
//            "pageIndex" : "1",
//            "pageUnit" : "500",
//            "dataTy" : apiType,
//            "searchCondition" : "road_nm_addr",
//            "searchKeyword" :
//        ]
//
//        AF.request(apiURL, method: .get, parameters: param).responseDecodable(of: API.self) { response in
//            switch response.result {
//            case .success(let res):
//                self.apiResponse = res
//                DispatchQueue.main.async {
//                    // Add Data to UI
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    
    
    
}



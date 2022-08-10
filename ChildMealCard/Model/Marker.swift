//
//  Marker.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/12.
//

import Foundation
import Alamofire
import NMapsMap

extension Notification.Name {
    static let didGetMarkerDataNotification = Notification.Name("didGetMarkerDataNotification")
}

func getMarkerData() {
    var api: API?
    let param = [
        "serviceKey" : apiServiceKey,
        "pageIndex" : "1",
        "pageUnit" : "500",
        "dataTy" : apiType
    ]
    
    var markers: [NMFMarker?] = []
    
    AF.request(apiURL, method: .get, parameters: param).responseDecodable(of: API.self) { response in
        switch response.result {
        case .success(let res):
            api = res
            guard let api = api else { return }
            for i in 0..<api.body.items.count {
                let item = api.body.items[i]
                let marker = NMFMarker()
                marker.position = NMGLatLng(lat: item.la, lng: item.lo)
                marker.width = 30
                marker.height = 40
                marker.captionText = item.mtlty
                marker.captionOffset = 5
                marker.userInfo = ["info" : item]
                
                markers.append(marker)
            }
            
            NotificationCenter.default.post(name: .didGetMarkerDataNotification,
                                            object: nil,
                                            userInfo: ["markers" : markers])

        case .failure(let error):
            print(error)
        }
    }
}

//
//  APIResponse.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/08.
//

import Foundation

let apiURL = "http://apis.data.go.kr/5690000/sjChildren'sWelfareMealsInforamtion/sj_00000620"
let apiServiceKey = "TpTNEDwlJZmED+fciIL1Qelia558KJBzFN5BcWGp//qwUOX8/O4wMug30rr1QcOkfu4aS0nPmuXg72hp6gD9lA=="
let apiType = "json"

struct Header: Codable {
    let resultCode: String
    let resultMsg: String
    let totalCount: Int
    let pageIndex: Int
    let pageUnit: Int
    let searchCondition: String
    let searchKeyword: String
}

struct Body: Codable {
    let items: [Item]
}

struct Item: Codable {
    let wkdayOperEndTm: String
    let lo: Double
    let dlvrBgngTm: String
    let frcsTyCd: Int
    let satOperBgngTm: String
    let roadNmAddr: String
    let hldyOperBgngTm: String
    let crtrYmd: String
    let telno: String
    let dlvrEndTm: String
    let wkdayOperBgngTm: String
    let la: Double
    let hldyOperEndTm: String
    let mngInstNm: String
    let satOperEndTm: String
    let mtlty: String
    let addr: String
    let ocrnYmd: String
    let frcsTelno: String
}

struct API: Codable {
    let header: Header
    let body: Body
}

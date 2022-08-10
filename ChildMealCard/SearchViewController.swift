//
//  SearchViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/08.
//

import UIKit
import Alamofire

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var merchantListTableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    let searchController = UISearchController(searchResultsController: nil)
    
    var api: API?
    var filtereds: [Item] = []
    
    let param = [
        "serviceKey" : apiServiceKey,
        "pageIndex" : "1",
        "pageUnit" : "500",
        "dataTy" : apiType
    ]
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false
        
        return isActive && isSearchBarHasText
    }
    
    // MARK: - Methods
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        merchantListTableView.dataSource = self
        merchantListTableView.delegate = self
        
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        title = "검색"
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "가맹점 이름"
        searchController.searchBar.setValue("취소", forKey: "cancelButtonText")
        navigationItem.searchController = searchController
        // navigationItem.backButtonTitle = ""
        
        AF.request(apiURL, method: .get, parameters: param).responseDecodable(of: API.self) { response in
            switch response.result {
            case .success(let res):
                self.api = res
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.merchantListTableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selectIndexPath = merchantListTableView.indexPathForSelectedRow {
            merchantListTableView.deselectRow(at: selectIndexPath, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailVC = segue.destination as? DetailViewController else { return }
        guard let cell = sender as? UITableViewCell else { return }
        
        if let indexPath = merchantListTableView.indexPath(for: cell) {
            if isFiltering {
                detailVC.item = filtereds[indexPath.row]
            } else {
                detailVC.item = api?.body.items[indexPath.row]
            }
            
            merchantListTableView.deselectRow(at: indexPath, animated: true)
        }
        
        
    }
    
}

// MARK: - Extensions for UITableView
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let apiResponse = api else { return 0 }
        return self.isFiltering ? filtereds.count : apiResponse.body.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        
        guard let apiResponse = api else { return UITableViewCell() }
        
        var item: Item
        
        if self.isFiltering {
            item = filtereds[indexPath.row]
        } else {
            item = apiResponse.body.items[indexPath.row]
        }
        
        cell.textLabel?.text = item.mtlty
        
        if item.roadNmAddr.count < 1 {
            print("empty")
            cell.detailTextLabel?.text = "-"
        } else {
            cell.detailTextLabel?.text = item.roadNmAddr
        }
        
        return cell
    }
    
}

// MARK: - Extensions for UISearch
extension SearchViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text?.lowercased() else { return }
        guard let items = api?.body.items else { return }
        self.filtereds = items.filter({ item in
            item.mtlty.lowercased().contains(text)
        })
        
        self.merchantListTableView.reloadData()
    }
    
}

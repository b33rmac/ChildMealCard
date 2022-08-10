//
//  MainViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/15.
//

import UIKit
import Network

class MainViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    func monitorNetwork() {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                DispatchQueue.main.async {
                    guard let tabBarVC = self?.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") else { return }
                    tabBarVC.modalPresentationStyle = .fullScreen
                    self?.present(tabBarVC, animated: true)
                }
                
            } else {
                DispatchQueue.main.async {
                    self?.label.text = "인터넷 연결 없음\n\nwifi 및 셀룰러 설정을 확인하세요"
                    self?.view.backgroundColor = .systemRed
                }
            }
        }
        
        let queue = DispatchQueue(label: "Network")
        monitor.start(queue: queue)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        monitorNetwork()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

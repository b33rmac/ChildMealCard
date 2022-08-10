//
//  InfoViewController.swift
//  ChildMealCard
//
//  Created by b33rmac on 2022/07/14.
//

import UIKit
import StoreKit
import MessageUI

class InfoViewController: UIViewController {
    
    // MARK: - Properties
    @IBOutlet weak var infoListTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "정보"
        
        infoListTableView.dataSource = self
        infoListTableView.delegate = self
    }
    
}

extension InfoViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "버전"
        } else if section == 1 {
            return "도움이 되셨다면"
        } else if section == 2 {
            return "더 나은 서비스를 위해"
        } else {
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath)
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "리뷰 남기기"
        } else if indexPath.section == 2 {
            cell.textLabel?.text = "문의하기"
        }
        
        return cell
    }
    
}

extension InfoViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            guard let scene = view.window?.windowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
        } else if indexPath.section == 2 {
            if MFMailComposeViewController.canSendMail() {
                let mailVC = MFMailComposeViewController()
                mailVC.mailComposeDelegate = self
                mailVC.setToRecipients(["smh9360@gmail.com"])
                mailVC.setMessageBody("문의 하실 내용:", isHTML: false)
                present(mailVC, animated: true)
            } else {
                showSendMailErrorAlert()
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패",
                                                   message: "아이폰 메일 설정을 확인하고 다시 시도해주세요.",
                                                   preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { action in
            print("확인")
        }
        
        sendMailErrorAlert.addAction(confirmAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
}

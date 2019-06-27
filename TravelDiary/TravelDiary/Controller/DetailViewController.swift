//
//  DetailViewController.swift
//  TravelDiary
//
//  Created by Chunsu Kim on 27/06/2019.
//  Copyright © 2019 Chunsu Kim. All rights reserved.
//

import UIKit

protocol CustomCollectionViewCellDelegate: class {
    func removeCell(_ sender: Int) -> Void
}

class DetailViewController: UIViewController {

    // MARK: - Properties
    var savedData: MemoData?
    let contents = UITextView()
    let selectedImageView = UIImageView()
    let registerDateLabel = UILabel()
    private let topNavigationView = UIView()
    private let backButton = UIButton()
    private let trashButton = UIButton()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    lazy var dao = MemoDAO()
    weak var delegate: CustomCollectionViewCellDelegate?
    
    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUserInterface()
        configureConstraints()
        showSavedUserInputData()
    }
    
    // MARK: - configuration
    private func configureUserInterface() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let buttonflexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonDoneBar = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonClicked(_sender:)))
        toolBarKeyboard.items = [buttonflexBar, buttonDoneBar]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        
        trashButton.setImage(UIImage(named: "trash"), for: .normal)
        trashButton.addTarget(self, action: #selector(removeButtonDidTap(_:)), for: .touchUpInside)
        
        contents.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        contents.textColor = #colorLiteral(red: 0.2683359385, green: 0.3678353727, blue: 0.7584179044, alpha: 1)
        contents.layer.cornerRadius = 10
        contents.layer.borderColor = #colorLiteral(red: 0.2142035365, green: 0.6806999445, blue: 0.986015141, alpha: 1)
        contents.layer.borderWidth = 0.5
        contents.clipsToBounds = true
        contents.textAlignment = .center
        contents.inputAccessoryView = toolBarKeyboard
        contents.text = "asdfasdfsdf"
        
        registerDateLabel.font = UIFont.systemFont(ofSize: 20, weight: .light)
        registerDateLabel.textColor = #colorLiteral(red: 0.2683359385, green: 0.3678353727, blue: 0.7584179044, alpha: 1)
        
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.layer.cornerRadius = 20
        selectedImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        view.addSubview(topNavigationView)
        topNavigationView.addSubview(backButton)
        topNavigationView.addSubview(trashButton)
        view.addSubview(selectedImageView)
        view.addSubview(contents)
        view.addSubview(registerDateLabel)
    }
    
    private func configureConstraints() {
        let guide = view.safeAreaLayoutGuide
        
//        imageView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.45)
        
        topNavigationView.translatesAutoresizingMaskIntoConstraints = false
        topNavigationView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topNavigationView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.centerYAnchor.constraint(equalTo: topNavigationView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        backButton.leadingAnchor.constraint(equalTo: topNavigationView.leadingAnchor, constant: 20).isActive = true
        
        trashButton.translatesAutoresizingMaskIntoConstraints = false
        trashButton.centerYAnchor.constraint(equalTo: topNavigationView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        trashButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        trashButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        trashButton.trailingAnchor.constraint(equalTo: topNavigationView.trailingAnchor, constant: -20).isActive = true
        
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        selectedImageView.topAnchor.constraint(equalTo: topNavigationView.bottomAnchor).isActive = true
        selectedImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        selectedImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        selectedImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true
        
        registerDateLabel.translatesAutoresizingMaskIntoConstraints = false
        registerDateLabel.topAnchor.constraint(equalTo: selectedImageView.bottomAnchor, constant: 10).isActive = true
        registerDateLabel.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        registerDateLabel.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        registerDateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        contents.translatesAutoresizingMaskIntoConstraints = false
        contents.topAnchor.constraint(equalTo: registerDateLabel.bottomAnchor, constant: 10).isActive = true
        contents.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 20).isActive = true
        contents.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -20).isActive = true
        contents.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -20).isActive = true
        
    }
    
    // MARK: - Action method
    private func showSavedUserInputData() {
        // 제목, 내용, 이미지 출력
        self.contents.text = savedData?.contents
        self.selectedImageView.image = savedData?.image
        
        // 날짜 포맷 변환
        let formatter = DateFormatter()
        formatter.dateFormat = "dd일 HH:mm분에 작성됨"
        let dateString = formatter.string(from: (savedData?.registerDate)!)
        
        // 레이블에 날짜 표시
        self.registerDateLabel.text = dateString
    }
    
    @objc private func doneButtonClicked (_sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc func removeButtonDidTap(_ sender: UIButton) {
        delegate?.removeCell(view.tag)
    }
}

extension DetailViewController: CustomCollectionViewCellDelegate {
    func removeCell(_ sender: Int) {
        let mainView = MainViewController()
        let data = self.appDelegate.memolist[sender]
        
        let alertAction = UIAlertController(title: "정말 삭제하실 건가요?", message: "삭제 후에는 복구 할 수 없습니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "삭제하기", style: .destructive) { (_) in
            if self.dao.delete(data.objectID!) {
                self.appDelegate.memolist.remove(at: sender)
            }
            mainView.collectionView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        alertAction.addAction(okAction)
        alertAction.addAction(cancelAction)
        present(alertAction, animated: true)
    
    }

}

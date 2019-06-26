//
//  WriteViewController.swift
//  TravelDiary
//
//  Created by Chunsu Kim on 25/06/2019.
//  Copyright © 2019 Chunsu Kim. All rights reserved.
//

import UIKit
import Firebase
import Photos
import TLPhotoPicker

class WriteViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TLPhotosPickerViewControllerDelegate, UIScrollViewDelegate {
    
    private let topNavigationView = UIView()
    private let backButton = UIButton()
    private let saveButton = UIButton()
    private let scrollView = UIScrollView()
    private let textView = UITextView()
    private let textViewLabel = UILabel()
    let selectedImageView = UIImageView()
    
    private var imageScrollView = UIScrollView()
//    private
    private var pageControl = UIPageControl()
    var slides = [ImageSlide]()
    
    var selectedPictures = [TLPHAsset]()
    var imageURLSforUpload = [String]()
    var uploadCount = 0
    var selectedImageCount = 0
    
    var previousHeight : CGFloat = 25.0
    var kKeyboardSize : CGFloat = 0.0
    var keyboardVisible = false
    
    // MARK: - imageSlide
    func createSlides(_ images: [TLPHAsset]) -> [ImageSlide] {
        var slides = [ImageSlide]()
        for i in images {
            let slide = ImageSlide()
            print("### :", i.fullResolutionImage!)
//            slide.imageView.image = i.fullResolutionImage
            slides.append(slide)
        }
        
        return slides
    }
    
    func setupScrollView(_ imageSlides: [ImageSlide]) {
        imageScrollView.contentSize = CGSize(width: imageScrollView.frame.width * CGFloat(imageSlides.count), height: imageScrollView.frame.height)
        imageScrollView.isPagingEnabled = true
        
        for i in 0 ..< imageSlides.count {
            imageSlides[i].frame = CGRect(x: imageScrollView.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: imageScrollView.frame.height)
            imageSlides[0].backgroundColor = .blue
            imageScrollView.addSubview(imageSlides[i])
        }
        
        pageControl.numberOfPages = imageSlides.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.view.bringSubviewToFront(pageControl)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(imageScrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }
    
    // TLPhotos delegate functions
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        
        // MARK - TODO: What if no image selected or asset not recognized? handle here.
        
        // use selected order, fullresolution image
        self.selectedPictures = withTLPHAssets
        
        let slides = createSlides(selectedPictures)
        setupScrollView(slides)
        
        self.selectedImageCount = self.selectedPictures.count
    }
    
    //

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        configureConstraints()
        configureNotificationForKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch photoAuthorizationStatus {
            
        case .authorized: print("Access is granted by user")
            
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                print("status is \(newStatus)")
                if newStatus == PHAuthorizationStatus.authorized {print("success")
                    
                } })
        case .restricted:
            print("User do not have access to photo album.")
            
        case .denied:
            print("User has denied the permission.")
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name:
            UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func configureViews() {
        let toolBarKeyboard = UIToolbar()
        toolBarKeyboard.sizeToFit()
        let buttonflexBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let buttonDoneBar = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonClicked(_sender:)))
        toolBarKeyboard.items = [buttonflexBar, buttonDoneBar]
        toolBarKeyboard.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        view.backgroundColor = .white
        topNavigationView.backgroundColor = .white
        selectedImageView.contentMode = .scaleAspectFit
        selectedImageView.image = UIImage(named: "IU")
        
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonDidTap(_:)), for: .touchUpInside)
        
        saveButton.setImage(UIImage(named: "save"), for: .normal)
        saveButton.addTarget(self, action: #selector(saveButtonDidTap(_:)), for: .touchUpInside)
        
        textView.delegate = self
        textView.font = UIFont.italicSystemFont(ofSize: 20)
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = #colorLiteral(red: 0.5004553199, green: 0.6069974899, blue: 1, alpha: 1)
        textView.clipsToBounds = true
        textView.inputAccessoryView = toolBarKeyboard
        
        configureTextViewLabel()
        
        view.addSubview(topNavigationView)
        topNavigationView.addSubview(backButton)
        topNavigationView.addSubview(saveButton)
        view.addSubview(scrollView)
        imageScrollView.backgroundColor = .red
        scrollView.addSubview(imageScrollView)
        imageScrollView.addSubview(pageControl)
        scrollView.addSubview(textView)
        textView.addSubview(textViewLabel)
        
        imageTapEvent()
    }
    
    private func imageTapEvent() {
        let addImageGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage(_:)))
        addImageGesture.numberOfTapsRequired = 1
        imageScrollView.addGestureRecognizer(addImageGesture)
    }
    
    private func configureTextViewLabel() {
        textViewLabel.text = "소중한 추억을 적어주세요 🧐"
        textViewLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textViewLabel.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        textViewLabel.textAlignment = .center
        textViewLabel.isHidden = false
    }
    
    private func configureNotificationForKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func configureConstraints() {
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
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.centerYAnchor.constraint(equalTo: topNavigationView.safeAreaLayoutGuide.centerYAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        saveButton.trailingAnchor.constraint(equalTo: topNavigationView.trailingAnchor, constant: -20).isActive = true
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: topNavigationView.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: -10).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: imageScrollView.bottomAnchor, constant: 10).isActive = true
        textView.centerXAnchor.constraint(equalTo: imageScrollView.centerXAnchor).isActive = true
        textView.widthAnchor.constraint(equalToConstant: 350).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        textView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -10).isActive = true
        
        textViewLabel.translatesAutoresizingMaskIntoConstraints = false
        textViewLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10).isActive = true
        textViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textViewLabel.heightAnchor.constraint(equalToConstant: 23).isActive = true
        
    }
    
    private func textViewLabelShow() {
        if textView.text?.isEmpty == true {
            configureTextViewLabel()
        } else {
            self.textViewLabel.isHidden = true
        }
    }
    
    @objc private func backButtonDidTap(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonDidTap(_ sender: UIButton) {
        
    }
    
    @objc private func doneButtonClicked (_sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(_ sender: Notification) {
        self.view.frame.origin.y = -300
        textViewLabel.isHidden = true
    }
    
    @objc private func keyboardWillHide(_ sender: Notification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        if !keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            let userInfo = notification.userInfo!
            let keyboardSize = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
            if self.view.frame.origin.y == previousHeight {
                kKeyboardSize = keyboardSize!.height
                self.view.frame.origin.y -= (keyboardSize!.height/2.0)
            }
        }
        
        keyboardVisible = true
    }
    
    @objc
    func keyboardWillHide(notification:Notification) {
        if keyboardVisible && ( self.view.traitCollection.horizontalSizeClass != UIUserInterfaceSizeClass.regular ) {
            if self.view.frame.origin.y != previousHeight {
                self.view.frame.origin.y = previousHeight
            }
        }
        keyboardVisible = false
    }
    
    @objc func selectImage(_ sender: UITapGestureRecognizer) {
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        var configure = TLPhotosPickerConfigure()
        configure.allowedVideo = false
        configure.allowedVideoRecording = false
        configure.muteAudio = true
        self.present(viewController, animated: true, completion: nil)
        
    }

    

}

extension WriteViewController: UITextViewDelegate {
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        textViewLabelShow()
        
        return true
    }
}

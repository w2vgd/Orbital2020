//
//  MSExpertMyReviewsViewController.swift
//  LinkUs
//
//  Created by macos on 16/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import UIKit
import Firebase
import Cosmos

class MSExpertMyReviewsViewController: UIViewController {
    
    @IBOutlet weak var profilePhotoImageView: UIImageView!
    
    @IBOutlet weak var totalRatingsCount: UILabel!
    
    @IBOutlet weak var ratingsView: CosmosView!
    
    @IBOutlet weak var reviewsTableView: UITableView!
    
    var user: LoginUser?
    
    var myReviews: MyReviews?
    
    var myReviewsListener: ListenerRegistration?
    
    var reviewClicked: Review?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setUpElements()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        setUpMyReviewsListener()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        myReviewsListener!.remove()
        print("myReviews listener removed in viewdiddisappear")
        
    }
    
    deinit {
        myReviewsListener?.remove()
        print("deinit of expertmyreviews called")
    }
    
    func setUpElements() {
        
        if let homeTabBarController = self.tabBarController as? HomeTabBarController {
            
            self.user = homeTabBarController.user
            
        }
        
        reviewsTableView.register(MSExpertMyReviewsTableViewCell.nib(), forCellReuseIdentifier: MSExpertMyReviewsTableViewCell.identifier)
        
        reviewsTableView.delegate = self
        reviewsTableView.dataSource = self
        
        // Remove the extra separator lines below the options
        let footerView = UIView()
        footerView.backgroundColor = .clear
        reviewsTableView.tableFooterView = footerView
        
        // To make the imageview circular with a border
        profilePhotoImageView.layer.masksToBounds = true
        profilePhotoImageView.layer.borderWidth = 2
        profilePhotoImageView.layer.borderColor = UIColor.lightGray.cgColor
        profilePhotoImageView.layer.cornerRadius = profilePhotoImageView.frame.size.width / 2.0
        
        let path = "images/\(self.user!.uid)_profile_picture.png"
        
        /* Might need to fix because this keeps downloading url from firebase */
        FirebaseStorageManager.shared.downloadURL(for: path) { [weak self ] result in
            
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    strongSelf.profilePhotoImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("failed to get download url: \(error)")
            }
        }
        
    }
    
    func setUpMyReviewsListener() {
        
        let db = Firestore.firestore()
        let myReviewRef = db.collection("myReviews").document(self.user!.uid)
        
        // Realtime listener that gets called everytime thrs an update in the database, meaning to say myReviews will be updated in realtime (realtime listener is better than fetching data everytime there is an update to myReviews)
        myReviewsListener = myReviewRef.addSnapshotListener { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard let snapshot = querySnapshot else {
                print("Error listening to realtime myReviews updates: \(error?.localizedDescription ?? "no error")")
                return
            }
            let data = snapshot.data()!
            
            let reviewsUidList = data["reviewsUidList"] as? [String]
            let reviewsUidToRatingsMap = data["reviewsUidToRatingsMap"] as? [String : Double]
            let reviewsUidToUserUidMap =  data["reviewsUidToUserUidMap"] as? [String : String]
            let reviewsUidToUserFullNameMap =  data["reviewsUidToUserFullNameMap"] as? [String : String]
            let reviewsUidToTimestampMap = data["reviewsUidToTimestampMap"] as? [String : Timestamp]
            let reviewsUidToUShortenedFeedbackMap =  data["reviewsUidToUShortenedFeedbackMap"] as? [String : String]
            
            strongSelf.myReviews = MyReviews(
                reviewsUidList: reviewsUidList,
                reviewsUidToRatingsMap: reviewsUidToRatingsMap,
                reviewsUidToUserUidMap: reviewsUidToUserUidMap,
                reviewsUidToUserFullNameMap: reviewsUidToUserFullNameMap,
                reviewsUidToTimestampMap: reviewsUidToTimestampMap,
                reviewsUidToUShortenedFeedbackMap: reviewsUidToUShortenedFeedbackMap)
            
            let totalRatings = reviewsUidToRatingsMap!.values.reduce(0.0, +)
            let totalReviews = reviewsUidList!.count
            
            strongSelf.totalRatingsCount.text = "(\(totalReviews) total ratings)"
            
            strongSelf.ratingsView.settings.fillMode = .half
            strongSelf.ratingsView.settings.updateOnTouch = false
            strongSelf.ratingsView.settings.textColor = .darkText
            strongSelf.ratingsView.settings.textMargin = 10
            strongSelf.ratingsView.rating = totalReviews == 0 ? 0.0 : totalRatings / Double(totalReviews)
            strongSelf.ratingsView.text = String(format: "%.2f", strongSelf.ratingsView.rating) + " stars"
            
            // Anything UI related should occur on main thread
            DispatchQueue.main.async {
                strongSelf.reviewsTableView.reloadData()
            }
            
            
        }
        
    }
    
}


// MARK: - TableView Delegate Methods

extension MSExpertMyReviewsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.myReviews != nil && self.myReviews!.reviewsUidList != nil {
            return self.myReviews!.reviewsUidList!.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MSExpertMyReviewsTableViewCell.identifier, for: indexPath) as! MSExpertMyReviewsTableViewCell
        
        if self.myReviews != nil && self.myReviews!.reviewsUidList != nil {
            
            let reviewUid = myReviews!.reviewsUidList![indexPath.row]
            let userUid = myReviews!.reviewsUidToUserUidMap![reviewUid]
            let userFullName = myReviews!.reviewsUidToUserFullNameMap![reviewUid]
            let ratings = myReviews!.reviewsUidToRatingsMap![reviewUid]
            let date = myReviews!.reviewsUidToTimestampMap![reviewUid]!.dateValue()
            let shortenedFeedback = myReviews!.reviewsUidToUShortenedFeedbackMap![reviewUid]
            
            var review = Review(reviewUid: reviewUid)
            review.userUid = userUid
            review.userFullName = userFullName
            review.ratings = ratings
            review.date = date
            review.shortenedFeedback = shortenedFeedback
            
            cell.configure(with: review)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // to unselect the item after clicking
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // Retrieve the review details from Firebase when expert clicks on the review
        
        let reviewUid = myReviews!.reviewsUidList![indexPath.row]
        
        let db = Firestore.firestore()
        let reviewRef = db.collection("reviews").document(reviewUid)
        
        reviewRef.getDocument { (document, error) in
            
            if let error = error {
                print("Error retrieving review from database: \(error.localizedDescription)")
            } else if let document = document, document.exists {
            
                let data = document.data()!
                
                let feedback = data["feedback"] as! String
                
                let userUid = self.myReviews!.reviewsUidToUserUidMap![reviewUid]
                let userFullName = self.myReviews!.reviewsUidToUserFullNameMap![reviewUid]
                let ratings = self.myReviews!.reviewsUidToRatingsMap![reviewUid]
                let date = self.myReviews!.reviewsUidToTimestampMap![reviewUid]!.dateValue()
                let shortenedFeedback = self.myReviews!.reviewsUidToUShortenedFeedbackMap![reviewUid]
                
                
                self.reviewClicked = Review(reviewUid: reviewUid)
                self.reviewClicked!.userUid = userUid
                self.reviewClicked!.userFullName = userFullName
                self.reviewClicked!.ratings = ratings
                self.reviewClicked!.date = date
                self.reviewClicked!.shortenedFeedback = shortenedFeedback
                self.reviewClicked!.feedback = feedback
                
                // Create a new ReviewPageVC when the expert clicks to view a review
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let reviewPageVC = storyboard.instantiateViewController(identifier: Constants.Storyboard.expertReviewPageViewController) as! MSExpertReviewPageViewController
                
                reviewPageVC.title = "Review Details"
                
                reviewPageVC.reviewClicked = self.reviewClicked
                
                // Push the next viewcontroller onto the navigation stack after everything is done
                self.navigationController?.pushViewController(reviewPageVC, animated: true)
                
            }
        }
        
    }
    
}

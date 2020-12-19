//
//  FirebaseFirestoreManager.swift
//  LinkUs
//
//  Created by macos on 26/6/20.
//  Copyright © 2020 macos. All rights reserved.
//

import Foundation
import FirebaseFirestore

final class FirebaseFirestoreManager {
    
    static let shared = FirebaseFirestoreManager()
    
    private let firestore = Firestore.firestore()
    
    
    // MARK: - Create New User Methods
    
    /// Uploads new user to Firestore
    public func uploadNewUser(for userUid: String, with data: [String : Any], completion: @escaping ((Bool) -> Void)) {
        
        let newUserRef = firestore.collection("users").document(userUid)
        
        newUserRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // Failed to upload new user info
                print("Failed to upload new user info to firestore: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Create the required collections for the new user
            
            strongSelf.createNewInboxApplication(for: userUid) { createdInboxApplication in
                
                guard createdInboxApplication else {
                    completion(false)
                    return
                }
                
                strongSelf.createNewChatsList(for: userUid) { createdChatsList in
                    
                    guard createdChatsList else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.createNewMyApplications(for: userUid) { createdMyApplications in
                        
                        guard createdMyApplications else {
                            completion(false)
                            return
                        }
                        
                        strongSelf.createNewMyReviews(for: userUid) { createdMyReviews in
                            
                            guard createdMyReviews else {
                                completion(false)
                                return
                            }
                            
                            strongSelf.createNewMyForumBookmarks(for: userUid) { createdMyForumBookmarks in
                                
                                guard createdMyForumBookmarks else {
                                    completion(false)
                                    return
                                }
                                
                                strongSelf.createNewMyNotifications(for: userUid) { createdMyNotifications in
                                    
                                    guard createdMyNotifications else {
                                        completion(false)
                                        return
                                    }
                                    
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// Create a new inboxApplication for every user who first signs up to keep track of applications received from applicants
    public func createNewInboxApplication(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        /*
        FYI, creating a separate inboxApplication to store only snippets of information required to populate the main page of Inbox page in order to save the number of reads to the database, which will reduce the amount of time it needs to load the data (and also reduce billing costs of reading the whole collection in a query)
        */
        
        let newInboxApplicationRef = firestore.collection("inboxApplications").document(userUid)
        
        newInboxApplicationRef.setData([
            "expertUid" : userUid,
            "applicationsUidList" : [String](),
            "applicationsUidToUserFullNameMap" : [String : String]()
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving inboxApplication data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created an inboxApplication")
            completion(true)
        }
        
    }
    
    /// Create a chatsList for every user who first signs up to keep track of authorised chat partners
    public func createNewChatsList(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let newChatsListRef = firestore.collection("chatsList").document(userUid)
        
        newChatsListRef.setData([
            "matchedPartnersUidList" : [String](),
            "matchedPartnersUidToNameMap" : [String : String](),
            "matchedPartnersUidToChatUidMap" : [String : String]()
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving chatsList data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created a chatsList for this user")
            completion(true)
        }
        
    }
    
    /// Create a myApplications list to keep track of the applications sent
    public func createNewMyApplications(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let newMyApplicationRef = firestore.collection("myApplications").document(userUid)
        
        newMyApplicationRef.setData([
            "applicationsUidList" : [String](),
            "applicationsUidToStatusMap" : [String : String]()
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving myApplications data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created a myApplications for this user")
            completion(true)
        }
        
    }
    
    /// Create a myReviews list to keep track of own reviews received
    public func createNewMyReviews(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let newMyReviewsRef = firestore.collection("myReviews").document(userUid)
        
        newMyReviewsRef.setData([
            "reviewsUidList" : [String](),
            "reviewsUidToRatingsMap" : [String : Double](),
            "reviewsUidToUserUidMap" : [String : String](),
            "reviewsUidToUserFullNameMap" : [String : String](),
            "reviewsUidToTimestampMap" : [String : Timestamp](),
            "reviewsUidToUShortenedFeedbackMap" : [String : String](),
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving myReviews data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created a myReviews for this user")
            completion(true)
        }
        
    }
    
    /// Create a myForumBookmarks list to keep track of own bookmarked forum posts
    public func createNewMyForumBookmarks(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let newMyForumBookmarksRef = firestore.collection("myForumBookmarks").document(userUid)
        
        newMyForumBookmarksRef.setData([
            "forumPostUidList" : [String](),
            "forumPostUidToTitleMap" : [String : String]()
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving myForumBookmarks data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created a myForumBookmarks for this user")
            completion(true)
        }
        
    }
    
    /// Create a myNotifications list to keep track of own notifications
    public func createNewMyNotifications(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let newMyNotificationsRef = firestore.collection("myNotifications").document(userUid)
        
        newMyNotificationsRef.setData([
            "exists" : true
        ]) { (error) in
            
            guard error == nil else {
                // There is an error saving user data in the database
                print("Error saving myNotifications data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully created a myNotifications for this user")
            completion(true)
        }
    }
    
    
    // MARK: - Update User Profile Information Methods
    
    /// Updates the user profile information
    public func updateUserProfileInformation(for userUid: String, with data: [String: Any], completion: @escaping ((Bool) -> Void)) {
        
        let userRef = firestore.collection("users").document(userUid)
        
        userRef.updateData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // Failed to update user info
                print("Failed to update user info to firestore: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Successfully updated user info
            print("Successfully updated user info to firestore")
            
            guard let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String else {
                return
            }
            
            let editedFullName = firstName + " " + lastName
            
            strongSelf.updateName(for: userUid, with: editedFullName) { (success) in
                
                if success {
                    
                    print("updated name successfully")
                    completion(true)
                    
                } else {
                    
                    print("error updating name")
                    completion(false)
                    
                }
                
            }
            
        }
        
    }
    
    /// Update the fullname of the user in all documents that store it
    public func updateName(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        updateNameInChatsList(for: userUid, with: updatedName) { [weak self] updatedChatsList in
            
            guard let strongSelf = self else {
                return
            }
            
            guard updatedChatsList else {
                completion(false)
                return
            }
            
            strongSelf.updateNameInReviews(for: userUid, with: updatedName) { updatedReviews in
                
                guard updatedReviews else {
                    completion(false)
                    return
                }
                
                strongSelf.updateNameInMatchedExpertUid(for: userUid, with: updatedName) { updatedMatchedExpertUid in
                    
                    guard updatedReviews else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.updateNameInApplication(for: userUid, with: updatedName) { updatedApplication in
                        
                        guard updatedApplication else {
                            completion(false)
                            return
                        }
                        
                        strongSelf.updateNameInForumPost(for: userUid, with: updatedName) { updatedForumPost in
                            
                            guard updatedForumPost else {
                                completion(false)
                                return
                            }
                            
                            strongSelf.updateNameInForumReply(for: userUid, with: updatedName) { updatedForumReply in
                                
                                guard updatedForumReply else {
                                    completion(false)
                                    return
                                }
                                
                                strongSelf.updateNameInMyNotifications(for: userUid, with: updatedName) { updatedMyNotifications in
                                    
                                    guard updatedMyNotifications else {
                                        completion(false)
                                        return
                                    }
                                    
                                    print("Name successfully updated in all places")
                                    completion(true)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func updateNameInChatsList(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Create a new write batch
        let chatsListBatch = firestore.batch()
        
        // Update chatsList
        let chatsListRef = firestore.collection("chatsList")
        let chatsListQuery = chatsListRef.whereField("matchedPartnersUidList", arrayContains: userUid)
        
        chatsListQuery.getDocuments { chatsListQuerySnapshot, chatsListQueryError in
            
            guard chatsListQueryError == nil else {
                // There was an error retrieving chatsList documents from the database
                print("Error getting chatsList documents from query: \(chatsListQueryError!.localizedDescription)")
                return
            }
            
            // chatsList documents successfully retrieved from the database
            for document in chatsListQuerySnapshot!.documents {
                
                // Each document is the chatsList of users who is matched with the current user
                
                let fieldToUpdate = "matchedPartnersUidToNameMap." + userUid
                
                // Update each chatsList
                chatsListBatch.updateData([
                    fieldToUpdate : updatedName
                ], forDocument: document.reference)
                
            }
            
            // Commit the batch
            chatsListBatch.commit { chatsListBatchError in
                
                guard chatsListBatchError == nil else {
                    print("Error updating chatsList batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed chatsList batch")
                completion(true)
                
            }
        }
    }
    
    private func updateNameInReviews(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Create a new write batch
        let reviewsBatch = firestore.batch()
        
        // Update reviews
        let reviewsRef = firestore.collection("reviews")
        let reviewsQuery = reviewsRef.whereField("userUid", isEqualTo: userUid)
        
        reviewsQuery.getDocuments { [weak self] reviewsQuerySnapshot, reviewsQueryError in
            
            guard let strongSelf = self else {
                return
            }
            
            guard reviewsQueryError == nil else {
                // There was an error retrieving reviews documents from the database
                print("Error getting reviews documents from query: \(reviewsQueryError!.localizedDescription)")
                return
            }
            
            // reviews documents successfully retrieved from the database
            for document in reviewsQuerySnapshot!.documents {
                
                // Each document is a submitted review by the user
                
                let data = document.data()
                let reviewUid = data["reviewUid"] as! String
                
                // Update each review
                reviewsBatch.updateData([
                    "userFullName" : updatedName
                ], forDocument: document.reference)
                
                
                // Update myReviews
                
                // Create a new myReviews write batch for each review document
                let myReviewsBatch = strongSelf.firestore.batch()
                
                let myReviewsRef = strongSelf.firestore.collection("myReviews")
                let myReviewsQuery = myReviewsRef.whereField("reviewsUidList", arrayContains: reviewUid)
                
                myReviewsQuery.getDocuments { (querySnapshot, myReviewsQueryError) in
                    
                    guard myReviewsQueryError == nil else {
                        // There was an error retrieving documents from the database
                        print("Error getting documents from query")
                        print(myReviewsQueryError!.localizedDescription)
                        return
                    }
                    
                    // myReviews documents successfully retrieved from the database
                    for document in querySnapshot!.documents {
                        
                        // Each document is the myReviews of an expert who has the user's review. Now we need to update the name of the user in this reviewsUidToUserFullNameMap.
                        let fieldToUpdate = "reviewsUidToUserFullNameMap." + reviewUid
                        
                        // Update each myReviews
                        myReviewsBatch.updateData([
                            fieldToUpdate : updatedName
                        ], forDocument: document.reference)
                        
                    }
                    
                    // Commit the batch
                    myReviewsBatch.commit { myReviewsBatchError in
                        
                        guard myReviewsBatchError == nil else {
                            print("Error updating myReviews batch")
                            return
                        }
                        
                        print("Successfully committed myReviews batch")
                        
                    }
                }
            }
            
            // Commit the batch
            reviewsBatch.commit { reviewsBatchError in
                
                guard reviewsBatchError == nil else {
                    print("Error updating reviews batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed reviews batch")
                completion(true)
                
            }
        }
        
    }
    
    private func updateNameInMatchedExpertUid(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Create a new write batch
        let matchExpertUidBatch = firestore.batch()
        
        // Update the matchedExpertFullName in the applications database if user has accepted any application
        let applicationsRef = firestore.collection("applications")
        let expertApplicationQuery = applicationsRef.whereField("matchedExpertUid", isEqualTo: userUid)
        
        expertApplicationQuery.getDocuments { expertApplicationQuerySnapshot, expertApplicationQueryError in
            
            guard expertApplicationQueryError == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query")
                print(expertApplicationQueryError!.localizedDescription)
                return
            }
            
            // Documents successfully retrieved from the database
            for document in expertApplicationQuerySnapshot!.documents {
                
                // Each document is an application accepted by the expert
                
                matchExpertUidBatch.updateData([
                    "matchedExpertFullName" : updatedName
                ], forDocument: document.reference)
                
            }
            
            // Commit the batch
            matchExpertUidBatch.commit { matchExpertUidBatchError in
                
                guard matchExpertUidBatchError == nil else {
                    print("Error updating matchedExpertUid batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed matchedExpertUid batch")
                completion(true)
            }
        }
        
    }
    
    private func updateNameInApplication(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Create a new write batch
        let userApplicationBatch = firestore.batch()
        
        // Update the user's full name in the applications database if user has an application
        let applicationsRef = firestore.collection("applications")
        let userApplicationQuery = applicationsRef.whereField("userUid", isEqualTo: userUid)
        
        userApplicationQuery.getDocuments { [weak self] userApplicationQuerySnapshot, userApplicationQueryError in
            
            guard let strongSelf = self else {
                return
            }
            
            guard userApplicationQueryError == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query")
                print(userApplicationQueryError!.localizedDescription)
                return
            }
            
            // Documents successfully retrieved from the database
            for document in userApplicationQuerySnapshot!.documents {
                
                // Each document is an application submitted by the user
                
                let data = document.data()
                let applicationUid = data["applicationUid"] as! String
                
                userApplicationBatch.updateData([
                    "userFullName" : updatedName
                ], forDocument: document.reference)
                
                // Update the user's full name in the inboxApplications database
                
                // Create a new write batch
                let inboxApplicationBatch = strongSelf.firestore.batch()
                
                let inboxApplicationsRef = strongSelf.firestore.collection("inboxApplications")
                let inboxApplicationQuery = inboxApplicationsRef.whereField("applicationsUidList", arrayContains: applicationUid)
                
                inboxApplicationQuery.getDocuments { (querySnapshot, inboxApplicationQueryError) in
                    
                    guard inboxApplicationQueryError == nil else {
                        // There was an error retrieving documents from the database
                        print("Error getting documents from query")
                        print(inboxApplicationQueryError!.localizedDescription)
                        return
                    }
                    
                    // Documents successfully retrieved from the database
                    for document in querySnapshot!.documents {
                        
                        // Each document is the inbox of an expert who has the user's application. Now we need to update the name of the user in this applicationUidToUserFullNameMap.
                        let fieldToUpdate = "applicationsUidToUserFullNameMap." + applicationUid
                        
                        inboxApplicationBatch.updateData([
                            fieldToUpdate : updatedName
                        ], forDocument: document.reference)
                        
                    }
                    
                    // Commit the batch
                    inboxApplicationBatch.commit { inboxApplicationBatchError in
                        
                        guard inboxApplicationBatchError == nil else {
                            print("Error updating inboxApplication batch")
                            return
                        }
                        
                        print("Successfully committed inboxApplication batch")
                        
                    }
                }
            }
            
            // Commit the batch
            userApplicationBatch.commit { userApplicationBatchError in
                
                guard userApplicationBatchError == nil else {
                    print("Error updating userApplication batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed userApplication batch")
                completion(true)
            }
        }
        
    }
    
    private func updateNameInForumPost(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update fullname in forumPosts
        
        // Create a new write batch
        let forumPostBatch = firestore.batch()
        
        let forumRef = firestore.collection("forum")
        let forumPostQuery = forumRef.whereField("posterUid", isEqualTo: userUid)
        
        forumPostQuery.getDocuments { forumPostQuerySnapshot, forumPostQueryError in
            
            guard forumPostQueryError == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query")
                print(forumPostQueryError!.localizedDescription)
                return
            }
            
            // Documents successfully retrieved from the database
            for document in forumPostQuerySnapshot!.documents {
                // Each document is a forum post made by the user
                forumPostBatch.updateData([
                    "posterFullName" : updatedName
                ], forDocument: document.reference)
                
            }
            
            // Commit the batch
            forumPostBatch.commit { forumPostBatchError in
                
                guard forumPostBatchError == nil else {
                    print("Error updating forumPost batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed forumPost batch")
                completion(true)
            }
        }
        
    }
    
    private func updateNameInForumReply(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update fullname in forumReplies
        
        let forumRef = firestore.collection("forum")
        
        forumRef.getDocuments { [weak self] allForumPostQuerySnapshot, allForumPostQueryError in
            
            guard let strongSelf = self else {
                return
            }
            
            guard allForumPostQueryError == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query")
                print(allForumPostQueryError!.localizedDescription)
                return
            }
            
            // Documents successfully retrieved from the database
            for document in allForumPostQuerySnapshot!.documents {
                
                // Each document is a forumPost
                
                // Create a new write batch
                let forumReplyBatch = strongSelf.firestore.batch()
                
                let data = document.data()
                let forumPostUid = data["forumPostUid"] as! String
                let forumReplyRef = forumRef.document(forumPostUid).collection("replies")
                
                let forumReplyQuery = forumReplyRef.whereField("userUid", isEqualTo: userUid)
                
                forumReplyQuery.getDocuments { (repliesQuerySnapshot, repliesQueryError) in
                    
                    guard repliesQueryError == nil else {
                        // There was an error retrieving documents from the database
                        print("Error getting documents from query")
                        print(repliesQueryError!.localizedDescription)
                        return
                    }
                    
                    // Documents successfully retrieved from the database
                    for document in repliesQuerySnapshot!.documents {
                        // Each document is a forum reply made by the user
                        forumReplyBatch.updateData([
                            "userFullName" : updatedName
                        ], forDocument: document.reference)
                        
                    }
                    
                    forumReplyBatch.commit { forumReplyBatchError in
                        
                        guard forumReplyBatchError == nil else {
                            print("Error updating forumReply batch")
                            return
                        }
                        
                        print("Successfully committed forumReply batch")
                        
                    }
                    
                    completion(true)
                    
                }
            }
        }
    }
    
    private func updateNameInMyNotifications(for userUid: String, with updatedName: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update fullname in myNotifications
        
        let myNotificationsRef = firestore.collection("myNotifications")
        
        myNotificationsRef.getDocuments { [weak self] allMyNotificationsQuerySnapshot, allMyNotificationsQueryError in
            
            guard let strongSelf = self else {
                return
            }
            
            guard allMyNotificationsQueryError == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query")
                print(allMyNotificationsQueryError!.localizedDescription)
                return
            }
            
            // Documents successfully retrieved from the database
            for document in allMyNotificationsQuerySnapshot!.documents {
                
                // Each document is the myNotifications of a user
                
                // Create a new write batch
                let notificationsBatch = strongSelf.firestore.batch()
                
                let notificationsRef = document.reference.collection("notifications")
                
                let notificationsQuery = notificationsRef.whereField("byUserUid", isEqualTo: userUid)
                
                notificationsQuery.getDocuments { (notificationsQuerySnapshot, notificationsQueryError) in
                    
                    guard notificationsQueryError == nil else {
                        // There was an error retrieving documents from the database
                        print("Error getting documents from query")
                        print(notificationsQueryError!.localizedDescription)
                        return
                    }
                    
                    // Documents successfully retrieved from the database
                    for document in notificationsQuerySnapshot!.documents {
                        // Each document is a notification related to the user
                        notificationsBatch.updateData([
                            "byUserFullName" : updatedName
                        ], forDocument: document.reference)
                        
                    }
                    
                    notificationsBatch.commit { notificationsBatchError in
                        
                        guard notificationsBatchError == nil else {
                            print("Error updating notifications batch")
                            return
                        }
                        
                        print("Successfully committed notifications batch")
                        
                    }
                    
                    completion(true)
                    
                }
            }
        }
    }
    
    // MARK: - Send Application Methods
    
    public enum SendApplicationErrors: Error {
        
        case failedToRetrieveDocuments, NoExpertWithSpecialization
        
    }
    
    /// Send application and a notification to experts who have the corresponding specialization
    public func sendApplicationToExperts(applicationForm: MSUserApplication, completion: @escaping ((Result<[String], Error>), String) -> Void) {
        
        // Send the application to all relevant experts and store the application to database
        
        let usersRef = firestore.collection("users")
        let inboxApplicationsRef = firestore.collection("inboxApplications")
        
        // Create a new application in the database
        let applicationRef = firestore.collection("applications").document()
        
        // Create an array that will store the uid of experts who will receive this application
        var expertsUidList = [String]()
        
        // Create a query to find out which expert has the corresponding area of specialization
        let query = usersRef
            .whereField("specializations", arrayContains: applicationForm.category!.description)
        
        // Execute the query
        query.getDocuments { (querySnapshot, error) in
            
            guard error == nil else {
                // There was an error retrieving documents from the database
                print("Error getting documents from query: \(error!.localizedDescription)")
                completion(.failure(SendApplicationErrors.failedToRetrieveDocuments), applicationRef.documentID)
                return
            }
                
            // Document successfully retrieved from the database
            
            for document in querySnapshot!.documents {
                
                // Each document is an expert who has the corresponding specialization. We need to send the application to the expert now.
                let data = document.data()
                let expertUid = data["uid"] as! String
                let expertStopReceiveApplications = data["stopReceiveApplications"] as! Bool
                
                // To prevent sending the application to ownself
                if expertUid == applicationForm.userUid {
                    continue
                }
                
                // To prevent sending the application to experts who turned on "stopReceiveApplications"
                if expertStopReceiveApplications {
                    continue
                }
                
                let expertRef = usersRef.document(expertUid)
                
                // Add the current application uid to the expert's application list
                expertRef.updateData([
                    "applicationsUidList": FieldValue.arrayUnion([applicationRef.documentID])
                ]) { (error) in
                    
                    guard error == nil else {
                        print("Error updating expert's application list: \(error!.localizedDescription)")
                        return
                    }
                    
                    print("Successfully updated expert's application list")
                    
                    // Now update the expert's inboxApplication
                    let expertInboxApplicationDocRef = inboxApplicationsRef.document(expertUid)
                    
                    let newApplicationUidKey = "applicationsUidToUserFullNameMap." + applicationRef.documentID
                    
                    expertInboxApplicationDocRef.updateData([
                        "applicationsUidList" : FieldValue.arrayUnion([applicationRef.documentID]),
                        newApplicationUidKey : applicationForm.userFullName
                    ]) { [weak self] error in
                        
                        guard let strongSelf = self else {
                            return
                        }
                        
                        guard error == nil else {
                            print("Error updating inbox application of expert: \(error!.localizedDescription)")
                            return
                        }
                        print("Successfully updated inbox application of expert")
                        
                        let newNotification =
                            MyNotification(byUserUid: applicationForm.userUid,
                                           byUserFullName: applicationForm.userFullName,
                                           category: "newApplication",
                                           date: Date(),
                                           applicationUid: applicationRef.documentID)
                        
                        strongSelf.uploadNewNotification(for: expertUid, with: newNotification) { uploadedNewNotification in
                            
                            guard uploadedNewNotification else {
                                print("Error uploading new applciation notification for expert")
                                return
                            }
                        }
                        
                    }
                    
                }
                
                // Update the list of experts the application has been sent to
                expertsUidList.append(expertUid)
            }
            
            // testing
            if expertsUidList.count == 0 {
                print("There are currently no experts with the corresponding specialization. Please submit an application later.")
                completion(.failure(SendApplicationErrors.NoExpertWithSpecialization), applicationRef.documentID)
                return
            }
            
            completion(.success(expertsUidList), applicationRef.documentID)
        }
    }
    
    /// Create a new application
    public func createNewApplication(userUid: String, applicationUid: String, data: [String : Any], completion: @escaping ((Bool) -> Void)) {
        
        // Create a new application in the database
        let applicationRef = firestore.collection("applications").document(applicationUid)
        
        // Store the application in the database
        applicationRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error saving application details!")
                completion(false)
                return
            }
            
            // No error in storing application to database
            print("Done storing application details to database")
            strongSelf.updateMyApplicationsList(for: userUid, applicationUid: applicationUid) { updatedMyApplicationsList in
                
                guard updatedMyApplicationsList else {
                    completion(false)
                    return
                }
                
                strongSelf.updateHasApplication(for: userUid) { updatedHasApplication in
                    
                    guard updatedHasApplication else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
                
            }
        }
        
    }
    
    private func updateMyApplicationsList(for userUid: String, applicationUid: String, completion: @escaping ((Bool) -> Void)) {
        // Update myApplications list of current user
        let myApplicationRef = firestore.collection("myApplications").document(userUid)
        
        let applicationsUidToStatusKey = "applicationsUidToStatusMap." + applicationUid
        
        myApplicationRef.updateData([
            "applicationsUidList" : FieldValue.arrayUnion([applicationUid]),
            applicationsUidToStatusKey : "Pending"
        ]) { (error) in
            guard error == nil else {
                print("Error updating myApplications list: \(error!.localizedDescription)")
                completion(false)
                return
            }
            print("Updated myApplications list successfully")
            completion(true)
        }
    }
    
    private func updateHasApplication(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update data of current user to indicate that there is a pending application
        let docRef = firestore.collection("users").document(userUid)
        
        docRef.updateData(["hasApplication": true]) { (error) in
            guard error == nil else {
                print("Error updating user application status: \(error!.localizedDescription)")
                completion(false)
                return
            }
            print("Updated user application status successfully")
            completion(true)
        }
    }
    
    
    // MARK: - Upload New Review Methods
    
    /// Uploads new review to Firestore
    public func uploadNewReview(application: MSUserApplication, rating: Double, feedback: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update review to database
        let newReviewRef = firestore.collection("reviews").document()
        
        let timestamp = Timestamp()
        
        let data: [String : Any] = [
            "reviewUid" : newReviewRef.documentID,
            "expertUid" : application.matchedExpertUid!,
            "userUid" : application.userUid,
            "userFullName" : application.userFullName,
            "ratings" : rating,
            "feedback" : feedback,
            "timestamp" : timestamp
        ]
        
        newReviewRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error saving review details: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing review to database
            print("Done storing review details to database")
            strongSelf.updateMyReviews(application: application, reviewUid: newReviewRef.documentID, rating: rating, feedback: feedback, timestamp: timestamp) { updatedMyReview in
                
                guard updatedMyReview else {
                    completion(false)
                    return
                }
                
                strongSelf.updateExpertTotalRatingsAndTotalReviews(application: application, rating: rating) { updatedExpertTotalRatingsAndTotalReviews in
                    
                    guard updatedExpertTotalRatingsAndTotalReviews else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.updateHasUserSubmittedReview(application: application) { updatedHasUserSubmittedReview in
                        
                        guard updatedHasUserSubmittedReview else {
                            completion(false)
                            return
                        }
                        
                        let newNotification =
                            MyNotification(byUserUid: application.userUid,
                                           byUserFullName: application.userFullName,
                                           category: "review",
                                           date: Date(),
                                           reviewUid: newReviewRef.documentID)
                        
                        strongSelf.uploadNewNotification(for: application.matchedExpertUid!, with: newNotification) { uploadedNewNotification in
                            
                            guard uploadedNewNotification else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                        
                    }
                }
            }
        }
    }
    
    private func updateMyReviews(application: MSUserApplication, reviewUid: String, rating: Double, feedback: String, timestamp: Timestamp, completion: @escaping ((Bool) -> Void)) {
        
        // Update myReviews list of expert
        let expertMyReviewsRef = firestore.collection("myReviews").document(application.matchedExpertUid!)
        
        var shortenedFeedback: String
        if feedback.count > 50 {
            shortenedFeedback = String(feedback.prefix(50)) + "..."
        } else {
            shortenedFeedback = feedback
        }
        
        let reviewsUidToRatingsMapKey = "reviewsUidToRatingsMap." + reviewUid
        let reviewsUidToUserUidMapKey = "reviewsUidToUserUidMap." + reviewUid
        let reviewsUidToUserFullNameMapKey = "reviewsUidToUserFullNameMap." + reviewUid
        let reviewsUidToTimestampMapKey = "reviewsUidToTimestampMap." + reviewUid
        let reviewsUidToUShortenedFeedbackMapKey = "reviewsUidToUShortenedFeedbackMap." + reviewUid
        
        expertMyReviewsRef.updateData([
            "reviewsUidList" : FieldValue.arrayUnion([reviewUid]),
            reviewsUidToRatingsMapKey : rating,
            reviewsUidToUserUidMapKey : application.userUid,
            reviewsUidToUserFullNameMapKey : application.userFullName,
            reviewsUidToTimestampMapKey : timestamp,
            reviewsUidToUShortenedFeedbackMapKey: shortenedFeedback
            
        ]) { (error) in
            guard error == nil else {
                print("Error updating expert's myReviews list: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated expert's myReviews list successfully")
            completion(true)
        }
        
    }
    
    private func updateExpertTotalRatingsAndTotalReviews(application: MSUserApplication, rating: Double, completion: @escaping ((Bool) -> Void)) {
        
        // Update expert's total rating and total reviews
        let expertDocRef = firestore.collection("users").document(application.matchedExpertUid!)
        
        expertDocRef.updateData([
            "totalRatings" : FieldValue.increment(rating),
            "totalReviews" : FieldValue.increment(Int64(1))
        ]) { (error) in
            guard error == nil else {
                print("Error updating expert's total ratings/reviews: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated expert's total ratings/reviews successfully")
            completion(true)
        }
    }
        
    private func updateHasUserSubmittedReview(application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        // Update application's hasUserSubmittedReview property to true, so that user can only review the expert once
        let applicationRef = firestore.collection("applications").document(application.applicationUid!)
        
        applicationRef.updateData([
            "hasUserSubmittedReview" : true
        ]) { (error) in
            guard error == nil else {
                print("Error updating hasUserSubmittedReview: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated hasUserSubmittedReview successfully")
            completion(true)
        }
        
    }
    
    
    // MARK: - Upload New Report Methods
    
    /// Uploads new report to Firestore
    public func uploadNewReport(application: MSUserApplication, data: [String: Any], completion: @escaping ((Bool) -> Void)) {
        
        let reportRef = firestore.collection("reports").document()
        let reportedUserUid = data["reportedUserUid"] as! String
        
        reportRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error saving report details: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully saved report details to database")
            
            strongSelf.updateTotalReportCount(userUid: reportedUserUid) { updatedTotalReportCount in
                
                guard updatedTotalReportCount else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    /// Update totalReportCount of the reported user
    public func updateTotalReportCount(userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let reportedUserDocRef = firestore.collection("users").document(userUid)
        
        reportedUserDocRef.updateData([
            "totalReportCount" : FieldValue.increment(Int64(1))
        ]) { error in
            
            guard error == nil else {
                print("Error updating totalReportCount data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Updated database successfully
            print("Updated totalReportCount successfully")
            completion(true)
        }
    }
    
    
    // MARK: - Update stopReceivingApplication Method
    
    /// Updates the stopReceivingApplications status for expert to Firestore
    public func updateStopReceivingApplications(for userUid: String, isSwitchOn: Bool, completion: @escaping ((Bool) -> Void)) {
        
        let docRef = firestore.collection("users").document(userUid)
        
        if isSwitchOn {
            
            docRef.updateData([
                "stopReceiveApplications" : true
            ]) { (error) in
                guard error == nil else {
                    print("Error updating stopReceiveApplications: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully updated stopReceiveApplications")
                completion(true)
            }
            
            
        } else {
            
            docRef.updateData([
                "stopReceiveApplications" : false
            ]) { (error) in
                guard error == nil else {
                    print("Error updating stopReceiveApplications: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully updated stopReceiveApplications")
                completion(true)
            }
        }
    }
    
    
    // MARK: - Update Specializations Methods
    
    /// Updates the specializations of the expert to Firestore
    public func updateSpecializations(for userUid: String, specializationsList: [String], completion: @escaping ((Bool) -> Void)) {
        
        // Update the database after expert is done updating specializations
        let docRef = firestore.collection("users").document(userUid)
        
        docRef.updateData(["specializations": specializationsList]) { (error) in
            guard error == nil else {
                print("Error updating user specialization data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated specializations successfully to firebase")
            completion(true)
            
        }
    }
    
    
    // MARK: - Expert Confirm Match Methods
    
    /// Confirm a match between a user and an expert
    public func confirmMatch(expertUid: String, expertFullName: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let chatsRef = firestore.collection("chats")
        
        // Create a new chat in the database
        let chatRef = chatsRef.document()
        
        // Data to be stored to the chat (note that the subcollection messages is not added at this point in time because there are no messages yet)
        let data: [String : Any] = [
            "chatUid" : chatRef.documentID,
            "userUid" : userUid,
            "expertUid" : expertUid,
        ]
        
        // Store the chat in the database
        chatRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                //Show error message
                print("Error saving new chat: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing chat to database
            print("Done storing a new chat to database")
            strongSelf.removeApplicationFromInboxAfterMatch(expertUid: expertUid, userUid: userUid, application: application) { haveRemovedApplicationFromInbox in
                
                guard haveRemovedApplicationFromInbox else {
                    completion(false)
                    return
                }
                
                strongSelf.updateMyApplicationsStatusAfterMatch(expertUid: expertUid, userUid: userUid, application: application) { updatedMyApplicationsStatus in
                    
                    guard updatedMyApplicationsStatus else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.updateApplicationStatusAfterMatch(expertUid: expertUid, expertFullName: expertFullName, userUid: userUid, application: application) { updatedApplicationStatus in
                        
                        guard updatedApplicationStatus else {
                            completion(false)
                            return
                        }
                        
                        strongSelf.updateChatsListAfterMatch(expertUid: expertUid, expertFullName: expertFullName, userUid: userUid, application: application, chatUid: chatRef.documentID) { updatedChatsList in
                            
                            guard updatedChatsList else {
                                completion(false)
                                return
                            }
                            
                            let newNotification =
                                MyNotification(byUserUid: expertUid,
                                               byUserFullName: expertFullName,
                                               category: "match",
                                               date: Date(),
                                               applicationUid: application.applicationUid!)
                            
                            strongSelf.uploadNewNotification(for: application.userUid, with: newNotification) { uploadedNewNotification in
                                
                                guard uploadedNewNotification else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            }
                            
                        }   
                    }
                }
            }
        }
    }
    
    /// Remove the application from other expert's inbox
    private func removeApplicationFromInboxAfterMatch(expertUid: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        
        // Create a query to find out which inboxApplication has the corresponding application
        let inboxApplicationsRef = firestore.collection("inboxApplications")
        let query = inboxApplicationsRef
            .whereField("applicationsUidList", arrayContains: application.applicationUid!)
        
        query.getDocuments { [weak self] querySnapshot, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error executing query: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Documents successfully retrieved from the database
            
            // Create a new write batch
            let batch = strongSelf.firestore.batch()
            
            for document in querySnapshot!.documents {
                
                // Each document is an inboxApplication of an expert who has the corresponding application. We need to remove the application from the inbox now.
                
                let data = document.data()
                let inboxExpertUid = data["expertUid"] as! String
                let mapKey = "applicationsUidToUserFullNameMap." + application.applicationUid!
                
                // Not removing the application from the current expert who is matched
                if inboxExpertUid != expertUid {
                    
                    batch.updateData([
                        "applicationsUidList" : FieldValue.arrayRemove([application.applicationUid!]),
                        mapKey : FieldValue.delete()
                    ], forDocument: document.reference)
                                
                }
                
            }
            
            // Commit the batch
            batch.commit { error in
                
                guard error == nil else {
                    print("Error committing batch")
                    completion(false)
                    return
                }
                
                print("Successfully committed  batch")
                completion(true)
                
            }
        }
    }
    
    /// Update status of myApplications of user
    private func updateMyApplicationsStatusAfterMatch(expertUid: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let userMyApplicationRef = firestore.collection("myApplications").document(application.userUid)
        
        let applicationUidToStatusKey = "applicationsUidToStatusMap." + application.applicationUid!
        
        userMyApplicationRef.updateData([
            applicationUidToStatusKey : "Matched"
        ]) { (error) in
            guard error == nil else {
                print("Error updating user's myApplications list: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated user's myApplications list")
            completion(true)
        }
    }
        
    /// Update application status to "Matched" and matchedExpertUid of application document
    private func updateApplicationStatusAfterMatch(expertUid: String, expertFullName: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let applicationRef = firestore.collection("applications").document(application.applicationUid!)
        
        applicationRef.updateData([
            "applicationStatus" : "Matched",
            "matchedExpertUid" : expertUid,
            "matchedExpertFullName" : expertFullName
        ]) { error in
            guard error == nil else {
                print("Error updating application status and matchedExpert info: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated application status and matchedExpert info")
            completion(true)
        }
    }
                
    /// Update both the expert's and user's chatsList
    private func updateChatsListAfterMatch(expertUid: String, expertFullName: String, userUid: String, application: MSUserApplication, chatUid: String, completion: @escaping ((Bool) -> Void)) {
        
        
        let chatsListRef = firestore.collection("chatsList")
        let expertChatsListRef = chatsListRef.document(expertUid)
        let userChatsListRef = chatsListRef.document(userUid)
        
        let expertMatchedPartnerUidToNameKey = "matchedPartnersUidToNameMap." + userUid
        let expertMatchedPartnerUidToChatUidKey = "matchedPartnersUidToChatUidMap." + userUid
        
        expertChatsListRef.updateData([
            "matchedPartnersUidList" : FieldValue.arrayUnion([application.userUid]),
            expertMatchedPartnerUidToNameKey : application.userFullName,
            expertMatchedPartnerUidToChatUidKey : chatUid
        ]) { (error) in
            guard error == nil else {
                print("Error updating chatsList of expert: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated chatsList of expert")
            
            
            let userMatchedPartnerUidToNameKey = "matchedPartnersUidToNameMap." + expertUid
            let userMatchedPartnerUidToChatUidKey = "matchedPartnersUidToChatUidMap." + expertUid
            
            userChatsListRef.updateData([
                "matchedPartnersUidList" : FieldValue.arrayUnion([expertUid]),
                userMatchedPartnerUidToNameKey : expertFullName,
                userMatchedPartnerUidToChatUidKey : chatUid
            ]) { (error) in
                guard error == nil else {
                    print("Error updating chatsList of user: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully updated chatsList of user")
                completion(true)
            }
        }
    }
        
    
    // MARK: - Expert Mark Application As Complete Methods
    
    /// Mark an application as completed
    public func markComplete(expertUid: String, expertFullName: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        // Remove application from matched expert
        let inboxApplicationRef = firestore.collection("inboxApplications").document(expertUid)
        
        let applicationUidToUserFullNameKey = "applicationsUidToUserFullNameMap." + application.applicationUid!
        
        inboxApplicationRef.updateData([
            "applicationsUidList" : FieldValue.arrayRemove([application.applicationUid!]),
            applicationUidToUserFullNameKey : FieldValue.delete()
        ]) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error updating inboxApplications list: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            strongSelf.removeFromChatsListAfterMarkComplete(expertUid: expertUid, userUid: userUid, application: application) { removedFromChatsList in
                
                guard removedFromChatsList else {
                    completion(false)
                    return
                }
                
                strongSelf.updateMyApplicationsAfterMarkComplete(expertUid: expertUid, userUid: userUid, application: application) { updatedMyApplications in
                    
                    guard updatedMyApplications else {
                        completion(false)
                        return
                    }
                    
                    strongSelf.updateApplicationAfterMarkComplete(expertUid: expertUid, userUid: userUid, application: application) { updatedApplication in
                        
                        guard updatedApplication else {
                            completion(false)
                            return
                        }
                        
                        let newNotification =
                            MyNotification(byUserUid: expertUid,
                                           byUserFullName: expertFullName,
                                           category: "markComplete",
                                           date: Date(),
                                           applicationUid: application.applicationUid!)
                        
                        strongSelf.uploadNewNotification(for: userUid, with: newNotification) { uploadedNewNotification in
                            
                            guard uploadedNewNotification else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        }
                    }
                }
            }
        }
    }
    
    /// Remove user from expert's chatsList and remove expert from user's chatsList
    public func removeFromChatsListAfterMarkComplete(expertUid: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let expertChatsListRef = firestore.collection("chatsList").document(expertUid)
        let userChatsListRef = firestore.collection("chatsList").document(userUid)
        
        
        let expertMatchedPartnerUidToNameKey = "matchedPartnersUidToNameMap." + userUid
        let expertMatchedPartnerUidToChatUidKey = "matchedPartnersUidToChatUidMap." + userUid
        
        expertChatsListRef.updateData([
            "matchedPartnersUidList" : FieldValue.arrayRemove([userUid]),
            expertMatchedPartnerUidToNameKey : FieldValue.delete(),
            expertMatchedPartnerUidToChatUidKey : FieldValue.delete()
        ]) { (error) in
            guard error == nil else {
                print("Error updating chatsList of expert: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated chatsList of expert")
            
            let userMatchedPartnerUidToNameKey = "matchedPartnersUidToNameMap." + expertUid
            let userMatchedPartnerUidToChatUidKey = "matchedPartnersUidToChatUidMap." + expertUid
            
            userChatsListRef.updateData([
                "matchedPartnersUidList" : FieldValue.arrayRemove([expertUid]),
                userMatchedPartnerUidToNameKey : FieldValue.delete(),
                userMatchedPartnerUidToChatUidKey : FieldValue.delete()
            ]) { (error) in
                guard error == nil else {
                    print("Error updating chatsList of user: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully updated chatsList of user")
                completion(true)
            }
        }
    }
        
    /// Update status of myApplications of user who submitted the application
    public func updateMyApplicationsAfterMarkComplete(expertUid: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let userMyApplicationRef = firestore.collection("myApplications").document(userUid)
        
        let applicationUidToStatusKey = "applicationsUidToStatusMap." + application.applicationUid!
        
        userMyApplicationRef.updateData([
            applicationUidToStatusKey : "Completed"
        ]) { (error) in
            guard error == nil else {
                print("Error updating user's myApplications list: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated user's myApplications list")
            completion(true)
        }
    }
    
    /// Update application status of application document to "Completed"
    public func updateApplicationAfterMarkComplete(expertUid: String, userUid: String, application: MSUserApplication, completion: @escaping ((Bool) -> Void)) {
        
        let applicationRef = firestore.collection("applications").document(application.applicationUid!)
        
        applicationRef.updateData([
            "applicationStatus" : "Completed"
        ]) { (error) in
            guard error == nil else {
                print("Error updating application status: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully updated application status")
            completion(true)
        }
    }
    
    
    // MARK: - Upload New Forum Post Methods
    
    /// Uploads a new forum post
    public func uploadNewForumPost(with data: [String: Any], completion: @escaping ((Bool) -> Void)) {
        
        let forumDocRef = firestore.collection("forum").document()
        let posterUid = data["posterUid"] as! String
        
        var dataWithDocumentID = data
        dataWithDocumentID["forumPostUid"] = forumDocRef.documentID
        
        forumDocRef.setData(dataWithDocumentID) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // There is an error saving forum data in the database
                print("Error saving forum data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // No error in storing data to database
            print("Successfully stored forum data")
            strongSelf.updateTotalForumPostCount(for: posterUid) { updatedTotalForumPostCount in
                
                guard updatedTotalForumPostCount else {
                    completion(false)
                    return
                }
                
                completion(true)
                
            }
                
        }
            
    }
        
    /// Update totalForumPostCount of user
    private func updateTotalForumPostCount(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let posterDocRef = firestore.collection("users").document(userUid)
        
        posterDocRef.updateData([
            "totalForumPostCount" : FieldValue.increment(Int64(1))
        ]) { error in
            guard error == nil else {
                print("Error updating totalForumPostCount data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // Updated database successfully
            print("Updated totalForumPostCount successfully")
            completion(true)
        }
    }
    
    
    // MARK: - Upload New Forum Reply Methods
    
    /// Uploads a new forum reply
    public func uploadNewForumReply(forumPost: ForumPost, with data: [String: Any], completion: @escaping ((Bool) -> Void)) {
        
        let forumPostUid = forumPost.forumPostUid
        
        let forumReplyDocRef = firestore.collection("forum").document(forumPostUid).collection("replies").document()
        
        let replyPosterUid = data["userUid"] as! String
        let replyPosterFullName = data["userFullName"] as! String
        
        var dataWithDocumentID = data
        dataWithDocumentID["forumReplyUid"] = forumReplyDocRef.documentID
        
        forumReplyDocRef.setData(dataWithDocumentID) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // There is an error saving forum data in the database
                print("Error saving forum reply data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // No error in storing data to database
            print("Successfully stored forum reply data")
            strongSelf.updateTotalForumReplyCount(for: replyPosterUid) { updatedTotalForumReplyCount in
                
                guard updatedTotalForumReplyCount else {
                    completion(false)
                    return
                }
                
                // If the user replying is the original poster, then do not send the notification to himself
                guard forumPost.posterUid != replyPosterUid else {
                    completion(true)
                    return
                }
                
                let newNotification = MyNotification(byUserUid: replyPosterUid,
                                                     byUserFullName: replyPosterFullName,
                                                     category: "reply",
                                                     date: Date(),
                                                     forumPostUid: forumPostUid)
                
                strongSelf.uploadNewNotification(for: forumPost.posterUid, with: newNotification) { uploadedNewNotification in
                    
                    guard uploadedNewNotification else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                }
            }
        }
    }
        
    /// Update totalForumReplyCount of user
    private func updateTotalForumReplyCount(for userUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let posterDocRef = firestore.collection("users").document(userUid)
        
        posterDocRef.updateData([
            "totalForumReplyCount" : FieldValue.increment(Int64(1))
        ]) { (error) in
            guard error == nil else {
                print("Error updating totalForumReplyCount data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // Updated database successfully
            print("Updated totalForumReplyCount successfully")
            completion(true)
        }
        
    }
    
    
    
    // MARK: - Upload New Bookmarked Forum Post Method
    
    /// Uploads a new bookmark forum post
    public func uploadNewBookmarkForumPost(for userUid: String, forumPost: ForumPost, completion: @escaping ((Bool) -> Void)) {
        
        let myForumBookmarkRef = firestore.collection("myForumBookmarks").document(userUid)

        let forumPostUidToTitleMapKey = "forumPostUidToTitleMap." + forumPost.forumPostUid

        myForumBookmarkRef.updateData([
            "forumPostUidList" : FieldValue.arrayUnion([forumPost.forumPostUid]),
            forumPostUidToTitleMapKey: forumPost.title
        ]) { error in

            guard error == nil else {
                print("Error adding bookmark for forum post: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated bookmark for forum post successfully")
            completion(true)
            
        }
        
    }
    
    
    // MARK: - Upvote/Downvote Methods
    
    /// Update the total upvotes for the forum post
    public func upvoteButtonTappedForForumPost(by userUid: String, forumPost: ForumPost, completion: @escaping ((Bool) -> Void)) {
        
        let forumPostUid = forumPost.forumPostUid
        let forumPostRef = firestore.collection("forum").document(forumPostUid)
        
        forumPostRef.updateData([
            "upvotes" : forumPost.upvotes,
            "upvotedUsersUidList" : FieldValue.arrayUnion([userUid])
        ]) { error in
            
            guard error == nil else {
                print("Error updating upvotes data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Updated upvotes successfully")
            completion(true)
            
        }
    }
    
    /// Update totalUpvoteCount and add a new notification for the original poster
    public func updateTotalUpvoteCount(userUid: String, userFullName: String, for posterUid: String, forumPostUid: String, completion: @escaping ((Bool) -> Void)) {
        
        let posterDocRef = firestore.collection("users").document(posterUid)
        
        posterDocRef.updateData([
            "totalUpvoteCount" : FieldValue.increment(Int64(1))
        ]) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error updating totalUpvoteCount data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Updated database successfully
            print("Updated totalUpvoteCount successfully")
            
            let newNotification = MyNotification(byUserUid: userUid,
                                                 byUserFullName: userFullName,
                                                 category: "upvote",
                                                 date: Date(),
                                                 forumPostUid: forumPostUid)
            
            strongSelf.uploadNewNotification(for: posterUid, with: newNotification) { uploadedNewNotification in
                
                guard uploadedNewNotification else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    /// Update the total downvotes for the forum post
    public func downvoteButtonTappedForForumPost(by userUid: String, forumPost: ForumPost, completion: @escaping ((Bool) -> Void)) {
        
        let forumPostUid = forumPost.forumPostUid
        let forumPostRef = firestore.collection("forum").document(forumPostUid)
        
        forumPostRef.updateData([
            "downvotes" : forumPost.downvotes,
            "downvotedUsersUidList" : FieldValue.arrayUnion([userUid])
        ]) { error in
            
            guard error == nil else {
                print("Error updating downvotes data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            // Updated database successfully
            print("Updated downvotes successfully")
            completion(true)
        }
    }
    
    /// Update totalDownvoteCount and add a new notification for  the original poster
    public func updateTotalDownvoteCount(userUid: String, userFullName: String, for posterUid: String, forumPostUid: String, completion: @escaping ((Bool) -> Void)) {
        
        // Update totalDownvoteCount of the original poster
        let posterDocRef = firestore.collection("users").document(posterUid)
        
        posterDocRef.updateData([
            "totalDownvoteCount" : FieldValue.increment(Int64(1))
        ]) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error updating totalDownvoteCount data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // Updated database successfully
            print("Updated totalDownvoteCount successfully")
            
            let newNotification = MyNotification(byUserUid: userUid,
                                                 byUserFullName: userFullName,
                                                 category: "downvote",
                                                 date: Date(),
                                                 forumPostUid: forumPostUid)
            
            strongSelf.uploadNewNotification(for: posterUid, with: newNotification) { uploadedNewNotification in
                
                guard uploadedNewNotification else {
                    completion(false)
                    return
                }
                
                completion(true)
            }
        }
    }
    
    /// Update the total upvotes for the forum reply
    public func upvoteButtonTappedForForumReply(by userUid: String, forumPostUid: String, forumReply: ForumReply, completion: @escaping ((Bool) -> Void)) {
        
        let forumReplyUid = forumReply.forumReplyUid
        
        let forumReplyRef = firestore.collection("forum").document(forumPostUid).collection("replies").document(forumReplyUid)
        
        forumReplyRef.updateData([
            "upvotes" : forumReply.upvotes,
            "upvotedUsersUidList" : FieldValue.arrayUnion([userUid])
        ]) { error in
            
            guard error == nil else {
                print("Error updating reply upvotes data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // Updated database successfully
            print("Updated reply upvotes successfully")
            completion(true)
        }
    }
    
    /// Update the total downvotes for the forum reply
    public func downvoteButtonTappedForForumReply(by userUid: String, forumPostUid: String, forumReply: ForumReply, completion: @escaping ((Bool) -> Void)) {
        
        let forumReplyUid = forumReply.forumReplyUid
        
        let forumReplyRef = firestore.collection("forum").document(forumPostUid).collection("replies").document(forumReplyUid)
        
        forumReplyRef.updateData([
            "downvotes" : forumReply.downvotes,
            "downvotedUsersUidList" : FieldValue.arrayUnion([userUid])
        ]) { error in
            
            guard error == nil else {
                print("Error updating reply downvotes data: \(error!.localizedDescription)")
                completion(false)
                return
            }
            // Updated database successfully
            print("Updated reply downvotes successfully")
            completion(true)
        }
    }
    
    
    // MARK: - Upload New Forum Report Methods
    
    /// Uploads new forum report to Firestore
    public func uploadNewForumReport(with data: [String: Any], completion: @escaping ((Bool) -> Void)) {
        
        let forumReportsRef = firestore.collection("forumReports").document()
        let reportedUserUid = data["reportedUserUid"] as! String
        
        forumReportsRef.setData(data) { [weak self] error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Error saving forum report details: \(error!.localizedDescription)")
                completion(false)
                return
            }
            
            print("Successfully saved forum report details to database")
            
            strongSelf.updateTotalReportCount(userUid: reportedUserUid) { updatedTotalReportCount in
                
                guard updatedTotalReportCount else {
                    completion(false)
                    return
                }
                completion(true)
            }
        }
    }
    
    
    // MARK: - Upload New Notification Methods
    
    /// Uploads new notification to Firestore
    public func uploadNewNotification(for userUid: String, with notification: MyNotification, completion: @escaping ((Bool) -> Void)) {
        
        let notificationRef = firestore.collection("myNotifications").document(userUid).collection("notifications").document()
        
        switch notification.category {
        case "upvote", "downvote", "reply":
            
            notificationRef.setData([
                "byUserUid" : notification.byUserUid,
                "byUserFullName" : notification.byUserFullName,
                "category" : notification.category,
                "timestamp" : Timestamp(date: notification.date),
                "forumPostUid" : notification.forumPostUid!
            ]) { (error) in
                guard error == nil else {
                    print("Error saving new notification details: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully saved new notification (upvote/downvote/reply) details to database")
                completion(true)
            }
            
        case "match", "markComplete", "newApplication":
            
            notificationRef.setData([
                "byUserUid" : notification.byUserUid,
                "byUserFullName" : notification.byUserFullName,
                "category" : notification.category,
                "timestamp" : Timestamp(date: notification.date),
                "applicationUid" : notification.applicationUid!
            ]) { (error) in
                guard error == nil else {
                    print("Error saving new notification details: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully saved new notification (match/markComplete/newApplication) details to database")
                completion(true)
            }
            
        case "review":
            
            notificationRef.setData([
                "byUserUid" : notification.byUserUid,
                "byUserFullName" : notification.byUserFullName,
                "category" : notification.category,
                "timestamp" : Timestamp(date: notification.date),
                "reviewUid" : notification.reviewUid!
            ]) { (error) in
                guard error == nil else {
                    print("Error saving new notification details: \(error!.localizedDescription)")
                    completion(false)
                    return
                }
                
                print("Successfully saved new notification (review) details to database")
                completion(true)
            }
            
        default:
            print("Error with notification category, not saving notification to database!")
        }
        
        
        
    }
    
}


//
//  UserManager.swift
//  FirebaseLearnNickSarnoTutorial
//
//  Created by Dostan Turlybek on 27.08.2025.
//
import Foundation
import FirebaseFirestore
import FirebaseFirestoreCombineSwift

struct Movie: Codable {
    let id: String
    let title: String
    let isPopular: Bool
}

struct DBUser: Codable {
    let userId: String
    let isAnonymous: Bool?
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    let isPremium: Bool?
    let preferences: [String]?
    let favoriteMovie: Movie?
    
    init(authData: AuthDataResultModel, isPremium: Bool? = false) {
        self.userId = authData.uid
        self.isAnonymous = authData.isAnonymous
        self.email = authData.email
        self.photoUrl = authData.photoURL
        self.dateCreated = Date()
        self.isPremium = isPremium
        self.preferences = nil
        self.favoriteMovie = nil
    }
    
    init(userID: String, isAnonymous: Bool?, email: String?, photoURL: String?, dateCreated: Date?, isPremium: Bool? = false, preferences: [String]?, favoriteMovie: Movie? ) {
        self.userId = userID
        self.isAnonymous = isAnonymous
        self.email = email
        self.photoUrl = photoURL
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.preferences = preferences
        self.favoriteMovie = favoriteMovie
    }
    
//    func tooglePremiumStatus() -> DBUser{
//        return DBUser(
//            userID: userId,
//            isAnonymous: isAnonymous,
//            email: email,
//            photoURL: photoURL,
//            dateCreated: dateCreated,
//            isPremium: isPremium == false
//        )
//    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.isAnonymous = try container.decodeIfPresent(Bool.self, forKey: .isAnonymous)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.photoUrl = try container.decodeIfPresent(String.self, forKey: .photoUrl)
        self.dateCreated = try container.decodeIfPresent(Date.self, forKey: .dateCreated)
        self.isPremium = try container.decodeIfPresent(Bool.self, forKey: .isPremium)
        self.preferences = try container.decodeIfPresent([String].self, forKey: .preferences)
        self.favoriteMovie = try container.decodeIfPresent(Movie.self, forKey: .favoriteMovie)
    }
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userId, forKey: .userId)
        try container.encodeIfPresent(self.isAnonymous, forKey: .isAnonymous)
        try container.encodeIfPresent(self.email, forKey: .email)
        try container.encodeIfPresent(self.photoUrl, forKey: .photoUrl)
        try container.encodeIfPresent(self.dateCreated, forKey: .dateCreated)
        try container.encodeIfPresent(self.isPremium, forKey: .isPremium)
        try container.encodeIfPresent(self.preferences, forKey: .preferences)
        try container.encodeIfPresent(self.favoriteMovie, forKey: .favoriteMovie)
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case isAnonymous = "is_anonymous"
        case email = "email"
        case photoUrl = "photo_url"
        case dateCreated = "date_created"
        case isPremium = "user_is_premium"
        case preferences = "preferences"
        case favoriteMovie = "favorite_movie"
    }
    
    
}

final class UserManager {
    
    static let shared = UserManager()
    private init() {}
    
    private let userCollection: CollectionReference = Firestore.firestore().collection("users")
    
    private func userDocument(userID: String) async throws -> DocumentReference{
        userCollection.document(userID)
    }
    
    private let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    private let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    
    func createNewUser(user: DBUser) async throws {
        try await userDocument(userID: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws{
//        var userData: [String:Any] = [
//            "user_id": auth.uid,
//            "is_anonymous": auth.isAnonymous,
//            "date_created" : Timestamp()
//        ]
//        
//        if let email = auth.email {
//            userData["email"] = email
//        }
//        
//        if let photoURL = auth.photoURL {
//            userData["photo_url"] = photoURL
//        }
//        
//        try await userDocument(userID: auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userID: String) async throws -> DBUser {
        try await userDocument(userID: userID).getDocument(as: DBUser.self)
    }
    func updateUserPremiumStatus(user: DBUser) async throws {
        try await userDocument(userID: user.userId).setData(from: user, merge: true)
    }
    func updateUserPremiumStatus(user: DBUser, isPremium: Bool) async throws {
        
        var data: [String:Any] = [
            DBUser.CodingKeys.isPremium.rawValue : isPremium
        ]
        
        try await userDocument(userID: user.userId).updateData(data)
    }
//    func getUser(userID: String) async throws -> DBUser {
//        let snapshot = try await userDocument(userID: userID).getDocument()
//        
//        guard let data = snapshot.data(), let userID = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let isAnonymous = data["is_anonymous"] as? Bool
//        let email = data["email"] as? String
//        let photoURL = data["photo_url"] as? String
//        let dateCreated = data["date_created"] as? Date
//        
//        return DBUser(userID: userID, isAnonymous: isAnonymous, email: email, photoURL: photoURL, dateCreated: dateCreated)
//    }
    
    func addUserPreferences(userID: String, preference: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayUnion([preference])
        ]
        let _ = try await userDocument(userID: userID).updateData(data)
    }
    
    func removeUserPreferences(userID: String, preference: String) async throws {
        let data: [String: Any] = [
            DBUser.CodingKeys.preferences.rawValue : FieldValue.arrayRemove([preference])
        ]
        let _ = try await userDocument(userID: userID).updateData(data)
    }
    
    func addFavoriteMovie(userID: String, movie: Movie) async throws {
        guard let data = try? encoder.encode(movie) else {
            throw URLError(.badURL)
        }
        let dict: [String: Any] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : data
        ]
        let _ = try await userDocument(userID: userID).updateData(dict)
    }
    
    func removeFavoriteMovie(userID: String) async throws {
        let data: [String: Any?] = [
            DBUser.CodingKeys.favoriteMovie.rawValue : nil
        ]
        let _ = try await userDocument(userID: userID).updateData(data as [AnyHashable : Any])
    }
    
}

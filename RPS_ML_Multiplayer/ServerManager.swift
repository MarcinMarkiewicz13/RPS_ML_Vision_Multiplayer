//
//  ServerManager.swift
//  RPS_ML_Multiplayer
//
//  Created by Jakub Ruranski on 10/07/2023.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseCore


class ServerManager: ObservableObject {
    @Published var signedIn = false
    @Published var onlinePlayers: [Opponent] = []
    
    @Published var selectedOpponent: Opponent? = nil
    
    private var user: User?
    
    private var ref: DatabaseReference?
    
    init() {
//        ref = Database.database().reference()
      let url =  readLinkFromPlist()
        print(url)
       ref = Database.database(url: url).reference()

        user = nil
        tryLogin()
        validatePlayerExistsInBackround()
        
        fetchAllOnlinePlayers { opponents in
            
            self.onlinePlayers = opponents
        }
        
    }
    
    init(user: User) {
        ref = Database.database().reference()
        self.user = user
        
    }
    
    func passDbReference() -> DatabaseReference {
        return ref ?? Database.database().reference()
    }
    
    func isSignedIn() -> Bool {
        
            return user != nil && signedIn
        
    }
    
    
    private func readLinkFromPlist() -> String {
        var link = ""
        print("reading link")
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {return "no bundle"}
        
        let url = URL(fileURLWithPath: path)
        do {
            let data = try Data(contentsOf: url)
            guard let plist = try PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [String: Any] else {
                       return "error reading"
                   }
                   guard let link = plist["DB_LINK"] as? String else {
                       return "DB_LINK not found"
                   }
                   print(link)
                   return link
            
        }catch let error {
            print(error.localizedDescription)
        }
        return link
    }
    
    
    func saveUser(user: User) {
        guard let ref = ref else {return}
        
        let userData: [String : Any] = [
            
            "username" : user.displayName ?? "Jack",
            "email" : user.email ?? "no_email",
            "playerOnline" : true,
            "wins" : 0
        ]
        
        ref.child("players").child(user.uid).setValue(userData) {error, refer  in
        
            if let error = error {
                print("Error saving user data \(error.localizedDescription)")
            }else{
                print("Saved user data successfully")
            }
        }
        self.user = user
    }
    
    
    func setOnlineStatus(isOnline: Bool) {
        guard let ref = ref else {return}
        guard let user = user else {return}
        guard UserDefaults.standard.bool(forKey: "userExists") else {
            print("user doesn't exist")
            return
        }
        ref.child("players/\(user.uid)/playerOnline").setValue(isOnline) { error, refer  in
            if let error = error {
                print("Error setting online status \(error.localizedDescription)")
            }else{
                print("Saved online status successfully \(isOnline)")
            }

        }
        // print("Saved online status \(isOnline)")
    }
    
    // Function will check whether the user is in the database and if not it will create a new user, save the result for later user in userdefaults
   private func validatePlayerExistsInBackround() {
        DispatchQueue.global(qos: .background).async { [weak self] in

        guard let self = self else {return}
        
        guard let ref = ref else {return}
        guard let user = user else {return}
        
        ref.child("players/\(user.uid)").observeSingleEvent(of: .value) { snapshot in
            if !snapshot.exists() {
                print("user doesn't exist")
                self.saveUser(user: user)
            }else{
                
                print("User exists in database")
            }
            UserDefaults.standard.set(true, forKey: "userExists")
        }
        }
    }

    
    
    
 private func fetchAllOnlinePlayers(completion: @escaping ([Opponent]) -> Void) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let ref = self?.ref else { return }
            guard let user = self?.user else {return}
            ref.child("players").observeSingleEvent(of: .value) { snapshot in
                var onlinePlayers: [Opponent] = []
                
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot,
                          let playerData = childSnapshot.value as? [String: Any],
                          let isOnline = playerData["playerOnline"] as? Bool,
                          let name = playerData["username"] as? String
                    else {
                        print("Error fetchin players")
                        continue
                    }
                    let uidString = childSnapshot.key
                    //if isOnline {
                    if uidString != user.uid {
                    let opponent = Opponent(name: name, uid: uidString, isOnline: isOnline)
                        
                        onlinePlayers.append(opponent)
                    }
                }
                
                // Return the result on the main queue
                DispatchQueue.main.async {
                    completion(onlinePlayers)
                }
            }
        }
    }
    
    

    
    func tryLogin() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let currentUser = user {
                self.user = currentUser
                self.signedIn = true
                let ud = UserDefaults.standard
                if ud.string(forKey: "username") == "" {
                    // add data to Core Data


                    ud.set(currentUser.email, forKey: "username")
                    ud.set(currentUser.displayName, forKey: "userDisplayName")
                    ud.set(currentUser.uid, forKey: "userID")
              
           
//                                                                }catch let error {
//                                                                    alertTitle = "Could not create an account"
//                                                                    alertMessage = error.localizedDescription
//                                                                    showAlertView.toggle()
//                                                                }
                    print("setting new user")
                }else{
                  
                    
                    print("user is signed in \(user?.uid ?? "no uid")")
                }
            }
        }
    }
    
    func logOut() {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        }catch {
            print("Sign out error \(error.localizedDescription)")
        }
        
        let ud = UserDefaults.standard
        ud.set("", forKey: "username")
        ud.set("", forKey: "userDisplayName")
        ud.set("", forKey: "userID")
    }
    
    
}

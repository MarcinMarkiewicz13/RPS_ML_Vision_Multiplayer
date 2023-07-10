//
//  HomeView.swift
//  RPS_ML_Multiplayer
//
//  Created by Jakub Ruranski on 07/07/2023.
//

import SwiftUI

struct HomeView: View {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var serverManager: ServerManager = ServerManager()
    
    @State var onlinePlayers: [OpponentModel] = [OpponentModel(name: "Jacek", id: UUID(), move: .none), OpponentModel(name: "Wacek", id: UUID(), move: .none)]
    @State var showContentView: Bool = false
   @State var showProfileView: Bool = false
   @State var showSettingsView: Bool = false
    @State private var signedIn: Bool = false


    var body: some View {
        VStack {
            HStack {
            Text("RPS")
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
         Spacer()
        Image(systemName: "person") // Sign In button
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .onTapGesture {
                    
                    //connect to auth
                    
                    
                    withAnimation(.easeInOut) {
                        self.showProfileView.toggle()
                    }
                }
                .fullScreenCover(isPresented: $showProfileView) {
                    if serverManager.isSignedIn() {
                    ProfileView(show: $showProfileView)
                    }else { 
                        SignUpView(show: $showProfileView, serverManager: serverManager)
                    }
                }

            Image(systemName: "gear")
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.showSettingsView.toggle()
                    }
                }
                .fullScreenCover(isPresented: $showSettingsView) {
                    SettingsView(show: $showSettingsView)
                }



            }
            .padding()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    ForEach(onlinePlayers, id: \.id) { player in
                        OnlinePlayerRow(player: player)
                    }
                }.padding()
            }
            .frame(height: 60 * 5)
            
            .background(Color(.systemBackground))
            .mask(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(.systemGray6), lineWidth: 2))
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 4)
            .padding()
            
            
            
            Spacer()
            
            Button(action: {
             // invite players and start game
             
            }) {
                HStack {
                    Spacer()
                    Text("START PARTY")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
                    .padding()
                    Spacer()
            }
                .background(Color.blue)
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.blue.lighter() ?? .blue, lineWidth: 2).opacity(0.8).blendMode(.overlay))
                .padding()
                
            }
            
            Button(action: {
             // invite players and start game
             
            }) {
                HStack {
                    Spacer()
                    Text("JOIN")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.white)
                    .padding()
                    Spacer()
            }
                .background(Color.blue)
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.blue.lighter() ?? .blue, lineWidth: 2).opacity(0.8).blendMode(.overlay))
                .padding()
                
            }
            
            
            Button(action: {
             // invite players and start game
                withAnimation(.easeInOut) {
                    self.showContentView.toggle()
                }
            }) {
                HStack {
                    Spacer()
                    Text("TEST")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundColor(.primary)
                    .padding()
                    Spacer()
            }
                .background(Color(.systemGray6))
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color(.systemGray5), lineWidth: 2).opacity(0.8).blendMode(.overlay))
                .padding(.horizontal)
                
            }
            
        
            
            
        }
        .fullScreenCover(isPresented: $showContentView, onDismiss: {
            
        }) {
            ContentView(show: $showContentView)
        }
        .onChange(of: scenePhase) { newValue in
            switch newValue {
            case .active:
                print("app is active")
                serverManager.setOnlineStatus(isOnline: true)
            case .inactive:
                serverManager.setOnlineStatus(isOnline: false)
            default:
                print("unknown state")
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

enum SignedInState {
    case signedIn
    case signedOut
}

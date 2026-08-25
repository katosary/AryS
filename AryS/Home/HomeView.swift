import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @Environment(ProfileViewModel.self) var profileViewModel
    @State var homeViewModel = HomeViewModel()
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userManager: UserManager
    
    // 💡 タイムライン用のViewModelをここで一元管理する
    @State private var timeLineViewModel = TimeLineViewModel()
    
    let barColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    var body: some View {
        TabView(selection: $homeViewModel.selectedTab) {
            // --- 0: ホーム（タイムライン）タブ ---
            NavigationStack {
                // 💡 生成したインスタンスを渡す
                TimeLineView(timeLineViewModel: timeLineViewModel)
                    .modifier(DarkToolbarModifier(profileViewModel: profileViewModel, authManager: authManager))
            }
            .tabItem {
                Label("ホーム", systemImage: "house")
            }
            .tag(0)
             
            // --- 1: 投稿するタブ ---
            NavigationStack {
                CoffeeRecordView(
                    onDismiss: {
                        homeViewModel.selectedTab = 0
                    },
                    onCompleted: {
                        homeViewModel.selectedTab = 0
                    }
                )
                .toolbar(.hidden, for: .navigationBar)
                .toolbar(.hidden, for: .tabBar)
            }
            .tabItem {
                Label("投稿する", systemImage: "plus")
            }
            .tag(1)
             
            // --- 2: プロフィールタブ ---
            NavigationStack {
                ProfileView()
                    .modifier(DarkToolbarModifier(profileViewModel: profileViewModel, authManager: authManager))
            }
            .tabItem {
                Label("プロフィール", systemImage: "person.circle")
            }
            .tag(2)
        }
        .accentColor(.white)
        .preferredColorScheme(.dark)
        // 💡 プロフィール編集シートの管理
        .sheet(isPresented: .init(
            get: { profileViewModel.isProfileEditSheet },
            set: { profileViewModel.isProfileEditSheet = $0 }
        )) {
            if let currentUser = userManager.currentUser {
                ProfileEditView(user: currentUser)
                    .onAppear {
                        profileViewModel.logs = homeViewModel.logs
                    }
            } else {
                ProfileEditView(user: profileViewModel.user)
                    .onAppear {
                        profileViewModel.logs = homeViewModel.logs
                    }
            }
        }
        .task {
            if let uid = Auth.auth().currentUser?.uid {
                await userManager.fetchCurrentUser(uid: uid)
            }
        }
    }
}


struct DarkToolbarModifier: ViewModifier {
    let barColor = Color(red: 89/255, green: 61/255, blue: 43/255)
    
    var profileViewModel: ProfileViewModel
    var authManager: AuthManager

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        ProfileMenuView(profileViewModel: profileViewModel)
                            .environmentObject(authManager)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                 
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 44)
                }
                 
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        NotificationView()
                    } label: {
                        Image(systemName: "bell")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .toolbarBackground(barColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
    }
}

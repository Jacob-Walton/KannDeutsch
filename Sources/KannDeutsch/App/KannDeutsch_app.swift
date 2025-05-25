import SwiftUI

@main
struct KannDeutsch_app: App {
    @StateObject private var dictionaryViewModel = DictionaryViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(dictionaryViewModel)
                .onAppear {
                    dictionaryViewModel.initialize()
                }
                .preferredColorScheme(.light)
        }
    }
}
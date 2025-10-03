import SwiftUI

struct BaseNavigationView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)   // 👈 force stack style everywhere
    }
}

import SwiftUI
import DataLayer

struct LoginView: View {
    private static let notionLoginPageURL = URL(
        string: ProcessInfo.processInfo.environment["NOTION_OAUTH_URL"]!
    )!
    
    var body: some View {
        // TODO: ログインの流れを説明する
        VStack {
            Link(destination: Self.notionLoginPageURL) {
                Text(String(moduleLocalized: "authorize-notion"))
                    .padding()
                    .background {
                        GlassmorphismRoundedRectangle()
                    }
            }
            .tint(Color(.label))
        }
    }
}

#Preview {
    ZStack {
        Color.black
        LoginView()
    }
}

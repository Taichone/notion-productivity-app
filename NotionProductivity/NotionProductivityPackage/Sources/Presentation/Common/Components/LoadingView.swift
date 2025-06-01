import SwiftUI

struct CommonLoadingView: View {
    let label: String?
    
    init(label: String? = nil) {
        self.label = label
    }
    
    var body: some View {
        LoadingView(label: label, textColor: .white) {
            GlassmorphismRoundedRectangle()
        }
    }
}

struct LoadingView<Content: View>: View {
    let label: String?
    let textColor: Color
    let backgroundContent: Content

    init(label: String?, textColor: Color, @ViewBuilder content: () -> Content) {
        self.label = label
        self.textColor = textColor
        self.backgroundContent = content()
    }

    var body: some View {
        VStack {
            ProgressView()
                .padding()
            
            if let label = label {
                Text(label)
                    .foregroundStyle(textColor)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .background {
            backgroundContent
        }
    }
}

#Preview {
    LoadingView(label: "読込中", textColor: .gray) {
        GlassmorphismRoundedRectangle()
    }
}

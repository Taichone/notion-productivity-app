import SwiftUI

struct LoadingView: View {
    let label: String?

    init(label: String? = nil) {
        self.label = label
    }

    var body: some View {
        VStack {
            ProgressView()
                .padding()
            
            if let label = label {
                Text(label)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
        .glassEffectIfAvailable()
    }
}

#Preview {
    LoadingView(label: "読込中")
}

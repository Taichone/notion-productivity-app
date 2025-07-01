import Foundation

extension String {
    init(moduleLocalized key: String.LocalizationValue) {
        self.init(localized: key, bundle: .module)
    }
}

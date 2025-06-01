import ManagedSettings
import FamilyControls

public actor ScreenTimeService {
    public static let familyActivitySelection = FamilyActivitySelection() // FamilyActivityPicker 用
    public var appSelection = FamilyActivitySelection()
}

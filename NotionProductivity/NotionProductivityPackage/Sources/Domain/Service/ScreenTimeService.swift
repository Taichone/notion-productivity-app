import ManagedSettings
import FamilyControls
import DataLayer

public actor ScreenTimeService {
    let screenTimeClient: ScreenTimeClient
    public static let familyActivitySelection = FamilyActivitySelection() // FamilyActivityPicker 用
    private var appSelection = FamilyActivitySelection()
    
    public init(screenTimeClient: ScreenTimeClient) {
        self.screenTimeClient = screenTimeClient
    }
    
    public func authorize() async throws {
        try await screenTimeClient.authorize()
    }
    
    public func startAppRestriction() {
        screenTimeClient.startAppRestriction(appSelection)
    }
    
    public func stopAppRestriction() {
        screenTimeClient.stopAppRestriction()
    }
    
    public func setAppSelection(_ newValue: FamilyActivitySelection) async {
        appSelection = newValue
    }
}

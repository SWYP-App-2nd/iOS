import SwiftUI
import Combine
import UserNotifications

class NotificationPermissionManager: ObservableObject {
    
    static let shared = NotificationPermissionManager()
    @Published var isGranted: Bool = false


//    private init() {}

}

import SwiftUI

public struct NotificationView: View {
    @EnvironmentObject var notificationManager: NotificationPermissionManager
    @StateObject var notificationViewModel = NotificationViewModel()
    
    public var body: some View {
        
//        if notificationManager.isGranted {
//            // TODO 어디로 가야 하지
//        } else {
            VStack {
                Text(notificationManager.isGranted ? "알림 권한 허용됨" : "알림 권한 미허용")
                
                Button(action: {
                    notificationViewModel.requestNotificationPermission()
                }){
                    Text("알림 권한 요청")
                }
                .padding()
            }
            
        }
    }
//}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
            .environmentObject(NotificationPermissionManager.shared)
    }
}

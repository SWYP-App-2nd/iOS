import SwiftUI
import Combine
import UserNotifications

/*
 1. 앱 인스턴스로부터 device token을 얻고 (요청), 이 token을 앱 사용자 계정에 연동시킨다.
    1.1. 앱이 APNs에 등록된다.
    1.2. 버튼을 누를 때? 앱이 APNs와 통신하면 APNs는 device token을 생성하고, 앱에 반환한다.
        - delegate method를 사용해서 자동으로 처리 / return 값 없음
        - 등록 성공: didRegisterForRemoteNotificationsWithDeviceToken
        - 등록 실패: didFailToRegisterForRemoteNotificationsWithError
    1.3. 앱은 device token을 provider 서버에 전달한다.
    1.4. provider 서버는 notification 전달 할 때마다 device token을 사용자 계정에 연동시킨다.
 
 2. 사용자에게 언제 notification을 보낼지 정하고, notification payloads를 생성한다.
    

 HTTP/2 and TLS를 사용해서 APNs에 연결하는 것을 관리한다.

 payload를 포함한 POST request를 생성하고, request를 HTTP/2 연결을 통해 전송한다.
 
 token-based authentication을 위해 정기적으로 token을 재생성한다.

 */

class NotificationViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let permissionManager = NotificationPermissionManager.shared

    // MARK: - permission 요청 메서드
    func requestNotificationPermission() {
        requestAuthorization()
            .receive(on: DispatchQueue.main) // UI 업데이트는 메인 스레드에서 수행
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    // TODO - 에러 핸들링
                    print("Error: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] granted in
                self?.permissionManager.isGranted = granted  // 권한 요청 결과를 permissionManager에 전달
                if granted {
                    registerForRemoteNotifications()
                }
            })
            .store(in: &cancellables)
    }

        // MARK: - Future를 이용한 비동기 권한 요청
    private func requestAuthorization() -> Future<Bool, Never> {
        return Future { promise in
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { granted, error in
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                }
                promise(.success(granted))
            }
        }
    }
}

    private func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func didRegisterForRemoteNotifications(token: Data) {
            let tokenString = token.map { String(format: "%02x", $0) }.joined()
            DispatchQueue.main.async {
                sendDeviceTokenToServer(tokenString)
            }
        }

    
//
//
//// MARK: - Forward token to server
//  func sendDeviceTokenToServer(_ token: String) {
//      guard let url = URL(string: "https://your-api-server.com/api/register-device-token") else { return }
//      
//      let payload: [String: Any] = ["deviceToken": token]
//      let jsonData = try? JSONSerialization.data(withJSONObject: payload)
//
//      var request = URLRequest(url: url)
//      request.httpMethod = "POST"
//      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//      request.httpBody = jsonData
//
//      URLSession.shared.dataTask(with: request) { data, response, error in
//          if let error = error {
//              print("Failed on forwarding token \(error.localizedDescription)")
//              return
//          }
//          print("Successfully forwarded token to server")
//      }.resume()
//  }



// MARK: - Check Permission
//center.getNotificationSettings { settings in
//    guard (settings.authorizationStatus == .authorized) || (settings.authorizationStatus == .provisional) else {
//        // Handle the error here.
//
//        return
//    }
//    if settings.alertSetting == .enabled {
//        // Schedule an alert-only notification.
//    } else {
//
//    }
//
//}
    

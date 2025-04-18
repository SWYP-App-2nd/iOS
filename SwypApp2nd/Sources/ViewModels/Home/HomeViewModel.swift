import Foundation
import UIKit
import Combine

class HomeViewModel: ObservableObject {
    /// 내 사람들
    @Published var allFriends: [Friend] = []
    /// 이번달 챙길 사람
    @Published var thisMonthFriends: [Friend] = []
    
//    init() {
//        loadPeoplesFromUserSession()
//    }
//
//    func loadPeoplesFromUserSession() {
//        DispatchQueue.main.async {
//            self.peoples = UserSession.shared.user?.friends ?? []
//        }
//    }
    
    func fetchAndSetImage(for friend: Friend, accessToken: String, completion: @escaping (UIImage?) -> Void) {
        guard let fileName = friend.fileName else {
            print("🔴 [HomeViewModel] fileName 없음: \(friend.name)")
            completion(nil)
            return
        }
        let category = "Friends/profile"
        
        BackEndAuthService.shared.fetchPresignedDownloadURL(fileName: fileName, category: category, accessToken: accessToken) { url in
            guard let url = url else {
                print("🔴 [HomeViewModel] 다운로드 URL 실패 - fileName: \(fileName)")
                completion(nil)
                return
            }

            self.downloadImage(from: url) { image in
                completion(image)
            }
        }
    }
    
    // PresignedURL 사용 이미지 데이터 다운
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🟡 [HomeViewModel] 응답 코드: \(httpResponse.statusCode)")
            }
            
            if let data = data, let image = UIImage(data: data) {
                print("🟢 [HomeViewModel] 이미지 다운로드 성공")
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                print("🔴 [HomeViewModel] 이미지 다운로드 실패: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func loadFriendList() {
        guard let token = UserSession.shared.user?.serverAccessToken else { return }
        
        BackEndAuthService.shared.fetchFriendList(accessToken: token) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendList):
                    DispatchQueue.main.async {
                        var loadedFriends: [Friend] = friendList.map {
                            Friend(
                                id: UUID(uuidString: $0.friendId) ?? UUID(),
                                name: $0.name,
                                imageURL: $0.imageUrl,
                                // TODO: - $0.source로 변경
                                source: .kakao,
                                position: $0.position,
                                fileName: $0.fileName
                            )
                        }
                        
                        let group = DispatchGroup()
                        
                        // 이미지 다운로드 진행
                        for index in loadedFriends.indices {
                            group.enter()
                            self.fetchAndSetImage(for: loadedFriends[index], accessToken: token) { image in
                                DispatchQueue.main.async {
                                    loadedFriends[index].image = image
                                    group.leave()
                                }
                            }
                        }
                        
                        group.notify(queue: .main) {
                            self.allFriends = loadedFriends
                            UserSession.shared.user?.friends = loadedFriends
                            print("🟢 [HomeViewModel] 모든 친구 이미지 로드 완료")
                        }
                    }
                case .failure(let error):
                    print("🔴 친구 목록 API 실패: \(error)")
                }
            }
        }
    }
}

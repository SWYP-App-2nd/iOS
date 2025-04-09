import Combine
import KakaoSDKUser
import Foundation

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    /// 사용자 객체
    @Published var user: User?
    
    /// 앱 흐름
    @Published var appStep: AppStep = .login
    

    // TODO: - 토큰 삭제, appStep 로그인으로
    func kakaoLogout() {
        self.user = nil
        self.appStep = .login
        print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
    }
    
    // TODO: - 토큰 삭제, appStep 로그인으로
    func appleLogout() {
        self.user = nil
        self.appStep = .login
        print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
    }
    
    /// 로그인 상태 업데이트
    func updateUser(_ user: User) {
        DispatchQueue.main.async {
            print("🟢 [UserSession] updateUser 호출 - loginType 확인: \(user.loginType)")

            self.user = user
            
            // 로그인 타입에 따른 약관 동의 확인
            switch user.loginType {
            case .kakao:
                print("🟢 [UserSession] updateUser 호출 - didAgreeToTerms 값: \(UserDefaults.standard.bool(forKey: "didAgreeToKakaoTerms"))")
                let agreed = UserDefaults.standard.bool(
                    forKey: "didAgreeToKakaoTerms"
                )
                self.appStep = agreed ? .home : .terms
                print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")

            case .apple:
                print("🟢 [UserSession] updateUser 호출 - didAgreeToTerms 값: \(UserDefaults.standard.bool(forKey: "didAgreeToAppleTerms"))")
                let agreed = UserDefaults.standard.bool(
                    forKey: "didAgreeToAppleTerms"
                )
                self.appStep = agreed ? .home : .terms
                print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
            }
        }
    }

    /// 로그아웃 처리
    func logout() {
        // TODO: - SNS 로그아웃 추가하기.
        TokenManager.shared.clear(type: .server)  // 토큰 삭제
        self.user = nil
        self.appStep = .login
        print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
    }
    
    /// 자동 로그인
    func tryAutoLogin() {
        if let _ = TokenManager.shared.get(for: .kakao) {
            // 카카오 로그인인 경우
            tryKakaoAutoLogin()
        } else if let _ = TokenManager.shared.get(for: .apple) {
            // 애플 로그인인 경우
            tryAppleAutoLogin()
        } else {
            print("🔴 [UserSession] 저장된 SNS 토큰이 없음, 로그인 필요")
            self.appStep = .login
            print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
        }
    }
    
    /// 카카오 토큰 검사
    func tryKakaoAutoLogin() {
        print("🟡 [UserSession] 카카오 로그인 시도")

        // 카카오 access token 유효성 검사
        UserApi.shared.accessTokenInfo { _, error in
            if let error = error {
                print("🔴 [UserSession] 카카오 accessToken 유효하지 않음: \(error.localizedDescription)")
                self.logout()
                return
            }

            print("🟢 [UserSession] 카카오 accessToken 유효")

            // 서버 accessToken 존재 여부 확인
            if TokenManager.shared.get(for: .server) != nil {
                print("🟢 [UserSession] 서버 accessToken 존재 → 로그인 유지")
                
                let agreed = UserDefaults.standard.bool(forKey: "didAgreeToKakaoTerms")
                
//                // TODO: - 서버에서 유저정보 가져와야함.
//                let user = User(
//                    id: "kakao_user",
//                    name: "카카오 유저",
//                    email: nil,
//                    profileImageURL: nil,
//                    loginType: .kakao,
//                    serverAccessToken: TokenManager.shared.get(
//                        for: .server,
//                        isRefresh: false
//                    ) ?? "",
//                    serverRefreshToken: TokenManager.shared.get(
//                        for: .server,
//                        isRefresh: true
//                    ) ?? ""
//                )
//                self.updateUser(user)
                
                self.appStep = agreed ? .home : .terms
                print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
                return
            }

            // 서버 refreshToken 존재 여부 확인
            guard let refreshToken = TokenManager.shared.get(for: .server, isRefresh: true) else {
                print("🔴 [UserSession] 서버 refreshToken 없음 → 로그인 필요")
                self.logout()
                return
            }

            print("🟡 [UserSession] 서버 accessToken 없음 → refreshToken으로 재발급 시도")

            // 서버 토큰 재발급 요청
            BackEndAuthService.shared
                .refreshAccessToken(refreshToken: refreshToken) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let newAccessToken):
                            print("🟢 [UserSession] 서버 accessToken 재발급 성공")
                            TokenManager.shared
                                .save(token: newAccessToken, for: .server)
                            let agreed = UserDefaults.standard.bool(
                                forKey: "didAgreeToKakaoTerms"
                            )
                            self.appStep = agreed ? .home : .terms
                            print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
                            // TODO: - 서버에 유저 정보 요청하는 로직 추가해야함
                        case .failure(let error):
                            print("🔴 [UserSession] 서버 토큰 재발급 실패: \(error.localizedDescription)")
                            self.logout()
                        }
                    }
                }
        }
    }
    
    /// 애플 토큰 검사
    func tryAppleAutoLogin() {
        print("🟡 [UserSession] 애플 로그인 시도")

        // 저장된 identityToken 가져오기
        guard TokenManager.shared.get(for: .apple) != nil else {
            print("🔴 [UserSession] 애플 identityToken 없음 → 로그인 필요")
            self.logout()
            return
        }

        // 서버 accessToken 확인
        if TokenManager.shared.get(for: .server) != nil {
            print("🟢 [UserSession] 서버 accessToken 존재 → 로그인 유지")
            let agreed = UserDefaults.standard.bool(
                forKey: "didAgreeToAppleTerms"
            )
            self.appStep = agreed ? .home : .terms
            print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
            return
        }

        // 서버 refreshToken 확인
        guard let refreshToken = TokenManager.shared.get(for: .server, isRefresh: true) else {
            print("🔴 [UserSession] 서버 refreshToken 없음 → 로그인 필요")
            self.logout()
            return
        }

        print("🟡 [UserSession] 서버 accessToken 없음 → refreshToken으로 재발급 시도")
        // 서버 토큰 재발급
        BackEndAuthService.shared.refreshAccessToken(refreshToken: refreshToken) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newAccessToken):
                    print("🟢 [UserSession] 서버 accessToken 재발급 성공")
                    TokenManager.shared.save(token: newAccessToken, for: .server)
                    let agreed = UserDefaults.standard.bool(
                        forKey: "didAgreeToAppleTerms"
                    )
                    self.appStep = agreed ? .home : .terms
                    print("🟢 [UserSession] appStep 설정됨: \(self.appStep)")
                case .failure(let error):
                    print("🔴 [UserSession] 서버 토큰 재발급 실패: \(error.localizedDescription)")
                    self.logout()
                }
            }
        }
    }
}

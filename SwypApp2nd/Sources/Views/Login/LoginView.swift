import AuthenticationServices
import SwiftUI

public struct LoginView: View {
    @ObservedObject var loginViewModel: LoginViewModel
    @StateObject private var termsViewModel = TermsViewModel()
    @EnvironmentObject var userSession: UserSession
    
    public var body: some View {
        VStack(spacing: 44) {

            Spacer()

            VStack(alignment: .center, spacing: 0) {
                Group {
                    Image.Character.success
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 160, height: 160)
                    
                    Image.Login.blueLogo
                        .frame(width: 120, height: 48)
                }

                Text("소중한 사람들과 더 가까워지는 시간")
                    .font(Font.Pretendard.b1Medium())
                    .foregroundStyle(Color.gray01)
                    .padding(.top, 8)
            }

            Spacer()

            VStack(alignment: .center, spacing: 12) {
                // 카카오 로그인
                Button(action: {
                    loginViewModel.loginWithKakao()
                }) {
                    HStack(spacing: 6) {
                        Image("kakao_symbol_large")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 14)

                        Text("카카오로 시작하기")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .background(Color.kakaoBackgroundColor)
                    .cornerRadius(8)
                }

                // 애플 로그인
                SignInWithAppleButton(
                    onRequest: loginViewModel.handleAppleRequest,
                    onCompletion: loginViewModel.handleAppleCompletion
                )
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .signInWithAppleButtonStyle(.black)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            AnalyticsManager.shared.trackLoginViewLogAnalytics()
        }
    }
}
#Preview {
    let session: UserSession = {
        let session = UserSession()
        session.appStep = .login
        return session
    }()
    
    LoginView(loginViewModel: LoginViewModel())
        .environmentObject(session)
}

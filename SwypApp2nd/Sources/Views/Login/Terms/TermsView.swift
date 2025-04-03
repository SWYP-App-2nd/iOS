import SwiftUI
import Combine
import WebKit

struct AgreementDetail: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let urlString: String
}

public struct TermsView: View {
    @ObservedObject var viewModel = TermsViewModel()
    
    // 약관 상세를 보여주기 위한 상태 관리
    @State private var selectedAgreement: AgreementDetail?
    
    let completion: () -> Void

    public var body: some View {
        VStack(alignment: .leading) {

            Text("서비스 약관 동의")
                .font(Font.Pretendard.h2Bold())
                .padding(.leading, 20)
                .padding(.top, 44)

            LazyVStack(spacing: 12) {
                AgreementRow(
                    isChecked: .constant(viewModel.isAllAgreed),
                    title: "약관 전체 동의",
                    checkBoxTappedClosure: {
                        viewModel.toggleAllAgreed()
                    },
                    onDetailTappedClosure: nil
                )
                
                AgreementRow(
                    isChecked: $viewModel.isServiceTermsAgreed,
                    title: "[필수] 서비스 이용 약관",
                    isBold: false,
                    showDetail: true,
                    detailURLString: "https://example.com/") {
                        // checkbox closure
                    } onDetailTappedClosure: { title, url in
                        self.selectedAgreement = AgreementDetail(title: title, urlString: url)
                    }
                
                AgreementRow(
                    isChecked: $viewModel.isPersonalInfoTermsAgreed,
                    title: "[필수] 개인정보 수집 및 이용 동의서",
                    isBold: false,
                    showDetail: true,
                    detailURLString: "https://example.com/") {
                        // checkbox closure
                    } onDetailTappedClosure: { title, url in
                        self.selectedAgreement = AgreementDetail(title: title, urlString: url)
                    }
                AgreementRow(
                    isChecked: $viewModel.isPrivacyPolicyAgreed,
                    title: "[필수] 개인정보 처리방침",
                    isBold: false,
                    showDetail: true,
                    detailURLString: "https://example.com/") {
                        // checkbox closure
                    } onDetailTappedClosure: { title, url in
                        self.selectedAgreement = AgreementDetail(title: title, urlString: url)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)

            Spacer()

            Button(action: {
                // MARK: - 약관 동의 유무 UserDefaults에 저장
                if UserSession.shared.user?.loginType == .kakao {
                    UserDefaults.standard
                        .set(true, forKey: "didAgreeToKakaoTerms")
                    print("🟢 [TermsView] didAgreeToKakaoTerms 저장됨: \(UserDefaults.standard.bool(forKey: "didAgreeToKakaoTerms"))")
                } else if UserSession.shared.user?.loginType == .apple {
                    UserDefaults.standard
                        .set(true, forKey: "didAgreeToAppleTerms")
                    print("🟢 [TermsView] didAgreeToAppleTerms 저장됨: \(UserDefaults.standard.bool(forKey: "didAgreeToAppleTerms"))")
                }
                
                completion()
            }) {
                Text("가입")
                    .foregroundColor(.white)
                    .font(Font.Pretendard.b1Bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(Color.blue01)
                    .cornerRadius(8)
            }
            .padding(20)
            .disabled(!viewModel.canProceed)
            .opacity(viewModel.canProceed ? 1 : 0.5)
        }
        .background(Color.white)
        .cornerRadius(24)
        .sheet(item: $selectedAgreement) { agreement in
            NavigationStack {
                TermsDetailView(
                    title: agreement.title,
                    urlString: agreement.urlString
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("닫기") {
                            selectedAgreement = nil
                        }
                        .foregroundStyle(.black)
                    }
                }
            }
        }
    }
}
/// 이용 약관 Row
public struct AgreementRow: View {
    var isChecked: Binding<Bool>
    var title: String
    var isBold: Bool = false
    var showDetail: Bool = false
    var detailURLString: String? = nil
    
    var checkBoxTappedClosure: (() -> Void)? = nil
    var onDetailTappedClosure: ((String, String) -> Void)?
    
    public init(
            isChecked: Binding<Bool>,
            title: String,
            isBold: Bool = false,
            showDetail: Bool = false,
            detailURLString: String? = nil,
            checkBoxTappedClosure: (() -> Void)? = nil,
            onDetailTappedClosure: ((String, String) -> Void)? = nil
        ) {
            self.isChecked = isChecked
            self.title = title
            self.isBold = isBold
            self.showDetail = showDetail
            self.detailURLString = detailURLString
            self.checkBoxTappedClosure = checkBoxTappedClosure
            self.onDetailTappedClosure = onDetailTappedClosure
        }
    
    public var body: some View {
        HStack {
            Button(action: {
                isChecked.wrappedValue.toggle()
                checkBoxTappedClosure?()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked.wrappedValue ? Color.blue01 : Color.gray02, lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(isChecked.wrappedValue ? Color.blue01 : Color.clear)
                        .cornerRadius(6)

                    if isChecked.wrappedValue {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            Text(title)
                .font(isBold ? .body.bold() : .body)
            
            Spacer()
            
            if showDetail, let detailURLString = detailURLString {
                Button {
                    onDetailTappedClosure?(title, detailURLString)
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

struct TermsDetailView: View {
    let title: String?
    let urlString: String?
    
    @State private var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("로딩 중...")
                    Spacer()
                }
            }
            
            if let urlString = urlString, let url = URL(string: urlString) {
                WebView(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(isLoading ? 0 : 1)
            } else if !isLoading {
                Text("유효하지 않은 URL입니다.")
                    .foregroundColor(.red)
                    .padding()
                    .opacity(isLoading ? 0 : 1)
                let _ = print("🔴 [TermsDetailView] 유효하지 않은 URL 입니다. ")
            }
            
        }
        .onAppear {
            if let urlString = urlString, let url = URL(string: urlString) {
                print("🟢 [TermsDetailView] URL 파싱 성공: \(url)")
                isLoading = false
            } else {
                print(
                    "🔴 [TermsDetailView] URL 파싱 실패: \(String(describing: urlString))"
                )
                isLoading = false
            }
        }
        .navigationTitle(title ?? "")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL
        
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
        
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
        
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
        
    class Coordinator: NSObject, WKNavigationDelegate {
        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            print("🟡 웹뷰 로딩 시작")
        }
            
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            print("🟢 웹뷰 로딩 완료")
        }
            
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            print("🔴 웹뷰 로딩 실패: \(error.localizedDescription)")
        }
    }
}

#Preview {
    TermsView(viewModel: TermsViewModel()) {
        
    }
}

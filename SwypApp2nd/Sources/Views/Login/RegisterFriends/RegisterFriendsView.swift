import SwiftUI

struct RegisterFriendView: View {
    @ObservedObject var viewModel: RegisterFriendsViewModel
    
    @State private var showContactPicker = false
    let proceed: () -> Void
    let skip: () -> Void
    
    private var contactListSection: some View {
        VStack(spacing: 12) {
            if !viewModel.phoneContacts.isEmpty {
                ForEach(viewModel.phoneContacts) { contact in
                    ContactRow(contact: contact) {
                        viewModel.removeContact(contact)
                    }
                }
            }

            if !viewModel.kakaoContacts.isEmpty {
                ForEach(viewModel.kakaoContacts) { contact in
                    ContactRow(contact: contact) {
                        viewModel.removeContact(contact)
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    
    var body: some View {
        Spacer()
            .frame(height: 12)
        
        VStack(alignment: .leading, spacing: 24) {
            // 헤더 텍스트
            VStack(alignment: .leading, spacing: 16) {
                
                HStack {
                    Text("챙길 사람 불러오기")
                        .font(.Pretendard.b1Bold())
                        .foregroundColor(.black)
                    Spacer()
                    Text("1 / 2")
                        .font(.Pretendard.captionBold())
                        .foregroundColor(.gray02)
                }

                Image("img_100_character_default")
                    .frame(height: 80)

                Text("가까워지고 싶은 사람을\n선택해주세요")
                    .font(.Pretendard.h1Bold())

                Text("먼저, 더 가까워지고 싶은\n소중한 사람만 선택해주세요.")
                    .font(.Pretendard.b2Bold())
                    .foregroundColor(.gray02)
            }
            .padding(.horizontal, 20)

            // 불러오기 카드 버튼, 가져온 연락처
            ScrollView {
                VStack(spacing: 12) {
                    // 연락처
                    VStack(spacing: 12) {
                        CardButton(
                            icon: Image("img_32_contact_square"),
                            title: "연락처에서 불러오기",
                            action: {
                                showContactPicker = true
                            }
                        )
                        .sheet(isPresented: $showContactPicker) {
                            ContactPickerView { contacts in
                                viewModel.fetchContactsFromPhone(contacts)
                            }
                        }
                        
                        if !viewModel.phoneContacts.isEmpty {
                            ForEach(viewModel.phoneContacts) { contact in
                                ContactRow(contact: contact) {
                                    viewModel.removeContact(contact)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                    
                    // 카카오톡
                    VStack(spacing: 12) {
                        CardButton(
                            icon: Image("img_32_kakao_square"),
                            title: "카카오톡에서 불러오기",
                            action: {
                                viewModel.fetchContactsFromKakao()
                            }
                        )
                        
                        if !viewModel.kakaoContacts.isEmpty {
                            ForEach(viewModel.kakaoContacts) { contact in
                                ContactRow(contact: contact) {
                                    viewModel.removeContact(contact)
                                }
                                
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
            Spacer()

            // 하단 버튼
            HStack(spacing: 12) {
                Button(action: skip) {
                    Text("나중에 하기")
                        .font(.Pretendard.b1Bold())
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black)
                        .frame(height: 52)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Button(action: proceed) {
                    Text("다음")
                        .font(.Pretendard.b1Bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(viewModel.canProceed ? Color.blue01 : Color.gray01)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canProceed)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - 카드 버튼 뷰 컴포넌트
struct CardButton: View {
    let icon: Image
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .cornerRadius(8)

                Text(title)
                    .font(.Pretendard.b2Medium())
                    .foregroundColor(.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray02)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 8)
        }
    }
}

// MARK: - 가져온 연락처 Row
struct ContactRow: View {
    let contact: Friend
    let onDelete: () -> Void

    var iconImage: Image {
        switch contact.source {
        case .phone:
            return Image("img_32_contact_square")
        case .kakao:
            return Image("img_32_kakao_square")
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            iconImage
                .resizable()
                .frame(width: 32, height: 32)

            Text(contact.name)
                .font(.Pretendard.b2Medium())
                .foregroundColor(.black)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 24)
        .background(Color.bg02)
        .cornerRadius(12)
    }
}


#Preview {
    RegisterFriendView(
        viewModel: RegisterFriendsViewModel(),
        proceed: { print("다음 눌림") },
        skip: { print("나중에 하기 눌림") }
    )
}

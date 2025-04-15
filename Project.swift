import ProjectDescription

let project = Project(
    name: "SwypApp2nd",
    options: .options(
        automaticSchemesOptions: .disabled,
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko",
        textSettings:
            .textSettings(usesTabs: false, indentWidth: 4, tabWidth: 4)
    ),
    settings: .settings(
        base: [:],
        configurations: [
            .debug(name: "Debug", xcconfig: "Tuist/Config/Config.xcconfig"),
            .release(
                name: "Release",
                xcconfig: "Tuist/Config/Config.xcconfig"
            ),
        ]
    ),
    targets: [
        .target(
            name: "SwypApp2nd",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.SwypApp2nd",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchStoryboardName": "LaunchScreen",
                    "UIAppFonts": [
                        "Pretendard-Black.otf",
                        "Pretendard-Bold.otf",
                        "Pretendard-ExtraBold.otf",
                        "Pretendard-ExtraLight.otf",
                        "Pretendard-Light.otf",
                        "Pretendard-Medium.otf",
                        "Pretendard-Regular.otf",
                        "Pretendard-SemiBold.otf",
                        "Pretendard-Thin.otf",
                    ],
                    "CFBundleIconName": "AppIcon",
                    "UIUserInterfaceStyle": "Light",
                    "NSContactsUsageDescription": "연락처에서 챙길 사람을 가져오려면\n 기기 설정에서 연락처를 허용해주세요.",
                    "KAKAO_APP_KEY": "$(KAKAO_APP_KEY)"
                ]
            ),
            sources: [
                "SwypApp2nd/Sources/**"
            ],
            resources: ["SwypApp2nd/Resources/**"],
            entitlements: "Tuist/SignInWithApple.entitlements",
            dependencies: [
                .external(name: "Alamofire"),
                .external(name: "Kingfisher"),
                .external(name: "KakaoSDK"),
            ],
            settings: .settings(base: [
                "RUN_EXECUTABLE_PATH": "$(BUILT_PRODUCTS_DIR)/SwypApp2nd.app",
                "MARKETING_VERSION": "0.1.2",
                "CURRENT_PROJECT_VERSION": "3"
            ])
        ),
        .target(
            name: "SwypApp2ndTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.SwypApp2ndTests",
            infoPlist: .default,
            sources: ["SwypApp2nd/Tests/**"],
            resources: [],
            dependencies: [.target(name: "SwypApp2nd")]
        ),
    ]
)

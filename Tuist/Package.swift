// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: ["Alamofire": .framework,
                       "Kingfisher": .framework,
                       "KakaoSDKCommon": .framework,
                       "KakaoSDKAuth": .framework,
                       "KakaoSDKUser": .framework,
                       "KakaoSDKFriend": .framework,
                       "KakaoSDKTalk": .framework,
                      ]
    )
#endif

let package = Package(
    name: "SwypApp2nd",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        .package(
            url: "https://github.com/onevcat/Kingfisher.git",
            from: "7.0.0"
        ),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.24.0")
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
    ]
)

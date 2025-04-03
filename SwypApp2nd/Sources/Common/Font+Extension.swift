import Foundation

import SwiftUI

extension Font {
    struct Pretendard {
        static func h1Bold() -> Font {
            Font.custom("Pretendard-Bold", size: 24)
        }
        
        static func h1Medium() -> Font {
            Font.custom("Pretendard-Medium", size: 24)
        }
        
        static func h1Regular() -> Font {
            Font.custom("Pretendard-Regular", size: 24)
        }
        
        static func h2Bold() -> Font {
            Font.custom("Pretendard-Bold", size: 18)
        }
        
        static func b1Bold() -> Font {
            Font.custom("Pretendard-Bold", size: 16)
        }
        
        static func b1Medium() -> Font {
            Font.custom("Pretendard-Medium", size: 16)
        }
        
        static func b2Bold() -> Font {
            Font.custom("Pretendard-Bold", size: 14)
        }
        
        static func b2Medium() -> Font {
            Font.custom("Pretendard-Medium", size: 14)
        }
        
        static func captionBold() -> Font {
            Font.custom("Pretendard-Bold", size: 12)
        }
        
        static func captionMedium() -> Font {
            Font.custom("Pretendard-Medium", size: 12)
        }
    }
}

// MARK: - Example
/*
Text("Example")
   .font(Font.Pretendard.h1Bold())
   .tracking(-0.25)
   .lineSpacing(10)
*/

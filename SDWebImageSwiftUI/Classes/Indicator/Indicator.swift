/*
* This file is part of the SDWebImage package.
* (c) DreamPiggy <lizhuoli1126@126.com>
*
* For the full copyright and license information, please view the LICENSE
* file that was distributed with this source code.
*/

import Foundation
import SwiftUI

/// A  type to build the indicator
public struct Indicator<T> where T : View {
    var builder: (Binding<Bool>, Binding<CGFloat>) -> T
    
    /// Create a indicator with builder
    /// - Parameter builder: A builder to build indicator
    /// - Parameter isAnimating: A Binding to control the animation. If image is during loading, the value is true, else (like start loading) the value is false.
    /// - Parameter progress: A Binding to control the progress during loading. If no progress can be reported, the value is 0.
    /// Associate a indicator when loading image with url
    public init(@ViewBuilder builder: @escaping (_ isAnimating: Binding<Bool>, _ progress: Binding<CGFloat>) -> T) {
        self.builder = builder
    }
}

/// A implementation detail View Modifier with indicator
/// SwiftUI View Modifier construced by using a internal View type which modify the `body`
/// It use type system to represent the view hierarchy, and Swift `some View` syntax to hide the type detail for users
struct IndicatorViewModifier<T> : ViewModifier where T : View {
    @ObservedObject var imageManager: ImageManager
    
    let indicatorView: T
    
    func body(content: Content) -> some View {
        if !imageManager.isLoading {
            // Disable Indiactor
            return AnyView(content)
        } else {
            // Enable indicator
            return AnyView(
                ZStack {
                    content
                    indicatorView
                }
            )
        }
    }
    
    init(imageManager: ImageManager, indicator: Indicator<T>) {
        self.imageManager = imageManager
        // This syntax looks not Swifty, hope for SwiftUI better design
        self.indicatorView = indicator.builder(_imageManager.projectedValue.isLoading, _imageManager.projectedValue.progress)
    }
}

#if os(macOS) || os(iOS) || os(tvOS)
extension Indicator where T == ActivityIndicator {
    /// Activity Indicator
    public static var activity: Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating)
        }
    }
    
    /// Activity Indicator with style
    /// - Parameter style: style
    public static func activity(style: ActivityIndicator.Style) -> Indicator {
        Indicator { isAnimating, _ in
            ActivityIndicator(isAnimating, style: style)
        }
    }
}

extension Indicator where T == ProgressIndicator {
    /// Progress Indicator
    public static var progress: Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress)
        }
    }
    
    /// Progress Indicator with style
    /// - Parameter style: style
    public static func progress(style: ProgressIndicator.Style) -> Indicator {
        Indicator { isAnimating, progress in
            ProgressIndicator(isAnimating, progress: progress, style: style)
        }
    }
}
#endif
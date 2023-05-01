//
//  SwiftUIView.swift
//  GradingApp
//
//  Created by Matthias Rudnick on 01.05.23.
//


import SwiftUI

extension View {
    func popup<PopupContent: View>(isPresented: Binding<Bool>,
                                          blurredBackground: Bool = false,
                                          darkBackground: Bool = false,
                                          flyIn: FlyIn = .none,
                                          view: @escaping () -> PopupContent) -> some View {
        self.modifier(Popup(isPresented: isPresented,
                            blurredBackground: blurredBackground,
                            darkBackground: darkBackground,
                            flyIn: flyIn,
                            view: view)
                     )
    }
}

enum FlyIn {
    case none, normal, bounce
}

public struct Popup<PopupContent>: ViewModifier where PopupContent: View {
    
    @Binding var isPresented: Bool
    
   
    
    let blur: Bool
    let darkBackground: Bool
    let flyIn: FlyIn
    
    let animationSpeed = 0.3
    
    var view: () -> PopupContent
    
    init(isPresented: Binding<Bool>,
         blurredBackground: Bool,
         darkBackground: Bool,
         flyIn: FlyIn,
         view: @escaping () -> PopupContent) {
        self._isPresented = isPresented
        self.view = view
        self.blur = blurredBackground
        self.flyIn = flyIn
        self.darkBackground = darkBackground
    }
    
    
    
    @State private var presenterContentRect: CGRect = .zero

    /// The rect of popup content
    @State private var sheetContentRect: CGRect = .zero

    /// The offset when the popup is displayed
    private var displayedOffset: CGFloat {
        -presenterContentRect.midY + screenHeight/2
    }
    

    /// The offset when the popup is hidden
    private var hiddenOffset: CGFloat {
        if presenterContentRect.isEmpty {
            return 1000
        }
        return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
    }

    /// The current offset, based on the "presented" property
    private var currentOffset: CGFloat {
        return isPresented ? displayedOffset : hiddenOffset
    }
    
    private var backgroundOpacity: CGFloat {
        if darkBackground {
            return isPresented ? 0.5 : 0.0
        }
        return 0.0
    }
    
    private var backgroundBlur: CGFloat {
        if blur {
            return isPresented ? 5.0 : 0.0
        }
        return 0.0
    }
    
    private var currentOpacity: CGFloat {
        return isPresented ? 1.0 : 0.0
    }
    
    
    private var screenWidth: CGFloat {
        UIScreen.main.bounds.size.width
    }

    private var screenHeight: CGFloat {
        UIScreen.main.bounds.size.height
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
                .frameGetter($presenterContentRect)
            if isPresented {
                Color(red: 0.41, green: 0.41, blue: 0.41, opacity: backgroundOpacity)
                    .edgesIgnoringSafeArea(.all)
                    .animation(Animation.easeInOut(duration: animationSpeed), value: backgroundOpacity)
            }
        }
        .blur(radius: backgroundBlur)
        .animation(Animation.easeInOut(duration: animationSpeed), value: backgroundBlur)
        .overlay(sheet())
    }
    
    
    func sheet() -> some View {
        ZStack {
            self.view()
              .frameGetter($sheetContentRect)
              .frame(width: screenWidth)
              .offset(x: 0, y: flyIn != .none ? currentOffset : displayedOffset)
              .if(flyIn == .bounce) { view in
                  return view.animation(.interpolatingSpring(stiffness: 80, damping: 13, initialVelocity: 10), value: currentOffset)
              }
              .if(flyIn == .normal) { view in
                  return view.animation(Animation.easeInOut(duration: animationSpeed), value: currentOffset)
              }
        }
        .opacity(currentOpacity)
        .animation(Animation.easeInOut(duration: animationSpeed), value: currentOpacity)
    }
    
    private func dismiss() {
        isPresented = false
    }
}


extension View {
    func frameGetter(_ frame: Binding<CGRect>) -> some View {
        modifier(FrameGetter(frame: frame))
    }
}

struct FrameGetter: ViewModifier {
  
    @Binding var frame: CGRect
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy -> AnyView in
                    let rect = proxy.frame(in: .global)
                    // This avoids an infinite layout loop
                    if rect.integral != self.frame.integral {
                        DispatchQueue.main.async {
                            self.frame = rect
                        }
                    }
                return AnyView(EmptyView())
            })
    }
}

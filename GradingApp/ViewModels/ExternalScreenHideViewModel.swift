//
//  ExternalScreenideViewModel.swift
//  GradingApp
//
//  Created by Tom Rudnick on 25.01.22.
//

import Foundation
import UIKit
import SwiftUI
import Combine


class ExternalScreenHideViewModel: ObservableObject {
    
    private let hideUserDefaults: String = "notHide"
    
    @Published var notHide: Bool {
        didSet {
            updateHide()
        }
    }
    @Published var additionalWindows: [UIWindow] = []
    
    var screenDidConnectPublisher: AnyPublisher<UIScreen, Never> {
            NotificationCenter.default
                .publisher(for: UIScreen.didConnectNotification)
                .compactMap { $0.object as? UIScreen }
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }

    var screenDidDisconnectPublisher: AnyPublisher<UIScreen, Never> {
        NotificationCenter.default
            .publisher(for: UIScreen.didDisconnectNotification)
            .compactMap { $0.object as? UIScreen }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    init() {
        self.notHide = UserDefaults.standard.bool(forKey: hideUserDefaults)
    }
    
    private func updateHide() {
        UserDefaults.standard.set(notHide, forKey: hideUserDefaults)
        if notHide {
            print("Show hidden Displays")
            UIApplication.shared.connectedScenes.filter { scene in
                let screen = (scene as? UIWindowScene)?.screen
                if let screen = screen {
                    if UIScreen.screens[1..<UIScreen.screens.count].contains(screen) {
                        return true
                    }
                }
                return false
            }.forEach { scene in
                
                print("FOUND SCENE")
                let screen = (scene as? UIWindowScene)?.screen
                if let screen = screen {
                    screenDidDisconnect(screen)
                    print("REPLACE SCREEN")
                    let window = UIWindow(frame: screen.bounds)

                    window.windowScene = UIApplication.shared.connectedScenes
                        .first { ($0 as? UIWindowScene)?.screen == screen }
                        as? UIWindowScene
                }
            }
        } else {
            UIScreen.screens[1..<UIScreen.screens.count].forEach { screen in
                screenDidConnect(screen, view: ExternalView())
            }
        }
    }
    
    func screenDidConnectNotification(_ screen: UIScreen) {
        screenDidConnect(screen, view: ExternalView())
    }
    
    func screenDidConnect<T: View>(_ screen: UIScreen, view: T) {
        if !notHide  {
            let window = UIWindow(frame: screen.bounds)

            window.windowScene = UIApplication.shared.connectedScenes
                .first { ($0 as? UIWindowScene)?.screen == screen }
                as? UIWindowScene

            let controller = UIHostingController(rootView: view)
            window.rootViewController = controller
            window.isHidden = false
            additionalWindows.append(window)
            print("SCREEN DID CONNECT")
        }
    }
    
    
    func screenDidDisconnect(_ screen: UIScreen) {
        additionalWindows.removeAll { $0.screen == screen }
        print("SCREEN DID DISCONNECT")
    }
    
}

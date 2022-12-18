//
//  SplatImagePainterApp.swift
//  SplatImagePainter
//
//  Created by Namikare Gikoha on 2022/12/17.
//

import SwiftUI

@main
struct SplatImagePainterApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView(appState: appState)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                // remove New Window
            }
            CommandGroup(replacing: .help) {
                Button (action: {
                    NSWorkspace.shared.open(URL(string: "https://github.com/vascarpenter/SplatImagePainter")!)
                }, label: {
                    Text("Show Website")
                })
            }
            CommandGroup(after: .newItem) {
                Button (action: {
                    appState.OpenFileItem()
                }, label: {
                    Text("画像を開く...")
                })
                .keyboardShortcut("O", modifiers:  [.command])
            }

        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate/*, NSWindowDelegate*/ {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        /*
         let rmMenuTitles = Set(["File"])
         
         if let mainMenu = NSApp.mainMenu {
         let menus = mainMenu.items.filter { item in
         return rmMenuTitles.contains(item.title)
         }
         for i in menus {
         mainMenu.removeItem(i)
         }
         }
         */
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // close app after last window closed
        return true
    }
    
}



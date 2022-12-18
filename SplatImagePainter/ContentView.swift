//
//  ContentView.swift
//  SplatImagePainter
//
//  Created by Namikare Gikoha on 2022/12/17.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appState : AppState
    
    var body: some View {
        VStack {
            Image(nsImage: appState.image ?? NSImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 320*3, height: 120*3)
            
            HStack {
                Button("Open Image...")
                {
                    appState.OpenFileItem()
                }
                
                Button("Save As bmpdata.h")
                {
                    appState.SaveFileItem()
                }
            }
            .padding()
        }
        .environmentObject(appState)
    }

}
                     


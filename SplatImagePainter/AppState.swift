//
//  AppState.swift
//  SplatImagePainter
//
//  Created by Namikare Gikoha on 2022/12/18.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftImage

class AppState: ObservableObject {
    @Published var image: NSImage? = nil
    
    func OpenFileItem()
    {
        // https://github.com/koher/swift-image を使用

        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [UTType.png, UTType.jpeg]
        if openPanel.runModal() == .OK {
            guard let url = openPanel.url,
                  let newImage = SwiftImage.Image<RGBA<UInt8>>(contentsOfFile: url.path)
            else { return }

            let slice = newImage.resizedTo(width: 320, height: 120)
            let cropped = SwiftImage.Image<RGBA<UInt8>>(slice)
            
            let threshold = UInt8(cropped.reduce(0) { $0 + $1.grayInt } / cropped.count)
            let resultimage = cropped.map { $0.gray >= threshold }
            image = resultimage.nsImage
            
            
        }
    }
    
    func SaveFileItem()
    {
        guard let ssimage = image else { return }  // if nil return
        var simage = SwiftImage.Image<Bool>(nsImage: ssimage)
        var str="const uint8_t Data[121][40] PROGMEM = {\n"
        for y in 0..<120
        {
            str += "{"
            for xx in 0..<40
            {
                let d = get8bit(image: simage, x: xx*8, y: y)
                str += "\(d)"
                
                if xx<39
                {
                    str += ","
                }
            }
            str += "},\n"
        }
        str += "{30,0,30,0,10,20,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,204,204}\n};\n"
        
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = "bmpdata.h"
        savePanel.begin { (result) in
            if result == .OK {
                guard let url = savePanel.url else { return }
                //print(url.absoluteString)
                do {
                    try str.write(to: url, atomically: true, encoding: String.Encoding.utf8) // utf8
                } catch {
                    // failed to write file (bad permissions, bad filename etc.)
                }
            }
        }
        
    }

    func get8bit(image: SwiftImage.Image<Bool>, x:Int, y:Int) -> Int
    {
        var c=0
        var bitmap = 0x80
        for i in 0..<8
        {
            if image[x+i,y] == true
            {
                c |= bitmap
            }
            bitmap >>= 1
        }
        return c
    }

}

//
//  AppState.swift
//  SplatImagePainter
//
//  Created by Namikare Gikoha on 2022/12/18.
//

import SwiftUI
import UniformTypeIdentifiers
import SwiftImage

let XSIZE = 320
let YSIZE = 120


class AppState: ObservableObject {
    @Published var image: NSImage? = nil

    func OpenFileCommon() -> URL?
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [UTType.png, UTType.jpeg]
        if openPanel.runModal() == .OK {
            return openPanel.url
        }
        return nil
    }
    
    func OpenFileItem()
    {
        guard let url = OpenFileCommon() else { return }
        guard let newImage = SwiftImage.Image<RGBA<UInt8>>(contentsOfFile: url.path) else { return }
        let slice = newImage.resizedTo(width: XSIZE, height: YSIZE)
        let cropped = SwiftImage.Image<RGBA<UInt8>>(slice)
        
        let threshold = UInt8(cropped.reduce(0) { $0 + $1.grayInt } / cropped.count)
        let resultimage = cropped.map { $0.gray >= threshold }
        image = resultimage.nsImage
    }
    
    func OpenFileWithDither()
    {
        guard let url = OpenFileCommon() else { return }
        guard let newImage = SwiftImage.Image<RGBA<UInt8>>(contentsOfFile: url.path) else { return }
        let slice = newImage.resizedTo(width: XSIZE, height: YSIZE)
        var cropped = SwiftImage.Image<RGBA<UInt8>>(slice)
        
        // Floyd Steinberg diffusion dither
        // 自動閾値計算
        let threshold = Float(cropped.reduce(0) { $0 + $1.grayInt } / cropped.count)

        var err : Float
        var fPixels = [[Float]](repeating: [Float](repeating:0.0,count:YSIZE), count:XSIZE)
        for y in 0..<YSIZE
        {
            for x in 0..<XSIZE
            {
                fPixels[x][y] = Float(cropped[x,y].gray)
            }
        }
        for y in 0..<YSIZE
        {
            for x in 0..<XSIZE
            {
                if fPixels[x][y]<threshold
                {
                    // black
                    err = fPixels[x][y]
                    fPixels[x][y] = 0
                }
                else
                {
                    // white
                    err = fPixels[x][y] - 255.0
                    fPixels[x][y] = 255.0
                }
                if x<XSIZE-1
                {
                    // 右
                    fPixels[x+1][y] += (err/16.0)*7.0
                }
                if y<YSIZE-1
                {
                    if  x>0
                    {
                        // 左下
                        fPixels[x-1][y+1] += (err/16.0)*3.0
                    }
                    
                    // 下
                    fPixels[x][y+1] += (err/16.0)*5.0
                    
                    if x<XSIZE-1
                    {
                        // 右下
                        fPixels[x+1][y+1] += (err/16.0)*1.0
                    }
                }
                err = 0.0
            }
        }
        for y in 0..<YSIZE
        {
            for x in 0..<XSIZE
            {
                let gray = UInt8(fPixels[x][y])
                cropped[x,y].red = gray
                cropped[x,y].green = gray
                cropped[x,y].blue = gray
            }
        }

        let resultimage = cropped.map { $0.gray >= 128 }
        image = resultimage.nsImage
    }
    
    func SaveFileItem()
    {
        guard let ssimage = image else { return }  // if nil return
        let simage = SwiftImage.Image<Bool>(nsImage: ssimage)
        var str="const uint8_t Data[121][40] PROGMEM = {\n"
        for y in 0..<YSIZE
        {
            str += "{"
            for xx in 0..<XSIZE/8
            {
                let d = get8bit(image: simage, x: xx*8, y: y)
                str += "\(d)"
                
                if xx<XSIZE/8-1
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

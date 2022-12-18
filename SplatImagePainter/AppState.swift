//
//  AppState.swift
//  SplatImagePainter
//
//  Created by Namikare Gikoha on 2022/12/18.
//

import SwiftUI
import UniformTypeIdentifiers


class AppState: ObservableObject {
    @Published var image: NSImage? = nil
    
    func OpenFileItem()
    {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedContentTypes = [UTType.png, UTType.jpeg]
        if openPanel.runModal() == .OK {
            guard let url = openPanel.url,
                  let newImage = CIImage(contentsOf: url)
            else { return }
            
            // https://github.com/koher/swift-image 使えば楽かなあ
            
            let filter = CIFilter(name: "CIColorControls")!
            filter.setValue(newImage, forKey: kCIInputImageKey)
            filter.setValue(0.0, forKey:kCIInputSaturationKey)
            filter.setValue(5.0, forKey:kCIInputContrastKey)
            let outputImage : CIImage = filter.outputImage!
            
            let targetSize = NSSize(width:320, height:120)
            
            let rep = NSCIImageRep(ciImage: outputImage)
            let bitmaprep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                             pixelsWide: Int(targetSize.width),
                                             pixelsHigh: Int(targetSize.height),
                                             bitsPerSample: 8,
                                             samplesPerPixel: 4,
                                             hasAlpha: true,
                                             isPlanar: false,
                                             colorSpaceName: NSColorSpaceName.deviceRGB,
                                             bytesPerRow: Int(targetSize.width * 4),
                                             bitsPerPixel: 32)
            let ctx = NSGraphicsContext(bitmapImageRep: bitmaprep!)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = ctx
            rep.draw(in: NSMakeRect(0, 0, targetSize.width, targetSize.height))
            ctx?.flushGraphics()
            NSGraphicsContext.restoreGraphicsState()
            
            image = NSImage(size: targetSize)
            image?.addRepresentation(bitmaprep!)
            
        }
    }
    
    func SaveFileItem()
    {
        var imageRect = CGRect(x: 0, y: 0,
                               width: (image?.size.width)!,
                               height: (image?.size.height)!)
        let imageRef = image?.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        let data = imageRef!.dataProvider!.data
        let bytes = CFDataGetBytePtr(data)!
        let bytesPerPixel = imageRef!.bitsPerPixel / imageRef!.bitsPerComponent
        var str="const uint8_t Data[121][40] PROGMEM = {\n"
        for y in 0..<120
        {
            str += "{"
            for xx in 0..<40
            {
                let offset = (y * imageRef!.bytesPerRow) + (xx * bytesPerPixel * 8)
                let d = get8bit(ptr: bytes, offset: offset)
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

    func get8bit(ptr: UnsafePointer<UInt8>, offset: Int) -> Int
    {
        var c=0
        var bitmap = 0x80
        for i in 0..<8
        {
            if ptr[offset+i*4]>128
            {
                c |= bitmap
            }
            bitmap >>= 1
        }
        return c
    }

}

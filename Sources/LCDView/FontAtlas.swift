import MetalKit

class FontAtlas {
    var fontTexture: MTLTexture?
    
    init(device: MTLDevice) {
        // We'll load the texture from the app's bundle
        let loader = MTKTextureLoader(device: device)
        
        // Try to load the font texture if available
        if let textureURL = Bundle.module.url(forResource: "lcd_font", withExtension: "png") {
            do {
                fontTexture = try loader.newTexture(URL: textureURL, options: nil)
            } catch {
                print("Failed to load font texture: \(error)")
            }
        } else {
            print("Could not find lcd_font.png resource")
        }
    }
    
    func getCharRect(_ char: Character) -> CGRect {
        guard let asciiValue = char.asciiValue else {
            return .zero
        }
        
        let ascii = Int(asciiValue)
        let cols = 16  // Assume 16 chars per row in the texture
        let x = (ascii % cols) * 8
        let y = (ascii / cols) * 8
        return CGRect(x: x, y: y, width: 8, height: 8)
    }
}

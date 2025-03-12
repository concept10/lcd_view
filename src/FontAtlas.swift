import MetalKit

class FontAtlas {
    var fontTexture: MTLTexture
    
    init(device: MTLDevice, textureName: String) {
        let loader = MTKTextureLoader(device: device)
        let url = Bundle.main.url(forResource: textureName, withExtension: "png")!
        fontTexture = try! loader.newTexture(URL: url, options: nil)
    }
    
    func getCharRect(_ char: Character) -> CGRect {
        let ascii = Int(char.asciiValue!)
        let cols = 16  // Assume 16 chars per row in the texture
        let x = (ascii % cols) * 8
        let y = (ascii / cols) * 8
        return CGRect(x: x, y: y, width: 8, height: 8)
    }
}
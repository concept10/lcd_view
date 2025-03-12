import SwiftUI
import Metal
import MetalKit

struct MetalLCDView: NSViewRepresentable {
    var textureData: [Float]
    var text: String
    var midiActive: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        mtkView.colorPixelFormat = .bgra8Unorm
        mtkView.framebufferOnly = false
        
        context.coordinator.setupMetal()
        return mtkView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {
        context.coordinator.textureData = textureData
        context.coordinator.text = text
        context.coordinator.midiActive = midiActive
        context.coordinator.updateBuffers()
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalLCDView
        var device: MTLDevice!
        var commandQueue: MTLCommandQueue!
        var pipelineState: MTLRenderPipelineState!
        var textBuffer: MTLBuffer!
        var waveformBuffer: MTLBuffer!
        var vertexBuffer: MTLBuffer!
        var fontTexture: MTLTexture?
        var waveTexture: MTLTexture?
        var midiActiveBuffer: MTLBuffer!
        
        var textureData: [Float]
        var text: String
        var midiActive: Bool
        var fontAtlas: FontAtlas?
        
        init(_ parent: MetalLCDView) {
            self.parent = parent
            self.textureData = parent.textureData
            self.text = parent.text
            self.midiActive = parent.midiActive
            super.init()
        }
        
        func setupMetal() {
            device = MTLCreateSystemDefaultDevice()
            commandQueue = device.makeCommandQueue()
            
            // Create the render pipeline
            let library = device.makeDefaultLibrary()
            let vertexFunction = library?.makeFunction(name: "vertexShader")
            let fragmentFunction = library?.makeFunction(name: "fragmentShader")
            
            let pipelineDescriptor = MTLRenderPipelineDescriptor()
            pipelineDescriptor.vertexFunction = vertexFunction
            pipelineDescriptor.fragmentFunction = fragmentFunction
            pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            
            do {
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create pipeline state: \(error)")
            }
            
            createBuffers()
            loadTextures()
            
            // Initialize font atlas
            fontAtlas = FontAtlas(device: device)
        }
        
        func createBuffers() {
            // Create vertex buffer for a quad covering the screen
            let quadVertices: [Float] = [
                -1.0, -1.0, 0.0, 1.0,
                 1.0, -1.0, 1.0, 1.0,
                -1.0,  1.0, 0.0, 0.0,
                 1.0,  1.0, 1.0, 0.0
            ]
            vertexBuffer = device.makeBuffer(bytes: quadVertices, length: quadVertices.count * MemoryLayout<Float>.size, options: [])
            
            // Create a buffer for waveform data
            waveformBuffer = device.makeBuffer(bytes: textureData, length: textureData.count * MemoryLayout<Float>.size, options: [])
            
            // Create a buffer for text data
            let textBytes = Array(text.utf8)
            textBuffer = device.makeBuffer(bytes: textBytes, length: textBytes.count * MemoryLayout<UInt8>.size, options: [])
            
            // MIDI active status
            let midiStatus: [UInt8] = [midiActive ? 1 : 0]
            midiActiveBuffer = device.makeBuffer(bytes: midiStatus, length: MemoryLayout<UInt8>.size, options: [])
        }
        
        func loadTextures() {
            // Load font texture
            if let fontImage = NSImage(named: "lcd_font") {
                fontTexture = loadTexture(from: fontImage)
            }
            
            // Load wave table texture
            if let waveImage = NSImage(named: "wave_table") {
                waveTexture = loadTexture(from: waveImage)
            }
        }
        
        func loadTexture(from image: NSImage) -> MTLTexture? {
            guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
                return nil
            }
            
            let textureLoader = MTKTextureLoader(device: device)
            do {
                return try textureLoader.newTexture(cgImage: cgImage, options: nil)
            } catch {
                print("Failed to load texture: \(error)")
                return nil
            }
        }
        
        func updateBuffers() {
            // Update waveform buffer with new data
            if let buffer = waveformBuffer {
                memcpy(buffer.contents(), textureData, textureData.count * MemoryLayout<Float>.size)
            }
            
            // Update text buffer with new text
            if let buffer = textBuffer {
                let textBytes = Array(text.utf8)
                memcpy(buffer.contents(), textBytes, min(textBytes.count, buffer.length))
            }
            
            // Update MIDI status
            if let buffer = midiActiveBuffer {
                let midiStatus: [UInt8] = [midiActive ? 1 : 0]
                memcpy(buffer.contents(), midiStatus, MemoryLayout<UInt8>.size)
            }
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
            // Handle resize if needed
        }
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let renderPassDescriptor = view.currentRenderPassDescriptor else {
                return
            }
            
            // Create command buffer and encoder
            guard let commandBuffer = commandQueue.makeCommandBuffer(),
                  let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
            }
            
            // Set the pipeline state
            renderEncoder.setRenderPipelineState(pipelineState)
            
            // Set vertex buffer
            renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            
            // Set fragment buffer and textures
            renderEncoder.setFragmentBuffer(waveformBuffer, offset: 0, index: 0)
            renderEncoder.setFragmentBuffer(textBuffer, offset: 0, index: 1)
            renderEncoder.setFragmentBuffer(midiActiveBuffer, offset: 0, index: 2)
            
            if let fontTexture = fontTexture {
                renderEncoder.setFragmentTexture(fontTexture, index: 0)
            }
            
            if let waveTexture = waveTexture {
                renderEncoder.setFragmentTexture(waveTexture, index: 1)
            }
            
            // Draw the quad
            renderEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
            
            // Finish encoding and submit to GPU
            renderEncoder.endEncoding()
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
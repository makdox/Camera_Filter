//
//  ContentView.swift
//  Camera_Filter
//
//  Created by Max Donets on 20.07.2023.
//


import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI

class FilterManager: ObservableObject {
    @Published var image: UIImage?
    @Published var filterIntensity: Double = 0.5 {
        didSet {
            applySepiaFilter()
        }
    }
    
    private func applySepiaFilter() {
        guard let inputImage = CIImage(image: image!) else { return }
        let context = CIContext()
        let filter = CIFilter.sepiaTone()
        filter.inputImage = inputImage
        filter.intensity = Float(filterIntensity)
        
        if let outputImage = filter.outputImage, let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            self.image = UIImage(cgImage: cgImage)
        }
    }
}

struct ContentView: View {
    @StateObject private var filterManager = FilterManager()
    @State private var showImagePicker: Bool = false
    
    var body: some View {
        VStack {
            if let uiImage = filterManager.image {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay(Text("Sepia Filter")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(10)
                        .padding(10)
                        , alignment: .topLeading
                    )
            } else {
                Spacer()
                Text("Choose photo from Library")
            }
            
            
            HStack {
                Button("Take Photo", action: {
                    self.showImagePicker = true
                })
                .padding()
                
                Slider(value: $filterManager.filterIntensity, in: 0.0...1.0, step: 0.01)
                    .padding(.horizontal)
                
                Button("Save", action: {
                    saveImageToPhotoLibrary()
                })
                .padding()
            }
        }
        .sheet(isPresented: $showImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $filterManager.image)
        }
    }
    
    func loadImage() {
    }
    
    func saveImageToPhotoLibrary() {
        if let filteredImage = filterManager.image {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: filteredImage)
            } completionHandler: { success, error in
                if success {
                    print("Image saved to the photo library successfully.")
                } else {
                    print("Error saving image to the photo library: \(error?.localizedDescription ?? "")")
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}









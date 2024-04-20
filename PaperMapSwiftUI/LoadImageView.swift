//
//  LoadImageView.swift
//  PaperMapSwiftUI
//

import SwiftUI
import UIKit

//https://betterprogramming.pub/how-to-pick-an-image-from-camera-or-photo-library-in-swiftui-a596a0a2ece

// Использование встроенного UIKit элемента "UIViewControllerRepresentable" в SwiftUI
struct LoadImageView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType = .photoLibrary // Выбор загрузки изображения
    @Binding var image: Image? // Изображение карты
    @Binding var isPresented: Bool // Контроль открытия окна
    
    func makeCoordinator() -> ImagePickerViewCoordinator {
        return ImagePickerViewCoordinator(image: $image, isPresented: $isPresented)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = context.coordinator
        return pickerController
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Ничего не обновляет
    }
}

// Использование встроенного UIKit элемента в SwiftUI для координатора в LoadImageView
class ImagePickerViewCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @Binding var image: Image?
    @Binding var isPresented: Bool
    
    init(image: Binding<Image?>, isPresented: Binding<Bool>) {
        self._image = image
        self._isPresented = isPresented
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = Image(uiImage: image)
        }
        self.isPresented = false
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.isPresented = false
    }
    
}

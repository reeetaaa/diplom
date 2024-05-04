//
//  MainPageView.swift
//  PaperMapSwiftUI
//
//  Created by Margarita Babukhadia on 16/10/23.
//

import SwiftUI

// Основной экран
struct MainPageView: View {
    
    // Изображение карты
    @State private var image: Image? = DataSource.instance.mapImage
    
    // Менеджер для определения координат пользователя
    @StateObject var locationDataManager = MyAppLogic.instance.locationDataManager
    
    // Окна, которые должны быть открыты на этой странице
    @State private var showImagePicker = false // Страница выбора изображения
    @State private var showSettings = false // Страница настроек типа координат
    @State private var showActionScheet = false // Меню выбора типа загрузки изображения
    @State private var showCornersPage = false // Страница указания координат углов карты
    @State private var showCorrectionPage = false // Страница коррекции карты
    @State private var showMap = false // Страница карты отслеживания геопозиции пользователя на изображении карты
    
    @State private var cornersAreSet: Bool = false // Углы карты установлены (разрешение нажатия кнопок на экране)
    
    @State private var imagePickerType: UIImagePickerController.SourceType = .camera // Тип загрузки изображения (Фото с камеры или изображение из галереи)
    
    var body: some View {
        // Запрос разрешения геопозиции
        switch locationDataManager.authorizationStatus {
            // Если пользователь не дал разрешение на использование геопозиции
            case .restricted, .denied:
                Text("Вы отказались от использования геопозиции.")
                Text("Это приложение не может работать без использования вашей геопозиции. Чтобы изменить настройки:")
                Text("откройте Настройки -> Конфиденциальность и безопасность -> Службы геолокации -> (найдите это приложение в списке) -> (сделайте выбор)")
            
            // Если происходит поиск гепозиции
            case .notDetermined:
                Text("Ищем вашу геопозицию...")
                ProgressView()
                
            // Если использование геопозиции разрешено
            case .authorizedWhenInUse:
                NavigationStack {
                    
                    Spacer() // ------------------------------------
                        // Если изображение загружено, то над кнопкой "Загрузка изображения карты"
                        // появится preview карты
                        .background {
                            ZStack {
                                if let image = image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                            .frame(width: UIScreen.main.bounds.width, alignment: .bottom)
                        }
                    
                    Button("Загрузка изображения карты", systemImage: "folder") {
                        showActionScheet = true
                    }
                    // Открытие опций выбора загрузки изображения
                    .actionSheet(isPresented: $showActionScheet) { () -> ActionSheet in
                        ActionSheet(title: Text("Опции выбора"),
                                    message: Text("Выберите тип загрузки изображения"),
                                    buttons: [ActionSheet.Button.default(Text("Камера"),
                                                                         action: {
                                                                            self.showImagePicker = true
                                                                            self.imagePickerType = .camera
                                                                        }),
                                              ActionSheet.Button.default(Text("Галерея"),
                                                                         action: {
                                                                            self.showImagePicker = true
                                                                            self.imagePickerType = .photoLibrary
                                                                        }),
                                              ActionSheet.Button.cancel(Text("Отмена"))])
                    }
                    // Открытие окна загрузки изображения
                    .sheet(isPresented: $showImagePicker) {
                        LoadImageView(sourceType: self.imagePickerType,
                                      image: self.$image,
                                      isPresented: self.$showImagePicker)
                    }
                    // При изменении картинки сохранить ее в памяти
                    .onChange(of: image) {
                        MyAppLogic.instance.selectMapImage(image: image)
                    }
                    
                    Spacer() // ------------------------------------
                    
                    Button("Настройка точности координат") {
                        showSettings = true
                    }
                    .disabled(image == nil)
                    .navigationDestination(isPresented: $showSettings) {
                        SettingsView()
                    }
                    
                    Spacer() // ------------------------------------
                    
                    Button("Установка углов карты") {
                        showCornersPage = true
                    }
                    .disabled(image == nil)
                    .navigationDestination(isPresented: $showCornersPage) {
                        SetCornersView()
                    }
                    
                    Spacer() // ------------------------------------
                    
                    Button("Коррекция карты") {
                        showCorrectionPage = true
                    }
                    .disabled(image == nil)
                    .navigationDestination(isPresented: $showCorrectionPage) {
                        SetCorrectionView(showCorrectionPage: $showCorrectionPage)
                    }
                    
                    Spacer() // ------------------------------------
                    
                    Button("Показать карту") {
                        showMap = true
                    }
                    .disabled(!cornersAreSet)
                    .onAppear() {
                        cornersAreSet = MyAppLogic.instance.areCornersSet()
                    }
                    .navigationDestination(isPresented: $showMap) {
                        MapView()
                    }
                    
                    Spacer() // ------------------------------------
                }
                // Если координаты пользователя изменились, обновить переменную координат пользователя
                .onChange(of: locationDataManager.coord) {
                    MyAppLogic.instance.lastSavedCoord = locationDataManager.coord
                }
                
            default:
                ProgressView()
            }
    }
}

#Preview {
    MainPageView()
}

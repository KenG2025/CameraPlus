//
//  AddEntryView.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//


import SwiftUI
import SwiftData
import PhotosUI
import UIKit

struct AddEntryView:View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = AddEntryViewModel()

    @State private var beforePickerItem: PhotosPickerItem? = nil
    @State private var afterPickerItem: PhotosPickerItem? = nil
    
    @State private var showBeforeCamera: Bool = false
    @State private var showAfterCamera: Bool = false
    
    
    private var cameraAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }

    var body: some View {
        VStack(spacing:16){
            Text("New Progress Entry")
                .font(.title2)

            // BEFORE PICKER
            VStack{
                Text("Before").font(.headline)
                photoBox(image: vm.beforeImage)
                
                HStack{
                    PhotosPicker("Choose photo",selection: $beforePickerItem,matching: .images)
                    Button("Take a photo"){
                        showBeforeCamera = true
                    }.disabled(cameraAvailable == false)
                }
                
                if cameraAvailable == false {
                    Text("Camera not available (use a real device).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            VStack{
                Text("After").font(.headline)
                photoBox(image: vm.afterImage)
                
                HStack{
                    PhotosPicker("Choose photo",selection: $afterPickerItem,matching: .images)
                    Button("Take a photo"){
                        showAfterCamera = true
                    }.disabled(cameraAvailable == false)
                }
                
                if cameraAvailable == false {
                    Text("Camera not available (use a real device).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
            }
            
            
            TextField("Optional note...", text: $vm.note)
                .textFieldStyle(.roundedBorder).padding()
            
            Button("Save"){
                let didSave = vm.save(modelContext: modelContext)
                if didSave {
                    dismiss()
                }
                   
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.canSave() == false)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Add Entry")
        .navigationBarTitleDisplayMode(.inline)
        
        // Library -> ViewModel
        .onChange(of:beforePickerItem){_, newItem in
            vm.setBeforePickerItem(newItem)
            
        }
        
        .onChange(of:afterPickerItem){_, newItem in
            vm.setAfterPickerItem(newItem)
            
        }
        
        .sheet(isPresented:$showBeforeCamera){
            CameraPicker{ image in
                vm.beforeImage = image
            }
        }
        
        .sheet(isPresented:$showAfterCamera){
            CameraPicker{ image in
                vm.afterImage = image
            }
        }
        
        // Error alert
        .alert("Error", isPresented: $vm.showError) {
            Button("OK") { }
        } message: {
            Text(vm.errorMessage)
        }
    }
}

func photoBox(image:UIImage?)-> some View{
    ZStack{
        RoundedRectangle(cornerRadius: 12)
            .stroke(style: StrokeStyle(lineWidth: 1,dash: [16]))
            .frame(height: 180)
        
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }else {
            Text("No photo selected")
                .foregroundStyle(.secondary)
        }
        
    }
}


#Preview {
  
    NavigationStack{
        AddEntryView()

    }.modelContainer(for:ProgressEntry.self,inMemory: true)
    
}

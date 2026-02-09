//
//  CameraView.swift
//  CameraPlus
//
//  Created by Ken Gonzalez on 2/5/26.
//

import SwiftUI
import SwiftData

struct FeedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ProgressEntry.createdAt, order: .reverse)
    
    private var entries: [ProgressEntry] = []
    private let imageStore = ImageFileStore()
    
    var body: some View {
        NavigationStack{
            List{
                ForEach(entries){entry in
                    NavigationLink{
                        EntryDetailView(entry: entry)
                    } label:{
                        HStack{
                            if let img = imageStore.loadIMG(fileName:entry.beforeImage){
                                Image(uiImage: img)
                                    .resizable()
                                    .frame(width: 54, height: 54)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }else{
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 54, height: 54)

                            }
                            VStack{
                                Text(entry.createdAt,style:.date)
                                if entry.note!.isEmpty == false {
                                    Text(entry.note!)
                                        .lineLimit(1)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    
                }.onDelete(perform: delete)

            }
            .navigationTitle("Progress Tracker")
            .toolbar{
                NavigationLink("Add"){
                    AddEntryView()
                }
            }
        }
    }
    
    func delete(_ indexSet: IndexSet){
        for index in indexSet{
            let entry = entries[index]
            imageStore.deleteIMG(fileName: entry.beforeImage)
            imageStore.deleteIMG(fileName: entry.afterImage)
            
            modelContext.delete(entry)

        }
        
        try? modelContext.save()
    }
    
    
    
}

#Preview {
    FeedView().modelContainer(for: ProgressEntry.self , inMemory: true)
}

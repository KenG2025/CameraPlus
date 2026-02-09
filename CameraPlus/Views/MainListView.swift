//
//  MainListView.swift
//  LocationService
//
//  Created by Ken Gonzalez on 2/9/26.
//

import SwiftUI
import SwiftData

enum DateFilter: String, CaseIterable, Identifiable {
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case all = "All"

    var id: String { rawValue }

    func predicate(for keyPath: String = "createdAt") -> Predicate<ProgressEntry>? {
        let now = Date()
        let calendar = Calendar.current
        switch self {
        case .thisWeek:
            guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return nil }
            return #Predicate<ProgressEntry> { entry in
                entry.createdAt >= startOfWeek && entry.createdAt <= now
            }
        case .thisMonth:
            guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return nil }
            return #Predicate<ProgressEntry> { entry in
                entry.createdAt >= startOfMonth && entry.createdAt <= now
            }
        case .all:
            return nil
        }
    }
}

struct MainListView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var filter: DateFilter = .all
    @State private var showAdd = false
    @State private var pendingDelete: ProgressEntry?

    @Query(sort: \ProgressEntry.createdAt, order: .reverse)
    private var entries: [ProgressEntry]

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $filter) {
                    ForEach(DateFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    ForEach(filteredEntries) { entry in
                        NavigationLink {
                            DetailView(entry: entry)
                        } label: {
                            HStack(spacing: 12) {
                                DiskImage(url: entry.beforeURL, placeholderSystemName: "photo")
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                DiskImage(url: entry.afterURL, placeholderSystemName: "photo.fill")
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                VStack(alignment: .leading) {
                                    Text(entry.createdAt, style: .date)
                                        .font(.headline)
                                    if let note = entry.note, !note.isEmpty {
                                        Text(note)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer()
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                pendingDelete = entry
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        if let idx = indexSet.first {
                            pendingDelete = filteredEntries[idx]
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddEntryView()
            }
            .alert("Delete Entry?", isPresented: .constant(pendingDelete != nil), presenting: pendingDelete) { entry in
                Button("Delete", role: .destructive) { delete(entry) }
                Button("Cancel", role: .cancel) { pendingDelete = nil }
            } message: { entry in
                Text("This will remove the entry and delete associated images from disk.")
            }
        }
    }

    private var filteredEntries: [ProgressEntry] {
        guard let predicate = filter.predicate() else { return entries }
        // Manual filtering since @Query cannot be changed dynamically without re-instantiation
        return entries.filter { entry in
            // Evaluate the predicate manually
            // SwiftData Predicates cannot be evaluated directly, so we re-create the time logic:
            let now = Date()
            let calendar = Calendar.current
            switch filter {
            case .thisWeek:
                guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) else { return true }
                return entry.createdAt >= startOfWeek && entry.createdAt <= now
            case .thisMonth:
                guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return true }
                return entry.createdAt >= startOfMonth && entry.createdAt <= now
            case .all:
                return true
            }
        }
    }

    private func delete(_ entry: ProgressEntry) {
        // Remove from SwiftData
        modelContext.delete(entry)
        // Cleanup images from disk
        FileManager.default.deleteFileIfExists(atRelativePath: entry.beforeImage)
        FileManager.default.deleteFileIfExists(atRelativePath: entry.afterImage)
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after delete: \(error)")
        }
        pendingDelete = nil
    }
}

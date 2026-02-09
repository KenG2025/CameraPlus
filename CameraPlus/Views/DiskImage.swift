import SwiftUI

struct DiskImage: View {
    let url: URL?
    let placeholderSystemName: String
    
    @State private var phase: Phase = .placeholder
    @State private var loadedImage: Image?
    
    enum Phase {
        case placeholder
        case loading
        case success
        case failure
    }
    
    init(url: URL?, placeholderSystemName: String) {
        self.url = url
        self.placeholderSystemName = placeholderSystemName
    }
    
    var body: some View {
        ZStack {
            switch phase {
            case .placeholder, .loading:
                placeholder
            case .success:
                loadedImage?
                    .resizable()
                    .scaledToFill()
            case .failure:
                placeholder
            }
        }
        .task {
            await loadIfNeeded()
        }
        .onChange(of: url) { _ in
            Task { await loadIfNeeded(force: true) }
        }
        .accessibilityLabel(Text(accessibilityLabel))
    }
    
    private var placeholder: some View {
        Image(systemName: placeholderSystemName)
            .resizable()
            .scaledToFit()
            .foregroundStyle(.secondary)
            .padding()
    }
    
    private var accessibilityLabel: String {
        if case .success = phase {
            return "Image"
        } else {
            return "Placeholder image"
        }
    }
    
    @MainActor
    private func setImage(from data: Data) {
        #if canImport(UIKit)
        if let uiImage = UIImage(data: data) {
            loadedImage = Image(uiImage: uiImage)
            phase = .success
        } else {
            phase = .failure
        }
        #elseif canImport(AppKit)
        if let nsImage = NSImage(data: data) {
            loadedImage = Image(nsImage: nsImage)
            phase = .success
        } else {
            phase = .failure
        }
        #else
        phase = .failure
        #endif
    }
    
    private func cacheURL(for url: URL) -> URL? {
        do {
            let caches = try FileManager.default.url(for: .cachesDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: true)
            let fileName = url.absoluteString
                .addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
            return caches.appendingPathComponent("DiskImageCache").appendingPathComponent(fileName)
        } catch {
            return nil
        }
    }
    
    private func loadFromDisk(for url: URL) -> Data? {
        guard let fileURL = cacheURL(for: url) else { return nil }
        return try? Data(contentsOf: fileURL)
    }
    
    private func saveToDisk(_ data: Data, for url: URL) {
        guard let fileURL = cacheURL(for: url) else { return }
        do {
            try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(),
                                                    withIntermediateDirectories: true)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            // Ignore cache write errors
        }
    }
    
    private func fetchRemoteData(for url: URL) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    @MainActor
    private func beginLoading() {
        if case .loading = phase { return }
        phase = .loading
        loadedImage = nil
    }
    
    private func loadIfNeeded(force: Bool = false) async {
        guard let url else {
            await MainActor.run { phase = .failure }
            return
        }
        
        await MainActor.run { beginLoading() }
        
        // Try disk cache first
        if !force, let cached = loadFromDisk(for: url) {
            await MainActor.run { setImage(from: cached) }
            return
        }
        
        // Fetch remote
        do {
            let data = try await fetchRemoteData(for: url)
            saveToDisk(data, for: url)
            await MainActor.run { setImage(from: data) }
        } catch {
            // If we failed fetching, fallback to cached if available
            if let cached = loadFromDisk(for: url) {
                await MainActor.run { setImage(from: cached) }
            } else {
                await MainActor.run { phase = .failure }
            }
        }
    }
}

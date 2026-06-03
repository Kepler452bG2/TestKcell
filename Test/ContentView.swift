//
//  ContentView.swift
//  Test
//
//  Created by adil on 02.06.2026.
//

import SwiftUI
import Combine


// MARK: - Model
struct Service: Identifiable, Equatable {
    let id: Int
    let title: String
    let price: Int
}

// MARK: - Provider
protocol ServiceProvider {
    func fetchServices() async throws -> [Service]
}

// MARK: - Mock
enum DemoError: Error { case network }

final class MockServiceProvider: ServiceProvider {
    var delay: UInt64 = 1_000_000_000
    var result: Result<[Service], Error> = .success([
        Service(id: 1, title: "Безлимит на ночь", price: 500),
        Service(id: 2, title: "Бонус-пакет",       price: 0),
        Service(id: 3, title: "Роуминг Турция",     price: 2990),
    ])
    func fetchServices() async throws -> [Service] {
        try await Task.sleep(nanoseconds: delay)
        return try result.get()
    }
}

// MARK: - ViewModel
@MainActor
final class ServicesViewModel: ObservableObject {
    @Published var services: [Service] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let provider: ServiceProvider

    init(provider: ServiceProvider) {
        self.provider = provider
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            services = try await provider.fetchServices()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - View
struct ServicesView: View {
    @StateObject var viewModel: ServicesViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Загрузка...")

                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "wifi.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Повторить") {
                            Task { await viewModel.load() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                } else if viewModel.services.isEmpty {
                    Text("Услуги не найдены")
                        .foregroundColor(.secondary)

                } else {
                    List(viewModel.services) { service in
                        HStack {
                            Text(service.title)
                            Spacer()
                            Text(service.price == 0 ? "Бесплатно" : "\(service.price) ₸")
                                .foregroundColor(service.price == 0 ? .green : .primary)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Услуги")
        }
        .task { await viewModel.load() }
    }
}

struct ContentView: View {
    var body: some View {
        ServicesView(viewModel: ServicesViewModel(provider: MockServiceProvider()))
    }
}

#Preview {
    ContentView()
}

//
//  Live Coding — «Список услуг» (iOS 15+, чистый SwiftUI)
//
//  Как запустить:
//  1. Создай новый проект: Xcode → App → Interface: SwiftUI, iOS 15+.
//  2. Вставь содержимое этого файла в ContentView.swift (замени всё).
//  3. Открой Canvas (⌥⌘↩) — превью внизу покажет экран.
//
//  Что нужно сделать — смотри пометки TODO.
//  Файл MockServiceProvider трогать НЕ нужно.
//

import SwiftUI
import Combine

// MARK: - Model

struct Service: Identifiable, Equatable {
    let id: Int
    let title: String
    let price: Int          // в тенге, 0 = бесплатно
}

// MARK: - Provider (протокольный шов — НЕ трогать)

protocol ServiceProvider {
    func fetchServices() async throws -> [Service]
}

// MARK: - Mock (готов; имитирует сеть)

enum DemoError: Error { case network }

final class MockServiceProvider: ServiceProvider {
    var delay: UInt64 = 1_000_000_000          // 1 сек
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
    // TODO: а где состояние ошибки?

    private let provider: ServiceProvider

    init(provider: ServiceProvider) {
        self.provider = provider
    }

    func load() async {
        // TODO: загрузи услуги через provider.fetchServices()
        //       управляй isLoading, обработай ошибку, подумай про пустой список.
    }
}

// MARK: - View

struct ServicesView: View {
    @StateObject var viewModel: ServicesViewModel

    var body: some View {
        // TODO: покажи список услуг (title + price).
        //       Состояния: загрузка / ошибка / пусто / данные.
        Text("TODO")
            .task { await viewModel.load() }
    }
}

// MARK: - Preview

struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView(viewModel: ServicesViewModel(provider: MockServiceProvider()))
    }
}

//  ContentView.swift
//  ORAControl – Chat UI Safe Build
//  Xcode 16.4 / iOS 17-18・macOS 14-26 で動作確認

import SwiftUI

// MARK: - ① アプリ共通スタイル
enum AppStyle {
    static let bubbleRadius : CGFloat = 14
    static let inputRadius  : CGFloat = 40
    static let baseFont     : Font    = .system(size: 16)

    /// デモ用：LLM のおしゃべり
    static func demoReply(for text: String) -> String { "『\(text)』ですね！" }
}

// MARK: - ② チャット行データ
struct ChatMessage: Identifiable {
    let id = UUID()
    let text  : String
    let isUser: Bool
}

// MARK: - ③ ルートビュー
struct ContentView: View {

    @Environment(\.colorScheme) private var scheme
    @State private var message  = ""
    @State private var thinking = false
    @State private var log: [ChatMessage] = [
        .init(text: "こんにちは！何でも聞いてね。", isUser: false)
    ]

    /// ⚡️モデル切替用
    @State private var currentModel = "Llama-3-8B-Instruct"

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ChatArea(log: log)

                InputBar(message: $message,
                         thinking: $thinking,
                         currentModel: $currentModel) { txt in
                    appendUser(txt)
                    simulateLLM(for: txt)
                }
            }
            .tint(Color.accentColor)
            .font(AppStyle.baseFont)
        }
    }

    // MARK: - ロジック
    private func appendUser(_ text: String) {
        log.append(.init(text: text, isUser: true))
    }

    private func simulateLLM(for text: String) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            log.append(.init(text: AppStyle.demoReply(for: text), isUser: false))
        }
    }
}

// MARK: - ④ チャット一覧
private struct ChatArea: View {
    let log: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(log) { ChatBubble(msg: $0).id($0.id) }
                }
                .padding(.horizontal)
                .padding(.bottom, 80)          // 入力バー分
            }
            .onChange(of: log.last?.id) { id in
                if let id {
                    withAnimation(.easeOut(duration: 0.25)) {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

// ---------- 吹き出し ----------
private struct ChatBubble: View {
    let msg: ChatMessage

    var body: some View {
        HStack {
            if msg.isUser { Spacer(minLength: 40) }

            Text(msg.text)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: AppStyle.bubbleRadius, style: .continuous)
                        .fill(msg.isUser ? Color.accentColor
                                         : Color.secondary.opacity(0.15))
                )
                .foregroundStyle(msg.isUser ? .white : .primary)
                .frame(maxWidth: .infinity,
                       alignment: msg.isUser ? .trailing : .leading)

            if !msg.isUser { Spacer(minLength: 40) }
        }
        .padding(msg.isUser ? .leading : .trailing, 32)
        .transition(.move(edge: msg.isUser ? .trailing : .leading)
                    .combined(with: .opacity))
    }
}

// MARK: - ⑤ 入力バー（アイコン付き）
private struct InputBar: View {

    // 入力 & 状態
    @Binding var message: String
    @Binding var thinking: Bool
    @Binding var currentModel: String
    var onSend: (String) -> Void

    // 内部
    @State private var fastMode  = true
    @State private var scale: CGFloat = 1
    @State private var showSelectModel = false
    @State private var showLive       = false
    @State private var streaming      = false
    @Namespace private var ns

    var body: some View {
        HStack(spacing: 10) {

            // 📎 添付
            icon("paperclip") { /* UIDocumentPicker */ }

            // ⚡️ モード切替
            icon(fastMode ? "bolt.fill" : "tortoise.fill",
                 tint: fastMode ? .yellow : .cyan) {
                bounce(); fastMode.toggle()
            }
            .contextMenu {
                Button("Fast") { fastMode = true }
                Button("Slow") { fastMode = false }
            }

            // 💡 Thinking
            icon(thinking ? "lightbulb.fill" : "lightbulb",
                 tint: thinking ? .orange : .secondary) {
                bounce(); thinking.toggle()
            }

            // 🎤 音声入力
            icon("mic.fill") { /* SpeechRecognizer */ }

            // 入力フィールド
            ZStack(alignment: .leading) {
                if message.isEmpty {
                    Text("何でも聞いて")
                        .foregroundStyle(.secondary)
                }
                TextField("", text: $message, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(1...4)
            }
            .padding(.vertical, 8)

            // 送信 / Live 切替
            Button {
                bounce()
                if message.isEmpty {
                    showLive = true                 // Live 画面へ
                } else {
                    onSend(message)
                    message = ""
                }
            } label: {
                Image(systemName: message.isEmpty ? "bolt.horizontal"
                                                  : "paperplane.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(message.isEmpty ? Color.accentColor : .white)
                    .padding(12)
                    .background(
                        Circle()
                            .fill(message.isEmpty ? .thinMaterial
                                                  : Color.accentColor)
                            .matchedGeometryEffect(id: "rightBtn", in: ns)
                    )
            }
            .disabled(message.isEmpty && streaming)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppStyle.inputRadius, style: .continuous)
                .background(.thinMaterial,
                            in: RoundedRectangle(cornerRadius: AppStyle.inputRadius,
                                                 style: .continuous))
        )
        .padding(.horizontal)
        .padding(.bottom, 10)
        // シート：Model 選択 & Live
        .sheet(isPresented: $showSelectModel) { ModelPicker(model: $currentModel) }
        .sheet(isPresented: $showLive)       { LiveChatView(model: currentModel) }
        .scaleEffect(scale)
        .animation(.spring(response: 0.25, dampingFraction: 0.5), value: scale)
    }

    // --- 共通アイコン ---
    private func icon(_ name: String,
                      tint: Color = .secondary,
                      action: @escaping () -> Void) -> some View {
        Button(action: { bounce(); action() }) {
            Image(systemName: name)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
                .background(Circle().fill(.thinMaterial))
        }
        .buttonStyle(.plain)
    }

    // --- アニメーション ---
    private func bounce() {
        scale = 0.75
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { scale = 1 }
    }
}

// MARK: - ⑥ モデル選択ポップアップ
private struct ModelPicker: View {
    @Environment(\.dismiss) private var close
    @Binding var model: String
    let models = ["Llama-3-8B-Instruct", "DeepSeek-R1-32B", "Gemma-9B"]
    @State private var selection: String?

    var body: some View {
        NavigationStack {
            List(selection: $selection) {
                ForEach(models, id: \.self) { Text($0) }
            }
            .navigationTitle("モデルを選択")
            .onAppear { selection = model }
            .onChange(of: selection) { newValue in
                if let newValue { model = newValue }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { close() }
                }
            }
        }
    }
}

// MARK: - ⑦ Live 音声モード（モック）
private struct LiveChatView: View {
    let model: String
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.accentColor)

            Text("Live Conversation with\n\(model)")
                .multilineTextAlignment(.center)
                .font(.title3.bold())

            Spacer()

            Button("閉じる", role: .cancel) { }
                .buttonStyle(.borderedProminent)
        }
        .padding(48)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .preferredColorScheme(.light)   // ダーク確認は .dark
}

import SwiftUI

struct QuoteTimerView: View {
    let expiresAt: Int
    let onRefresh: () -> Void

    @State private var remainingSeconds: Int = 0
    @State private var timer: Timer?

    var isExpired: Bool { remainingSeconds <= 0 }

    var body: some View {
        HStack {
            if isExpired {
                Text("Quote expired")
                    .textSM(weight: .medium)
                    .foregroundColor(Color.TON.red600)
                Spacer()
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise")
                        .textSM(weight: .semibold)
                        .foregroundColor(Color.TON.blue600)
                }
            } else {
                HStack(spacing: 0) {
                    Text("Quote valid for ")
                        .textSM()
                        .foregroundColor(Color.TON.blue700)
                    Text(formattedTime)
                        .textSM(weight: .bold)
                        .foregroundColor(Color.TON.blue700)
                }
                Spacer()
            }
        }
        .padding(AppSpacing.spacing(3))
        .background(isExpired ? Color.TON.red50 : Color.TON.blue50)
        .cornerRadius(AppRadius.standard)
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: expiresAt) { _ in startTimer() }
    }

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return "\(minutes)m \(String(format: "%02d", seconds))s"
    }

    private func startTimer() {
        stopTimer()
        updateRemaining()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                updateRemaining()
                if remainingSeconds <= 0 {
                    stopTimer()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateRemaining() {
        let now = Int(Date().timeIntervalSince1970)
        remainingSeconds = max(0, expiresAt - now)
    }
}

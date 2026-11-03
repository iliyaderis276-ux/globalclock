import SwiftUI

private struct ClockLocation: Identifiable {
    let id: String
    let country: String
    let city: String
    let flag: String
    let timeZoneID: String
    let accent: Color

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneID) ?? .gmt
    }

    static let all: [ClockLocation] = [
        .init(id: "iran", country: "ایران", city: "تهران", flag: "🇮🇷",
              timeZoneID: "Asia/Tehran", accent: Color(red: 0.20, green: 0.78, blue: 0.62)),
        .init(id: "thailand", country: "تایلند", city: "بانکوک", flag: "🇹🇭",
              timeZoneID: "Asia/Bangkok", accent: Color(red: 0.98, green: 0.69, blue: 0.28)),
        .init(id: "russia", country: "روسیه", city: "مسکو", flag: "🇷🇺",
              timeZoneID: "Europe/Moscow", accent: Color(red: 0.43, green: 0.62, blue: 0.98))
    ]
}

struct ContentView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.035, green: 0.055, blue: 0.10),
                         Color(red: 0.075, green: 0.09, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                let now = timeline.date

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 26) {
                        header
                        localTimeCard(now: now)

                        HStack {
                            Text("۳ منطقه زمانی")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.48))
                            Spacer()
                            Text("ساعت شهرها")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        ForEach(ClockLocation.all) { location in
                            ClockCard(location: location, date: now)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text("زمان‌ها به‌صورت خودکار و زنده به‌روزرسانی می‌شوند")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.38))
                        .frame(maxWidth: .infinity)
                        .padding(.top, 2)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .trailing, spacing: 7) {
                Text("WORLD CLOCK")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(Color.cyan.opacity(0.9))
                    .environment(\.layoutDirection, .leftToRight)

                Text("ساعت جهانی")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(.white)

                Text("همیشه از زمان دنیا باخبر باش")
                    .font(.system(size: 13))
                    .foregroundStyle(.white.opacity(0.52))
            }

            Spacer()

            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.07))
                    .frame(width: 58, height: 58)
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 27))
                    .foregroundStyle(.cyan)
            }
        }
    }

    private func localTimeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func localTimeCard(now: Date) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                Circle().fill(Color.green).frame(width: 7, height: 7)
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.green)
                Spacer()
                Text("زمان فعلی دستگاه")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }

            Text(localTimeString(now))
            .font(.system(size: 34, weight: .light, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(now.formatted(
                Date.FormatStyle(date: .complete, time: .omitted)
                    .locale(Locale(identifier: "fa_IR"))
            ))
            .font(.system(size: 12))
            .foregroundStyle(.white.opacity(0.48))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }
}

private struct ClockCard: View {
    let location: ClockLocation
    let date: Date

    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = location.timeZone
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }

    private var dateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fa_IR")
        formatter.calendar = Calendar(identifier: .persian)
        formatter.timeZone = location.timeZone
        formatter.dateFormat = "EEEE، d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var offsetText: String {
        let seconds = location.timeZone.secondsFromGMT(for: date)
        let hours = seconds / 3600
        let minutes = abs(seconds % 3600) / 60
        return String(format: "UTC%+03d:%02d", hours, minutes)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 17) {
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(location.country)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    Text(location.city)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.48))
                }

                Spacer()

                Text(location.flag)
                    .font(.system(size: 34))
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 16))
            }

            HStack(alignment: .firstTextBaseline) {
                Text(offsetText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(location.accent)
                    .environment(\.layoutDirection, .leftToRight)

                Spacer()

                Text(timeText)
                    .font(.system(size: 38, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .leftToRight)
            }

            Rectangle()
                .fill(.white.opacity(0.07))
                .frame(height: 1)

            HStack {
                Text(dateText)
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.52))
                Spacer()
                Circle()
                    .fill(location.accent)
                    .frame(width: 6, height: 6)
                Text("زمان محلی")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 23)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.085), .white.opacity(0.035)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 23)
                .stroke(.white.opacity(0.075), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ContentView()
}

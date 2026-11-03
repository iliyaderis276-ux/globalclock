import SwiftUI

private struct ClockLocation: Identifiable, Hashable {
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
        .init(id: "iran", country: "ایران", city: "تهران", flag: "🇮🇷", timeZoneID: "Asia/Tehran", accent: Color(red: 0.20, green: 0.78, blue: 0.62)),
        .init(id: "thailand", country: "تایلند", city: "بانکوک", flag: "🇹🇭", timeZoneID: "Asia/Bangkok", accent: Color(red: 0.98, green: 0.69, blue: 0.28)),
        .init(id: "russia", country: "روسیه", city: "مسکو", flag: "🇷🇺", timeZoneID: "Europe/Moscow", accent: Color(red: 0.43, green: 0.62, blue: 0.98)),
        .init(id: "germany", country: "آلمان", city: "برلین", flag: "🇩🇪", timeZoneID: "Europe/Berlin", accent: .orange),
        .init(id: "uk", country: "بریتانیا", city: "لندن", flag: "🇬🇧", timeZoneID: "Europe/London", accent: .purple),
        .init(id: "uae", country: "امارات", city: "دبی", flag: "🇦🇪", timeZoneID: "Asia/Dubai", accent: .green),
        .init(id: "turkey", country: "ترکیه", city: "استانبول", flag: "🇹🇷", timeZoneID: "Europe/Istanbul", accent: .red),
        .init(id: "japan", country: "ژاپن", city: "توکیو", flag: "🇯🇵", timeZoneID: "Asia/Tokyo", accent: .pink),
        .init(id: "usa_ny", country: "آمریکا", city: "نیویورک", flag: "🇺🇸", timeZoneID: "America/New_York", accent: .cyan),
        .init(id: "usa_la", country: "آمریکا", city: "لس‌آنجلس", flag: "🇺🇸", timeZoneID: "America/Los_Angeles", accent: .indigo),
        .init(id: "canada", country: "کانادا", city: "تورنتو", flag: "🇨🇦", timeZoneID: "America/Toronto", accent: .red),
        .init(id: "australia", country: "استرالیا", city: "سیدنی", flag: "🇦🇺", timeZoneID: "Australia/Sydney", accent: .mint)
    ]
}

struct ContentView: View {
    @AppStorage("globalClock.savedCities") private var savedCityIDs = "iran,thailand,russia"
    @State private var isShowingCityPicker = false

    private var selectedIDs: [String] {
        savedCityIDs.split(separator: ",").map(String.init)
    }

    private var locations: [ClockLocation] {
        selectedIDs.compactMap { id in ClockLocation.all.first { $0.id == id } }
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.035, green: 0.055, blue: 0.10), Color(red: 0.075, green: 0.09, blue: 0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            TimelineView(.periodic(from: .now, by: 1)) { timeline in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .trailing, spacing: 24) {
                        header
                        localTimeCard(now: timeline.date)

                        HStack {
                            Text("\(locations.count) شهر")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.white.opacity(0.48))
                            Spacer()
                            Text("ساعت شهرها")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }

                        ForEach(locations) { location in
                            ClockCard(location: location, date: timeline.date) {
                                remove(location)
                            }
                        }

                        Button {
                            isShowingCityPicker = true
                        } label: {
                            Label("افزودن شهر جدید", systemImage: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.cyan)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(.cyan.opacity(0.09), in: RoundedRectangle(cornerRadius: 18))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(.cyan.opacity(0.25), style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                                }
                        }
                        .buttonStyle(.plain)

                        HStack(spacing: 6) {
                            Image(systemName: "globe")
                            Text("زمان شهرها به‌صورت خودکار به‌روزرسانی می‌شود")
                        }
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.38))
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 24)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingCityPicker) {
            CityPickerView(selectedIDs: Set(selectedIDs)) { location in
                add(location)
            }
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .trailing, spacing: 7) {
                Text("WORLD CLOCK")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(3)
                    .foregroundStyle(.cyan.opacity(0.9))
                    .environment(\.layoutDirection, .leftToRight)
                Text("ساعت جهانی")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(.white)
                Text("زمان دنیا، همیشه همراه تو")
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

    private func localTimeCard(now: Date) -> some View {
        VStack(alignment: .trailing, spacing: 9) {
            HStack {
                Circle().fill(.green).frame(width: 7, height: 7)
                Text("LIVE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(.green)
                Spacer()
                Text("زمان فعلی دستگاه")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
            Text(Self.timeString(now, timeZone: .current, seconds: false))
                .font(.system(size: 36, weight: .light, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(Self.dateString(now, timeZone: .current))
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.48))
                    .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(.white.opacity(0.055), in: RoundedRectangle(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22).stroke(.white.opacity(0.08), lineWidth: 1)
        }
    }

    private func add(_ location: ClockLocation) {
        var ids = selectedIDs
        guard !ids.contains(location.id) else { return }
        ids.append(location.id)
        savedCityIDs = ids.joined(separator: ",")
    }

    private func remove(_ location: ClockLocation) {
        savedCityIDs = selectedIDs.filter { $0 != location.id }.joined(separator: ",")
    }

    fileprivate static func timeString(_ date: Date, timeZone: TimeZone, seconds: Bool = true) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_GB")
        formatter.timeZone = timeZone
        formatter.dateFormat = seconds ? "HH:mm:ss" : "HH:mm"
        return formatter.string(from: date)
    }

    fileprivate static func dateString(_ date: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "fa_IR")
        formatter.calendar = Calendar(identifier: .persian)
        formatter.timeZone = timeZone
        formatter.dateFormat = "EEEE، d MMMM yyyy"
        return formatter.string(from: date)
    }
}

private struct ClockCard: View {
    let location: ClockLocation
    let date: Date
    let onRemove: () -> Void

    private var offsetText: String {
        let totalSeconds = location.timeZone.secondsFromGMT(for: date)
        let absoluteSeconds = abs(totalSeconds)
        let sign = totalSeconds < 0 ? "-" : "+"
        return String(format: "UTC%@%02d:%02d", sign, absoluteSeconds / 3600, (absoluteSeconds % 3600) / 60)
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 15) {
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
                Button(action: onRemove) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                        .frame(width: 32, height: 32)
                        .background(.white.opacity(0.06), in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("حذف شهر")
            }

            HStack(alignment: .firstTextBaseline) {
                Text(offsetText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundStyle(location.accent)
                    .environment(\.layoutDirection, .leftToRight)
                Spacer()
                Text(ContentView.timeString(date, timeZone: location.timeZone))
                    .font(.system(size: 37, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .environment(\.layoutDirection, .leftToRight)
            }

            Rectangle().fill(.white.opacity(0.07)).frame(height: 1)

            HStack {
                Text(ContentView.dateString(date, timeZone: location.timeZone))
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.52))
                Spacer()
                Circle().fill(location.accent).frame(width: 6, height: 6)
                Text("زمان محلی")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
        .padding(18)
        .background {
            RoundedRectangle(cornerRadius: 23)
                .fill(LinearGradient(colors: [.white.opacity(0.085), .white.opacity(0.035)], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 23).stroke(.white.opacity(0.075), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
    }
}

private struct CityPickerView: View {
    let selectedIDs: Set<String>
    let onSelect: (ClockLocation) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var availableCities: [ClockLocation] {
        ClockLocation.all.filter { !selectedIDs.contains($0.id) }
    }

    private var filteredCities: [ClockLocation] {
        guard !searchText.isEmpty else { return availableCities }
        return availableCities.filter {
            $0.city.localizedCaseInsensitiveContains(searchText) ||
            $0.country.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredCities) { location in
                Button {
                    onSelect(location)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(location.flag).font(.system(size: 28))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.city).font(.system(size: 16, weight: .semibold))
                            Text(location.country).font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "plus.circle.fill").foregroundStyle(.cyan)
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.white.opacity(0.045))
            }
            .scrollContentBackground(.hidden)
            .background(Color(red: 0.055, green: 0.07, blue: 0.12))
            .searchable(text: $searchText, prompt: "جستجوی شهر یا کشور")
            .navigationTitle("افزودن شهر")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("بستن") { dismiss() }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    ContentView()
}

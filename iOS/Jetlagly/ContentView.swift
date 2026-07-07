import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.tripName).font(Theme.headlineFont)
                            Text(entry.timezoneShift).font(Theme.bodyFont).foregroundColor(.secondary)
                            HStack {
                                Text("\(entry.sleepHours, specifier: \"%.1f\") hrs")
                                Spacer()
                                Text("\(entry.energyLevel, specifier: \"%.1f\")")
                            }
                            .font(.caption)
                            .foregroundColor(Theme.accent)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(Theme.card)
                        .contentShape(Rectangle())
                        .onTapGesture { editingEntry = entry }
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Jetlagly")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if store.canAddMore || purchases.isPro {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct EntryFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var tripName: String
    @State private var timezoneShift: String
    @State private var sleepHoursText: String
    @State private var energyLevelText: String
    @State private var notes: String
    @FocusState private var focusedField: Field?
    private let originalID: UUID
    private let onSave: (Entry) -> Void

    enum Field { case f1, f2, n1, n2, notes }

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        _tripName = State(initialValue: entry?.tripName ?? "")
        _timezoneShift = State(initialValue: entry?.timezoneShift ?? "")
        _sleepHoursText = State(initialValue: entry != nil ? String(entry!.sleepHours) : "")
        _energyLevelText = State(initialValue: entry != nil ? String(entry!.energyLevel) : "")
        _notes = State(initialValue: entry?.notes ?? "")
        originalID = entry?.id ?? UUID()
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("tripName") {
                    TextField("tripName", text: $tripName)
                        .focused($focusedField, equals: .f1)
                        .accessibilityIdentifier("field_tripName")
                }
                Section("timezoneShift") {
                    TextField("timezoneShift", text: $timezoneShift)
                        .focused($focusedField, equals: .f2)
                        .accessibilityIdentifier("field_timezoneShift")
                }
                Section("Details") {
                    TextField("sleepHours", text: $sleepHoursText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n1)
                        .accessibilityIdentifier("field_sleepHours")
                    TextField("energyLevel", text: $energyLevelText)
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .n2)
                        .accessibilityIdentifier("field_energyLevel")
                    TextField("Notes", text: $notes)
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("field_notes")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                focusedField = nil
            }
            .navigationTitle(originalID == UUID() ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("formCancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let entry = Entry(
                            id: originalID,
                            tripName: tripName,
                            timezoneShift: timezoneShift,
                            sleepHours: Double(sleepHoursText) ?? 0,
                            energyLevel: Double(energyLevelText) ?? 0,
                            notes: notes
                        )
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("formSaveButton")
                    .disabled(tripName.isEmpty)
                }
            }
        }
    }
}

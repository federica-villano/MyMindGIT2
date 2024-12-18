//
//  ContentView.swift
//  CopiaMyMind
//
//  Created by Federica Villano on 17/12/24.
//


import SwiftUI
import AVFoundation

struct Note: Identifiable, Codable {
    var id = UUID()  // Identificatore unico
    var title: String  // Titolo della nota
    var text: String   // Testo della nota
    var timestamp: Date  // Data e ora di creazione
    var audioURL: URL?  // URL del file audio
}

struct ContentView: View {
    @State private var searchText: String = ""
    @State private var showModal: Bool = false
    @State private var notes: [Note] = []
    @State private var showProfile: Bool = false
    
    @State private var isRecording: Bool = false
    @State private var audioRecorder: AVAudioRecorder?
    @State private var recordedAudioURL: URL?
    @State private var audioPlayer: AVAudioPlayer?
    
    // Variabili per titolo e descrizione
    @State private var newTitle: String = ""
    @State private var newText: String = ""
    @State private var showAddNoteModal: Bool = false  // Variabile per aprire la modale
    @State private var selectedNote: Note?  // Note selezionata per modifica
    
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return notes
        } else {
            return notes.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .accessibilityLabel("Search bar")  // Etichetta di accessibilità per la barra di ricerca
                
                // List of notes
                List {
                    ForEach(filteredNotes) { note in
                        VStack(alignment: .leading) {
                            Text(note.title)
                                .font(.headline)
                                .accessibilityLabel(note.title)  // Etichetta per il titolo della nota
                            
                            // Icon to play audio if audioURL is available
                            if let audioURL = note.audioURL {
                                HStack {
                                    Text("Audio available")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                        .onTapGesture {
                                            // Play audio when tapped
                                            playAudio(url: audioURL)
                                        }
                                        .accessibilityLabel("Audio available")  // Etichetta per il testo "Audio available"
                                         .accessibilityHint("Tap to play audio")  // Suggerimento per l'azione
                                                                            
                                    Image(systemName: "speaker.3.fill")
                                        .foregroundColor(.blue)
                                        .padding(.leading, 5)
                                        .accessibilityLabel("Play audio")  // Etichetta per l'icona dell'altoparlante
                                }
                            }
                            
                            Text(note.text)
                                .font(.body)
                                .lineLimit(2)
                                .accessibilityLabel(note.text)  // Etichetta per il testo della nota
                                                            
                            Text("Saved on: \(note.timestamp, formatter: dateFormatter)")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .accessibilityLabel("Saved on \(note.timestamp, formatter: dateFormatter)")  // Etichetta per la data
                        }
                        .onTapGesture {
                            // Open the selected note for editing
                            selectedNote = note
                            newTitle = note.title
                            newText = note.text
                            showAddNoteModal = true
                        }
                        .accessibilityElement(children: .combine)  // Combina i figli in un solo elemento accessibile
                    }
                    .onDelete(perform: deleteNote)
                }
                
                Spacer()
                
                HStack {
                    // Floating button to add notes
                    Button(action: {
                        showModal = true
                    }) {
                        Image(systemName: "plus")
                            .font(.largeTitle)
                            .frame(width: 60, height: 60)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding()
                    .accessibilityLabel("Add a new note")  // Etichetta per il pulsante di aggiunta
                    .accessibilityHint("Tap to create a new note")  // Suggerimento per l'azione
                    .sheet(isPresented: $showModal) {
                        AddNoteView(notes: $notes)
                    }
                    
                    // Button to start/stop audio recording
                    Button(action: {
                        if isRecording {
                            stopRecording()   // Stop recording and show modale
                        } else {
                            startRecording()
                        }
                    }) {
                        Image(systemName: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.largeTitle)
                            .frame(width: 60, height: 60) // Same size as the plus button
                            .foregroundColor(isRecording ? .red : .black)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    }
                    .padding()
                    .accessibilityLabel(isRecording ? "Stop recording" : "Start recording")  // Etichetta per il pulsante di registrazione
                    .accessibilityHint(isRecording ? "Tap to stop recording" : "Tap to start recording")  // Suggerimento per l'azione
                }
                .padding(.bottom)
            }
            .navigationTitle("Memories")
            .navigationBarItems(trailing: Button(action: {
                showProfile = true
            }) {
                Image(systemName: "person.crop.circle")
                    .font(.title)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
            })
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
            // Modale per aggiungere titolo e descrizione
            .sheet(isPresented: $showAddNoteModal) {
                VStack {
                    TextField("Enter Title", text: $newTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .accessibilityLabel("Enter note title")  // Etichetta per il campo del titolo
                    
                    TextField("Enter Description", text: $newText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .accessibilityLabel("Enter note description")  // Etichetta per il campo della descrizione
                    
                    Button("Save Note") {
//                        addNewNote()  // Funzione che aggiunge la nuova nota e salva le note
                        if let selectedNote = selectedNote {
                            updateNote(selectedNote)  // Funzione che aggiorna la nota selezionata
                        } else {
                            addNewNote()  // Funzione che aggiunge una nuova nota
                        }
                    }
                    .padding()
                    .accessibilityLabel("Save note")  // Etichetta per il pulsante "Save"
                    .accessibilityHint("Tap to save the note")  // Suggerimento per l'azione
                }
                .padding()
            }
        }
        .onAppear {
            loadNotes()  // Carica le note quando la view appare
        }
    }
    
//    // Funzione per aggiungere una nuova nota e salvarla
//        func addNewNote() {
//            if !newTitle.isEmpty && !newText.isEmpty, let audioURL = recordedAudioURL {
//                let newNote = Note(title: newTitle, text: newText, timestamp: Date(), audioURL: audioURL)
//                notes.append(newNote)
//                saveNotes()  // Salva le note dopo aver aggiunto una nuova
//            }
//            showAddNoteModal = false
//        }
    
    // Funzione per aggiungere una nuova nota e salvarla
    func addNewNote() {
        if let audioURL = recordedAudioURL {
            // Se non ci sono un titolo o un testo, aggiungiamo comunque la registrazione audio
            let newNote = Note(title: newTitle.isEmpty ? "Untitled" : newTitle,
                               text: newText.isEmpty ? "No description" : newText,
                               timestamp: Date(),
                               audioURL: audioURL)
            notes.append(newNote)
            saveNotes()  // Salva le note dopo aver aggiunto una nuova
        }
        showAddNoteModal = false
    }
    
    // Funzione per aggiornare una nota esistente
        func updateNote(_ note: Note) {
            if let index = notes.firstIndex(where: { $0.id == note.id }) {
                // Aggiorna la nota con il nuovo titolo e testo
                notes[index].title = newTitle
                notes[index].text = newText
                if let audioURL = recordedAudioURL {
                    notes[index].audioURL = audioURL
                }
                saveNotes()  // Salva le note dopo l'aggiornamento
            }
            showAddNoteModal = false
        }
    
    // Funzione per cancellare una nota
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes() // Salva le note dopo la cancellazione
    }
    
    // Funzione per salvare le note in UserDefaults
        func saveNotes() {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(notes) {
                UserDefaults.standard.set(encoded, forKey: "notes")
            }
        }
        
        // Funzione per caricare le note da UserDefaults
        func loadNotes() {
            if let savedNotes = UserDefaults.standard.data(forKey: "notes") {
                let decoder = JSONDecoder()
                if let decodedNotes = try? decoder.decode([Note].self, from: savedNotes) {
                    notes = decodedNotes
                }
            }
        }
    
//    // Funzione per avviare la registrazione
//    func startRecording() {
//        let audioSession = AVAudioSession.sharedInstance()
//        try? audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
//        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
//
//        let recordingURL = getAudioFileURL()
//        let settings: [String: Any] = [
//            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//            AVSampleRateKey: 12000,
//            AVNumberOfChannelsKey: 1,
//            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//        ]
//
//        do {
//            audioRecorder = try AVAudioRecorder(url: recordingURL, settings: settings)
//            audioRecorder?.record()
//            isRecording = true
//        } catch {
//            print("Failed to start recording: \(error)")
//        }
//    }
    
    // Funzione per avviare la registrazione
//        func startRecording() {
//            let audioSession = AVAudioSession.sharedInstance()
//            try? audioSession.setCategory(.record, mode: .default)
//            try? audioSession.setActive(true)
//
//            let settings: [String: Any] = [
//                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//                AVSampleRateKey: 12000,
//                AVNumberOfChannelsKey: 1,
//                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
//            ]
//
//            let fileName = UUID().uuidString + ".m4a"
//            let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
//
//            try? audioRecorder = AVAudioRecorder(url: url, settings: settings)
//            audioRecorder?.record()
//
//            isRecording = true
//        }
    func startRecording() {
            let audioSession = AVAudioSession.sharedInstance()
            
            do {
                // Configura la sessione audio
                try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                
                // Controlla se il microfono è disponibile
                if !audioSession.isInputAvailable {
                    print("Microphone not available")
                    return
                }
                
                let settings: [String: Any] = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 12000,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                ]
                
                let fileName = UUID().uuidString + ".m4a"
                let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
                
                audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                audioRecorder?.record()
                
                isRecording = true
                recordedAudioURL = url
                
            } catch {
                print("Error starting recording: \(error.localizedDescription)")
            }
        }
    
    
    // Funzione per fermare la registrazione
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        recordedAudioURL = audioRecorder?.url
        
        // Una volta che la registrazione è stata fermata, apriamo la modale per aggiungere il titolo e la descrizione
        // Se il titolo e la descrizione sono vuoti, la registrazione verrà comunque salvata
        showAddNoteModal = true
    }
    
    // Funzione per aggiungere una nota audio senza titolo o descrizione
    func saveAudioOnly() {
        if let audioURL = recordedAudioURL {
            let newNote = Note(title: "Untitled", text: "No description", timestamp: Date(), audioURL: audioURL)
            notes.append(newNote)
            saveNotes()  // Salva le note dopo aver aggiunto la registrazione
        }
        showAddNoteModal = false
    }
    
    // Funzione per ottenere l'URL del file audio
    func getAudioFileURL() -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "note_\(UUID().uuidString).m4a"
        return tempDirectory.appendingPathComponent(fileName)
    }
    
    // Funzione per riprodurre l'audio
    func playAudio(url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
        }
    }
}


struct AddNoteView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var notes: [Note]
    @State private var newTitle: String = ""
    @State private var newText: String = ""
    var audioURL: URL?
    
    var body: some View {
        NavigationView {
            VStack {
                // Title
                TextField("Title", text: $newTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // Text
                TextField("Write your note here...", text: $newText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Add Note")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                if !newTitle.isEmpty && !newText.isEmpty {
                    let newNote = Note(title: newTitle, text: newText, timestamp: Date())
                    notes.append(newNote)
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// Date formatter per visualizzare la data e ora
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()


struct ProfileView: View {
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var contacts: String = ""
    @State private var medications: String = ""
    @State private var allergies: String = ""
    @State private var conditions: String = ""
    
    // Method to load saved profile data
    func loadProfile() {
        let defaults = UserDefaults.standard
        name = defaults.string(forKey: "name") ?? ""
        email = defaults.string(forKey: "email") ?? ""
        phone = defaults.string(forKey: "phone") ?? ""
        address = defaults.string(forKey: "address") ?? ""
        contacts = defaults.string(forKey: "emergency contacts") ?? ""
        medications = defaults.string(forKey: "medications") ?? ""
        allergies = defaults.string(forKey: "allergies") ?? ""
        conditions = defaults.string(forKey: "conditions") ?? ""
    }
    
    // Method to save profile data
    func saveProfile() {
        let defaults = UserDefaults.standard
        defaults.set(name, forKey: "name")
        defaults.set(email, forKey: "email")
        defaults.set(phone, forKey: "phone")
        defaults.set(address, forKey: "address")
        defaults.set(contacts, forKey: "emergency contacts")
        defaults.set(medications, forKey: "medications")
        defaults.set(allergies, forKey: "allergies")
        defaults.set(conditions, forKey: "conditions")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Details")) {
                    TextField("Name and Surname", text: $name)
                    TextField("E-mail", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Address", text: $address)
                }
                
                Section(header: Text("Medical ID")) {
                    TextField("Medications", text: $medications)
                    TextField("Allergies", text: $allergies)
                    TextField("Conditions", text: $conditions)
                    TextField("Emergency contacts", text: $contacts)
                }
            }
            .navigationTitle("My Story")
            .onAppear {
                loadProfile()  // Load saved data when the view appears
            }
            .navigationBarItems(trailing: Button("Save") {
                saveProfile()  // Save data when "Save" button is tapped
            })
        }
    }
}



#Preview {
    ContentView()
}

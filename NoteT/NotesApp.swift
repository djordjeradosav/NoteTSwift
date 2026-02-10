import SwiftUI
import Combine

// MARK: - Models
struct Note: Identifiable, Codable {
    var id = UUID()
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
}

// MARK: - View Model
class NotesViewModel: ObservableObject {
    @Published var notes: [Note] = []
    
    private let notesKey = "savedNotes"
    
    init() {
        loadNotes()
    }
    
    func addNote(title: String, content: String) {
        let note = Note(
            title: title,
            content: content,
            createdAt: Date(),
            modifiedAt: Date()
        )
        notes.insert(note, at: 0)
        saveNotes()
    }
    
    func updateNote(_ note: Note, title: String, content: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].title = title
            notes[index].content = content
            notes[index].modifiedAt = Date()
            saveNotes()
        }
    }
    
    func deleteNote(at offsets: IndexSet) {
        notes.remove(atOffsets: offsets)
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadNotes() {
        if let savedNotes = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: savedNotes) {
            notes = decoded
        }
    }
}

// MARK: - Content View (Notes List)
struct ContentView: View {
    @StateObject private var viewModel = NotesViewModel()
    @State private var showingAddNote = false
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.notes.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Notes Yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Tap + to create your first note")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    List {
                        ForEach(viewModel.notes) { note in
                            NavigationLink(destination: NoteDetailView(note: note, viewModel: viewModel)) {
                                NoteRowView(note: note)
                            }
                        }
                        .onDelete(perform: viewModel.deleteNote)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddNote = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                
                if !viewModel.notes.isEmpty {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView(viewModel: viewModel, isPresented: $showingAddNote)
            }
        }
    }
}

// MARK: - Note Row View
struct NoteRowView: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(note.title.isEmpty ? "Untitled" : note.title)
                .font(.headline)
                .foregroundColor(note.title.isEmpty ? .gray : .primary)
            
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Text(note.modifiedAt, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Note View
struct AddNoteView: View {
    @ObservedObject var viewModel: NotesViewModel
    @Binding var isPresented: Bool
    
    @State private var title = ""
    @State private var content = ""
    @FocusState private var titleFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Title", text: $title)
                    .font(.title2.bold())
                    .padding()
                    .focused($titleFocused)
                
                Divider()
                
                TextEditor(text: $content)
                    .font(.body)
                    .padding()
                    .frame(maxHeight: .infinity)
            }
            .navigationTitle("New Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.addNote(title: title, content: content)
                        isPresented = false
                    }
                    .disabled(title.isEmpty && content.isEmpty)
                }
            }
            .onAppear {
                titleFocused = true
            }
        }
    }
}

// MARK: - Note Detail View
struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NotesViewModel
    
    @State private var title: String
    @State private var content: String
    @State private var isEditing = false
    
    init(note: Note, viewModel: NotesViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                TextField("Title", text: $title)
                    .font(.title2.bold())
                    .padding()
                
                Divider()
                
                TextEditor(text: $content)
                    .font(.body)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(title.isEmpty ? "Untitled" : title)
                            .font(.title.bold())
                        
                        HStack {
                            Text("Modified")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(note.modifiedAt, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(note.modifiedAt, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        Text(content)
                            .font(.body)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        viewModel.updateNote(note, title: title, content: content)
                    }
                    isEditing.toggle()
                }
            }
        }
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

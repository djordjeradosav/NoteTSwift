# NoteT: SwiftUI Notes App

A clean, native iOS notes app built with **SwiftUI** and the **MVVM** pattern.

**Swift · SwiftUI · Combine · Codable · Xcode**

## Features

- Create, edit and delete notes (swipe to delete)
- Notes persist between launches (`Codable` + `UserDefaults`)
- Newest notes first, with relative "last modified" timestamps
- Detail view with created/modified dates
- Empty state for first-time users

## Architecture

| Layer | Type | Responsibility |
|---|---|---|
| Model | `Note` (`Identifiable`, `Codable`) | id, title, content, timestamps |
| ViewModel | `NotesViewModel` (`ObservableObject`) | CRUD operations, JSON encoding and persistence |
| Views | `ContentView`, `NoteRowView`, `AddNoteView`, `NoteDetailView` | List, row, create sheet, detail/edit screen |

## Run

1. Open `NoteT.xcodeproj` in Xcode
2. Select an iPhone simulator
3. Press **⌘R**

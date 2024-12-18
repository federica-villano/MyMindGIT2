# MyMind
MyMind App 🧠
MyMind is an iOS app that allows users to create, edit, and record audio notes, with the ability to add descriptions and titles to the saved notes.

![Image 18-12-24 at 18 01](https://github.com/user-attachments/assets/a3e0c1dd-462d-41ab-bd2c-4db1b20a917a)
![Image 18-12-24 at 18 03](https://github.com/user-attachments/assets/d3c53cd2-37ba-4c6d-93ff-f41efaa73822)
![Image 18-12-24 at 18 02](https://github.com/user-attachments/assets/3550b01a-0c44-4993-8ab8-af986cad0b8a)

Features ✨
* Note management: add, edit, and delete notes.
* Search notes by title.
* Audio recording with the option to stop and save recordings.
* User profile: add and save personal and medical information.

Installation 📱
1. Clone this repository: `git clone <https://github.com/federica-villano/MyMindGIT2.git`>
2. Open the project in Xcode:
    * Go to Xcode and open the project using the .xcodeproj file.
3. Build and run the app on a simulator or a physical device.
4. Make sure to grant microphone permissions when prompted to record audio.

Code 👾
* Audio Recording: Uses AVAudioRecorder to record audio in .m4a format. You can start, stop, and save the audio recording as part of the note.
* Persistence of Notes: Notes are saved and loaded from UserDefaults to retain data between sessions.

Key Functions in the Code 🎯
* addNewNote(): Adds a new note with audio.
* updateNote(): Allows for updating an existing note.
* startRecording(): Starts the audio recording.
* stopRecording(): Stops the audio recording and opens a modal to add a title and description.

License 🔑
This project is licensed under the MIT License. See the LICENSE file for details.

Notes 📒
* Microphone access is required to record audio, and permission is requested when starting the recording.
* The app is designed with accessibility in mind, providing accessibility labels for key UI elements like the search bar, buttons, and notes.

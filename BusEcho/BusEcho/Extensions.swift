import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

struct StarPicker: View {
    @Binding var rating: Int
    var filledColor: Color = Color(hex: "#FFD700")
    var emptyColor: Color = Color(hex: "8DD0F0")
    var size: CGFloat = 24

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(index <= rating ? filledColor : emptyColor)
                    .onTapGesture {
                        rating = index
                    }
            }
        }
    }
}

struct StarRatingView: View {
    var rating: Double
    var maxRating: Int = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= Int(rating.rounded(.down)) ? "star.fill" :
                      (Double(index) - rating <= 0.5 ? "star.leadinghalf.filled" : "star"))
                    .foregroundColor(.yellow)
            }
        }
    }
}

struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    var placeholder: String
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.6))
                    .padding(8)
            }
            TextEditor(text: $text)
                .padding(4)
                .background(Color.clear)
        }
        .frame(minHeight: 100)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}


struct CustomPicker: View {
    var title: String
    @Binding var text: String
    var icon: String

    var body: some View {
        HStack {
            TextField(title, text: $text)
                .padding(.vertical, 10)
            Spacer()
            Image(systemName: icon)
                .foregroundColor(Color(hex: "8DD0F0"))
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct CustomTextField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

struct CustomPasswordField: View {
    var title: String
    @Binding var text: String

    var body: some View {
        SecureField(title, text: $text)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
    }
}

//Mark: - Time Selection

struct TimeSelectionField: View {
    var label: String
    @Binding var time: Date // ✅ Changed from `Date?` to `Date`
    @State private var internalTime: Date
    @State private var showPicker = false
    @State private var isTimeSelected = false

    init(label: String, time: Binding<Date>) {
        self.label = label
        self._time = time
        self._internalTime = State(initialValue: time.wrappedValue)
    }

    var body: some View {
        VStack(spacing: 6) {
            HStack{
                Text(label)
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        showPicker.toggle()
                    }
                }) {
                    HStack {
                        Text(isTimeSelected ? formattedTime : "Select time")
                            .foregroundColor(isTimeSelected ? .primary : .gray)
                        Spacer()
                        Image(systemName: "clock")
                            .foregroundColor(Color(hex: "8DD0F0"))
                    }
                    .frame(maxWidth: 160)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }

            if showPicker {
                VStack(spacing: 0) {
                    DatePicker(
                        "",
                        selection: $internalTime,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.wheel)
                    .transition(.opacity)

                    Button(action: {
                        time = internalTime
                        isTimeSelected = true
                        withAnimation {
                            showPicker = false
                        }
                    }) {
                        Text("Done")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "8DD0F0"))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 5)
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.top, 5)
            }
        }
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: internalTime)
    }
}



import SwiftUI

struct DatePickerWithPlaceholder: View {
    @Binding var selectedDate: Date
    var defaultDate: Date = Date()

    @State private var showPicker = false
    @State private var internalDate: Date = Date()
    @State private var isDateSelected = false

    var body: some View {
        VStack() {
            HStack{
                Text("Journey Date")
                    .font(.headline)
                Spacer()
                Button(action: {
                    withAnimation {
                        internalDate = selectedDate
                        showPicker.toggle()
                    }
                }) {
                    Text(isDateSelected ? formattedDate(selectedDate) : "Select Date")
                        .foregroundColor(isDateSelected ? .primary : .gray)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(Color(hex: "8DD0F0"))
                }
                .frame(maxWidth: 160)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
                if showPicker {
                    VStack {
                        DatePicker(
                            "",
                            selection: $internalDate,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .datePickerStyle(.graphical) // ⬅️ This enables calendar view
                        
                        Button(action:{selectedDate = internalDate
                            isDateSelected = true
                            showPicker = false}) {
                                Text("Done")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "8DD0F0"))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                    .padding(.top, 5)
                            }
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}




//Mark: Location
struct LocationSearchField: View {
    @ObservedObject var viewModel: PlaceSearchViewModel
    var title: String
    @Binding var searchText: String
    @Binding var selectedPlace: Place?
    var icon: String
    var body: some View {
        VStack() {
            CustomPicker(title: title, text: $searchText,icon: icon)
                .onChange(of: searchText) {
                    viewModel.filterPlaces(query: searchText)
                }
            if !searchText.isEmpty && !viewModel.searchResults.isEmpty {
                if viewModel.searchResults.isEmpty {
                    Text("No matches found")
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                } else {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(Array(viewModel.searchResults.prefix(10)), id: \.self) { place in
                                Button(action: {
                                    selectedPlace = place
                                    searchText = place.name
                                    viewModel.searchResults = []
                                }) {
                                    HStack {
                                        Text(place.name)
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.vertical, 4)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .padding(.top, 4)
                }
            }
        }
    }
}


struct OptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body)
                .foregroundColor(isSelected ? .white : .blue)
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background(isSelected ? Color.blue : Color(hex:"8DD0F0").opacity(0.5))
                .cornerRadius(12)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

import SwiftUI
import PhotosUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}


import SwiftUI
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // 0 = unlimited selection

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker

        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                self.parent.selectedImages.append(image)
                            }
                        }
                    }
                }
            }
        }
    }
}

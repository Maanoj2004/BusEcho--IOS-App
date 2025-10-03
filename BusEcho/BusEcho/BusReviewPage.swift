import SwiftUI
import UniformTypeIdentifiers

struct PostView: View {
    @EnvironmentObject var appState: AppState
    @StateObject var boardingVM = PlaceSearchViewModel()
    @StateObject var droppingVM = PlaceSearchViewModel()
    @StateObject private var operatorVM = BusOperatorViewModel()
    
    @State private var busOperator = ""
    @State private var addNewBus: Bool = false
    @State private var boardingPoint = ""
    @State private var selectedBoarding: Place? = nil
    @State private var droppingPoint = ""
    @State private var selectedDropping: Place? = nil
    @State private var journeyDate: Date = Date()
    @State private var selectedBusType: String = ""
    @State private var selectedACType: String = ""
    @State private var busNumber = ""
    @State private var busTicket = ""
    @State private var punctualityRating: Int = 0
    @State private var cleanlinessRating: Int = 0
    @State private var comfortRating: Int = 0
    @State private var staffBehaviorRating: Int = 0
    @State private var reviewText = ""
    @State private var selectedTicketURL: URL? = nil
    @State private var showTicketPicker = false
    @State private var selectedUIImages: [UIImage] = []
    @State private var showImagePicker = false
    @State private var confirmJourney = false
    
    @State private var isNewBusAdded = false
    @State private var showReviewConfirmation = false
    @State private var confirmationMessage = ""

    var body: some View {
        NavigationStack {
            VStack{
                VStack {
                    Text("Post a Review")
                        .font(.largeTitle.bold())
                        .foregroundColor(Color.white)
                        .padding(.top, 10)
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [Color.indigo, Color.cyan],
                                   startPoint: .top,
                                   endPoint: .bottom)
                    .ignoresSafeArea(edges: .top)
                )
                
                ScrollView {
                    VStack(spacing: 20) {
                        // MARK: - Operator Section
                        CardSection {
                            VStack(alignment: .leading, spacing: 12) {
                                BusOperatorPicker(busOperator: $busOperator, viewModel: operatorVM)
                                
                                HStack {
                                    Text("Can't find operator?")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Button("➕ Add New Bus") {
                                        addNewBus = true
                                    }
                                    .font(.caption.bold())
                                    .foregroundColor(Color(hex:"2A3B7F"))
                                    .sheet(isPresented: $addNewBus) {
                                        AddBusView()
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Locations & Date
                        CardSection {
                            VStack(spacing: 16) {
                                LocationSearchField(viewModel: boardingVM, title:"Boarding Point", searchText: $boardingPoint, selectedPlace: $selectedBoarding, icon:"map.fill")
                                
                                LocationSearchField(viewModel: droppingVM, title:"Dropping Point", searchText: $droppingPoint, selectedPlace: $selectedDropping, icon:"mappin.and.ellipse")
                                
                                if boardingPoint == droppingPoint && !boardingPoint.isEmpty {
                                    Text("⚠️ Boarding and Dropping locations can't be the same.")
                                        .foregroundColor(.red)
                                        .font(.footnote)
                                        .padding(.top, 4)
                                }
                                
                                DatePickerWithPlaceholder(selectedDate: $journeyDate)
                            }
                        }
                        
                        // MARK: - Bus Type & AC Type
                        CardSection {
                            VStack(spacing: 16) {
                                HStack {
                                    Text("Bus Type")
                                        .font(.headline)
                                    Spacer()
                                    HStack(spacing: 12) {
                                        OptionButton(title: "Sleeper", isSelected: selectedBusType == "Sleeper") {
                                            selectedBusType = "Sleeper"
                                        }
                                        OptionButton(title: "Seater", isSelected: selectedBusType == "Seater") {
                                            selectedBusType = "Seater"
                                        }
                                    }
                                }
                                
                                HStack {
                                    Text("AC Type")
                                        .font(.headline)
                                    Spacer()
                                    HStack(spacing: 12) {
                                        OptionButton(title: "AC", isSelected: selectedACType == "AC") {
                                            selectedACType = "AC"
                                        }
                                        OptionButton(title: "Non-AC", isSelected: selectedACType == "Non AC") {
                                            selectedACType = "Non AC"
                                        }
                                    }
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text("Bus Number")
                                            .font(.headline)
                                            .frame(width: 120, alignment: .leading) // fixed width for alignment
                                        
                                        CustomTextField(title: "Bus Number", text: $busNumber)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.vertical, 4)
                                
                            }
                        }
                        
                        // MARK: - Ratings
                        CardSection {
                            HStack {
                                VStack(alignment: .leading, spacing: 20) {
                                    Text("Punctuality")
                                    Text("Cleanliness")
                                    Text("Comfort")
                                    Text("Staff Behaviour")
                                }
                                .font(.headline)
                                
                                Spacer()
                                
                                VStack(spacing: 20) {
                                    StarPicker(rating: $punctualityRating)
                                    StarPicker(rating: $cleanlinessRating)
                                    StarPicker(rating: $comfortRating)
                                    StarPicker(rating: $staffBehaviorRating)
                                }
                            }
                        }
                        
                        // MARK: - Review Text (No white card)
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("✍️ Write your review here...", text: $reviewText, axis: .vertical)
                                .padding()
                                .frame(minHeight: 100, alignment: .topLeading)
                                .background(Color.gray.opacity(0.1)) // subtle fill only
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                        }
                        CardSection{
                            VStack(spacing: 20) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Upload Bus Ticket (PDF)")
                                        .font(.headline)
                                    
                                    Button(action: {
                                        showTicketPicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "doc.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                            
                                            Text(selectedTicketURL == nil ? "Select PDF" : selectedTicketURL!.lastPathComponent)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .truncationMode(.middle)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .background(
                                            LinearGradient(colors: [Color(hex:"2A3B7F"), .cyan],
                                                           startPoint: .leading,
                                                           endPoint: .trailing)
                                        )
                                        .cornerRadius(12)
                                    }
                                    .fileImporter(
                                        isPresented: $showTicketPicker,
                                        allowedContentTypes: [UTType.pdf],
                                        allowsMultipleSelection: false
                                    ) { result in
                                        switch result {
                                        case .success(let urls):
                                            if let url = urls.first {
                                                selectedTicketURL = url
                                                busTicket = url.lastPathComponent
                                            }
                                        case .failure(let error):
                                            print("📄 PDF selection failed: \(error.localizedDescription)")
                                        }
                                    }
                                    
                                    if let ticket = selectedTicketURL {
                                        Text("Selected: \(ticket.lastPathComponent)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                    }
                                }
                            }
                        }
                        
                        // MARK: - Upload Images (No white card)
                        VStack(spacing: 10) {
                            Button(action: { showImagePicker.toggle() }) {
                                Label("Upload Images", systemImage: "photo.on.rectangle.angled")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(colors: [Color(hex:"2A3B7F"), .cyan],
                                                       startPoint: .leading,
                                                       endPoint: .trailing)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 4)
                            }
                            .sheet(isPresented: $showImagePicker) {
                                MultiImagePicker(selectedImages: $selectedUIImages)
                            }
                            
                            if !selectedUIImages.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(Array(selectedUIImages.enumerated()), id: \.offset) { index, image in
                                            ZStack(alignment: .topTrailing) {
                                                Image(uiImage: image)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    .shadow(radius: 2)
                                                
                                                Button {
                                                    selectedUIImages.remove(at: index)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.white)
                                                        .background(Color.black.opacity(0.6))
                                                        .clipShape(Circle())
                                                }
                                                .offset(x: -8, y: 8)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }.padding(.horizontal,20)
                        
                        
                        // MARK: - Confirmation
                        HStack {
                            Button(action: { confirmJourney.toggle() }) {
                                Image(systemName: confirmJourney ? "checkmark.square.fill" : "square")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(confirmJourney ? Color(hex:"2A3B7F") : .gray)
                            }
                            
                            Text("I confirm that I personally took this journey")
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Submit Button
                        Button(action: { submitReview() }) {
                            Text("Submit Review")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(colors: [Color.cyan, Color(hex:"2A3B7F")],
                                                   startPoint: .leading,
                                                   endPoint: .trailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 40)
                }
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                .alert(isPresented: $showReviewConfirmation) {
                    Alert(
                        title: Text("Review Submission"),
                        message: Text(confirmationMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
                .onAppear {
                    boardingVM.fetchPlaces()
                    droppingVM.fetchPlaces()
                    operatorVM.fetchOperators()
                }
            }
        }
        .background(.gray)
    }
    
    // MARK: - Submit Handler
    // MARK: - Submit Handler
    func submitReview() {
        let (isValid, message) = validateReviewForm(
            busOperator: busOperator,
            busNumber: busNumber,
            boardingPoint: boardingPoint,
            droppingPoint: droppingPoint,
            selectedBusType: selectedBusType,
            selectedACType: selectedACType,
            punctualityRating: punctualityRating,
            cleanlinessRating: cleanlinessRating,
            comfortRating: comfortRating,
            staffBehaviorRating: staffBehaviorRating,
            ticketURL: selectedTicketURL   // ✅ new check
        )
        
        guard isValid else {
            confirmationMessage = message
            showReviewConfirmation = true
            return
        }
        
        let imageDatas: [Data] = selectedUIImages.compactMap { $0.jpegData(compressionQuality: 0.8) }
        let pdfData = selectedTicketURL.flatMap { try? Data(contentsOf: $0) }
        
        if let userID = appState.storedUserID {
            postReview(
                userID: userID,
                busOperator: busOperator,
                busNumber: busNumber,
                busType: selectedBusType,
                boardingPoint: boardingPoint,
                droppingPoint: droppingPoint,
                dateOfTravel: formattedDate(from: journeyDate),
                acType: selectedACType,
                punctuality: punctualityRating,
                cleanliness: cleanlinessRating,
                comfort: comfortRating,
                staffBehaviour: staffBehaviorRating,
                reviewText: reviewText,
                confirmed: confirmJourney,
                ticketPDF: pdfData,       // ✅ send PDF
                images: imageDatas
            ) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        confirmationMessage = isNewBusAdded
                            ? "Your review is being reviewed."
                            : "✅ Review Posted!"
                        showReviewConfirmation = true
                        resetForm()
                    case .failure(let error):
                        confirmationMessage = "❌ \(error.localizedDescription)"
                        showReviewConfirmation = true
                    }
                }
            }
        }
    }

    
    func resetForm() {
        busOperator = ""
        busNumber = ""
        boardingPoint = ""
        selectedBoarding = nil
        droppingPoint = ""
        selectedDropping = nil
        journeyDate = Date()
        selectedBusType = ""
        selectedACType = ""
        punctualityRating = 0
        cleanlinessRating = 0
        comfortRating = 0
        staffBehaviorRating = 0
        reviewText = ""
        selectedUIImages = []
        selectedTicketURL = nil   // ✅ clear PDF
        confirmJourney = false
        isNewBusAdded = false
    }
}

// MARK: - Card Section Modifier
struct CardSection<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .gray.opacity(0.2), radius: 6, x: 0, y: 3)
        .padding(.horizontal, 16)
    }
}


#Preview(){
    PostView()
        .environmentObject(AppState())
}

import SwiftUI

struct AddBusView: View{
    @StateObject var boardingVM = PlaceSearchViewModel()
    @StateObject var droppingVM = PlaceSearchViewModel()
    @State private var selectedACType: String = ""
    @State var BusOperator: String = ""
    @State private var selectedBusType: String = ""
    @State var BoardingPoint: String = ""
    @State private var selectedBoarding: Place? = nil
    @State var DroppingPoint = ""
    @State private var selectedDropping: Place? = nil
    
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    var body: some View{
        NavigationView{
            VStack{
                VStack(alignment: .leading,spacing: 12){
                    Text("Add Bus Operator")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color(hex:"2A3B7F"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                }
                
                ScrollView{
                    VStack(alignment: .leading,spacing: 14){
                        Text("Bus Operator")
                            .font(.headline)
                        CustomTextField(title: "Bus operator", text: $BusOperator)
                        
                        Text("Boarding Point")
                            .font(.headline)
                        LocationSearchField(viewModel: boardingVM,title:"Boarding Point", searchText: $BoardingPoint, selectedPlace: $selectedBoarding,icon:"map")
                        
                        Text("Dropping Point")
                            .font(.headline)
                        LocationSearchField(viewModel: droppingVM, title:"Dropping Point",searchText: $DroppingPoint, selectedPlace: $selectedDropping,icon:"map")
                        
                        HStack {
                            Text("Bus Type")
                                .font(.headline)
                            Spacer()
                        
                            OptionButton(title: "Sleeper", isSelected: selectedBusType == "Sleeper") {
                                selectedBusType = "Sleeper"
                            }

                            OptionButton(title: "Seater", isSelected: selectedBusType == "Seater") {
                                selectedBusType = "Seater"
                            }
                        }
                        
                        HStack(spacing: 16){
                            Text("AC Type")
                                .font(.headline)
                            Spacer()
                            OptionButton(title:"AC",isSelected: selectedACType == "AC"){
                                selectedACType="AC"
                            }
                            OptionButton(title:"Non-AC",isSelected: selectedACType == "Non-AC"){
                                selectedACType="Non-AC"
                            }
                        }
                        .padding(.bottom,20)
                        
                        Button(action: submitBus) {
                            Text("Submit")
                                .padding(.horizontal,10)
                                .padding(.vertical,10)
                                .foregroundColor(.white)
                                .background(Color(hex:"2A3B7F"))
                                .cornerRadius(13)
                        }
                        .frame(maxWidth: .infinity)
                        // Success alert
                        .alert("Bus Added Successfully", isPresented: $showSuccessAlert) {
                            Button("OK", role: .cancel) { }
                        }
                        // Error alert
                        .alert("Error", isPresented: $showErrorAlert) {
                            Button("OK", role: .cancel) { }
                        } message: {
                            Text(errorMessage)
                        }
                    }
                }
            }
            .onAppear {
                boardingVM.fetchPlaces()
                droppingVM.fetchPlaces()
            }
            .padding(.horizontal,30)
        }
    }
    
    // MARK: - Submit Bus
    func submitBus() {
        // Check for missing fields
        guard !BusOperator.isEmpty,
              !BoardingPoint.isEmpty,
              !DroppingPoint.isEmpty,
              !selectedBusType.isEmpty,
              !selectedACType.isEmpty else {
            errorMessage = "Please fill in all fields."
            showErrorAlert = true
            return
        }
        
        BusService.submitBus(
            busOperator: BusOperator,
            boardingPoint: BoardingPoint,
            droppingPoint: DroppingPoint,
            busType: selectedBusType,
            acType: selectedACType
        ) { result in
            switch result {
            case .success(_):
                showSuccessAlert = true
                resetForm()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showErrorAlert = true
            }
        }
    }
    
    // MARK: - Reset all fields
    func resetForm() {
        BusOperator = ""
        BoardingPoint = ""
        DroppingPoint = ""
        selectedBusType = ""
        selectedACType = ""
        selectedBoarding = nil
        selectedDropping = nil
    }
}

#Preview {
    AddBusView()
}

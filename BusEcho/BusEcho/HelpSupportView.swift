import SwiftUI

struct HelpSupportView: View {
    @State private var showFAQ = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: - FAQ
                    Button(action: { showFAQ.toggle() }) {
                        SupportCardView(
                            icon: "questionmark.circle.fill",
                            title: "FAQs",
                            subtitle: "Find answers to common questions",
                            color: Color(hex: "2A3B7F")
                        )
                    }
                    .sheet(isPresented: $showFAQ) {
                        FAQView()
                    }
                    
                    // MARK: - Contact
                    Button(action: {
                        if let url = URL(string: "mailto:maanojpalani@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        SupportCardView(
                            icon: "envelope.fill",
                            title: "Email Us",
                            subtitle: "Get in touch via email",
                            color: .blue
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Help & Support")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Card Component
struct SupportCardView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ Fix alignment
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading) // ✅ For multi-line consistency
                    .frame(maxWidth: .infinity, alignment: .leading) // ✅ Keeps wrapped lines aligned
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
    }
}

// MARK: - FAQ View
struct FAQView: View {
    let faqs: [(question: String, answer: String)] = [
        ("How do I post a review?", "Go to the Post tab and fill in the details."),
        ("How do I edit my profile?", "Go to Profile → Settings to update your details."),
        ("How do I contact support?", "You can email us at busecho.support@gmail.com.")
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(faqs, id: \.question) { faq in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(faq.question)
                                .font(.headline)
                                .foregroundColor(Color(hex: "2A3B7F"))
                            Text(faq.answer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading) // ✅ Makes all cards same width
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal) // Keeps equal padding from screen edges
            }
            .navigationTitle("FAQs")
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}


#Preview {
    HelpSupportView()
}

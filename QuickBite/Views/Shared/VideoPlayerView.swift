import SwiftUI

struct VideoPlayerView: View {
    let youTubeId: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            YouTubeView(youTubeId: youTubeId)
                .ignoresSafeArea()
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .opacity(0.8)
            }
            .padding()
        }
    }
}

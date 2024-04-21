import SwiftUI

struct ImageUIView: View {
    var body: some View {
        Image("Cat")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: 40))
            .frame(width: 300, height: 300)
            .border(.blue)
            .mask(Circle())
        Image(systemName: "pencil")
            .font(.system(size: 60))
    }
}

#Preview {
    ImageUIView()
}

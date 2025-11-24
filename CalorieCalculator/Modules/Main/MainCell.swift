
import SwiftUI

struct MainCell: View {
    var title: String
    var kcal: Int
    var image: UIImage?
    
    var body: some View {
        VStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.black)
            
            if let photo = image {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            
            Spacer()
            
            Text("\(kcal)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
        }
    }
}

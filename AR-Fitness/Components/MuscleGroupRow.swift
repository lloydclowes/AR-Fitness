import SwiftUI

struct MuscleGroupRow: View {
    
    var icon: String
    var color: UIColor
    var iconSize: Int
    var muscleGroup: String
    
    var body: some View {
        HStack {
            IconView(iconName: self.icon, color: self.color, size: self.iconSize)
            Text(self.muscleGroup)
                .fontWeight(.semibold)
                .padding()
            Spacer()
        }
    }
}

struct MuscleGroupRow_Previews: PreviewProvider {
    static var previews: some View {
        MuscleGroupRow(icon: "leg-icon", color: .blue, iconSize: 33, muscleGroup: "Legs")
    }
}

import SwiftUI

struct ExerciseDetailView: View {
    
    @State private var searchQuery: String = ""
    
    let title: String
    var exercises: [Exercise]

    var body: some View {
        VStack{
            SearchBar(text: $searchQuery)
                .padding([.horizontal], 12)
                .padding([.top], -9)
            ForEach(exercises.filter{$0.name.lowercased().hasPrefix(searchQuery.lowercased()) || searchQuery == ""}, id:\.self) { exercise in
                ExerciseRowView(exercise: exercise,
                                 color: Color(red: 1.00, green: 0.98, blue: 0.98)).padding()
            }
            Spacer()
        }
        .navigationBarTitle(Text(self.title))
        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseDetailView(
            title: "Core",
            exercises: exerciseData.filter {
                switch $0.muscleGroup {
                case .core: return true
                    default: return false
                }
            }
        )
    }
}


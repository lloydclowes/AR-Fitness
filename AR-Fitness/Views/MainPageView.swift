import SwiftUI

struct MainPageView: View {
    
    @State private var searchQuery: String = ""
    
    var exercises: [Exercise] = exerciseData
    private var searchBarIsActive = false
    
    init() {
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.5)
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                
                SearchBar(text: $searchQuery)
                    .padding([.horizontal], 13)
                    .padding([.top], -9)
                if (searchQuery == "") {
                Text("Select your type of workout:")
                    .font(.headline)
                NavigationLink(destination: ExerciseDetailView(
                    title: "High Intensity",
                    exercises: filterByIntensity(exercises: self.exercises, intensity: .high)
                )) {
                    IntensityButtonView(text: "High Intensity", color: .orange)
                }.padding()
                NavigationLink(destination: ExerciseDetailView(
                    title: "Low Intensity",
                    exercises: filterByIntensity(exercises: self.exercises, intensity: .low)
                )) {
                    IntensityButtonView(text: "Low Intensity", color: .green)
                }.padding()
                HStack {
                    Text("Muscle groups")
                        .font(.system(size: 20, weight: .bold))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    Spacer()
                }.padding([.horizontal])
                MuscleGroupsList(exercises: self.exercises)
                    .frame(height: 258)
                    .padding([.horizontal])
                
                } else {
                    ForEach(exercises.filter{$0.name.lowercased().hasPrefix(searchQuery.lowercased())}, id:\.self) { exercise in
                    ExerciseRowView(exercise: exercise,
                                     color: Color(red: 1.00, green: 0.98, blue: 0.98)).padding()
                    }
                }
                Spacer()
            }
            .navigationBarTitle(Text("Exercises"))
            .background(Color(red: 0.95, green: 0.95, blue: 0.95))
            .edgesIgnoringSafeArea(.bottom)
        }
        
    }
    
    private func filterByIntensity(exercises: [Exercise], intensity: Intensity) -> [Exercise] {
        return exercises.filter {
            switch $0.intensity {
                case intensity: return true
                default: return false
            }
        }
    }
    
}


struct MainPageView_Previews: PreviewProvider {
    static var previews: some View {
        MainPageView()
    }
}

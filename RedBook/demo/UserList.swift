import SwiftUI

struct UserList: View {
    @State private var users: [User] = []
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            List(users) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Users")
            .onAppear {
                fetchUsers()
            }
        }
    }
    
    func fetchUsers() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        NetworkManager.shared.get(url: url) { (result: Result<[User], Error>) in
            switch result {
            case .success(let users):
                DispatchQueue.main.async {
                    self.users = users
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func createUser(name: String, email: String) {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
        
        let newUser = User(id: 0, name: name, email: email)
        guard let httpBody = try? JSONEncoder().encode(newUser) else { return }
        
        NetworkManager.shared.post(url: url, body: httpBody) { (result: Result<User, Error>) in
            switch result {
            case .success(let createdUser):
                DispatchQueue.main.async {
                    self.users.append(createdUser)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    UserList()
}

import Vapor
import Fluent

final class Member: Model {

    var id: Node?
    var exists: Bool = false
    
    var name: String
    var email: String
    
    init(name: String, email: String) {
        self.id = nil
        self.name = name
        self.email = email
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        email = try node.extract("email")
    }
    
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "email": email
            ])
    }
    
}

extension Member: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("members", closure: { member in
            member.id()
            member.string("name")
            member.string("email")
        })
    }
    
    
    static func revert(_ database: Database) throws {
        try database.delete("members")
    }
}

import Vapor
import Fluent
import HTTP

final class Teacher: Model {
    
    var id: Node?
    var exists: Bool = false
    
    var name: String
    var grade: String
    var code: String
    
    init(name: String, grade: String, code: String) {
        self.id = nil
        self.name = name
        self.grade = grade
        self.code = code
    }
    
    
    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        grade = try node.extract("grade")
        code = try node.extract("code")
    }
    
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name,
            "grade": grade,
            "code": code
            ])
    }
    
}


extension Teacher: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("Teachers", closure: { Teacher in
            Teacher.id()
            Teacher.string("name")
            Teacher.string("grade")
            Teacher.string("code")
        })
    }
    
    
    static func revert(_ database: Database) throws {
        try database.delete("Teachers")
    }
}

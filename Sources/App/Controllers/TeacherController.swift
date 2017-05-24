import Vapor
import HTTP
import Foundation
import VaporPostgreSQL

final class TeacherController {
    
    func addRoutes(drop: Droplet) {
        drop.group("teachers") { group in
            group.post("create", handler: create)
            group.get(handler: index)
            group.get("show", Teacher.self, handler: show)
            group.patch("update", Teacher.self, handler: update)
            group.get("update", Teacher.self, handler: updateWithForm)
            group.post("delete", Teacher.self, handler: delete)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var name: String? = .none
        var grade: String? = .none
        
        if let formData = request.formData {
            guard let aName = formData["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = formData["grade"]?.string else { throw Abort.badRequest }
            name = aName
            grade = aGrade
        }
        else if let json = request.json {
            guard let aName = json["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = json["grade"]?.string else { throw Abort.badRequest }
            name = aName
            grade = aGrade
        }
        
        guard name != .none && grade != .none else { throw Abort.badRequest }
        
        let code = try makeCodeUnique(grade: grade!, name: name!)
        let validCode: Valid<Code> = try code.validated()
        
        var teacher = Teacher(name: name!, grade: grade!, code: validCode.value)
        try teacher.save()
        return try Teacher.all().makeNode().converted(to: JSON.self)
    }
    
    private func makeCodeUnique(grade: String, name: String) throws -> String {
        var code = String.makeCode(grade: grade, name: name)
        
        let codesQuery = try Teacher.query().filter("code", .contains, code).all()
        let count = codesQuery.count
        if count > 0 {
            code.uniqueCode(name: name, idx: 0)
            for var teacher in codesQuery {
                if teacher.code.lengthOfBytes(using: .utf8) == 2 {
                    teacher.code.uniqueCode(name: teacher.name, idx: 0)
                    try teacher.save()
                }
                if teacher.code == code {
                    code.uniqueCode(name: name, idx: 1)
                }
            }
        }
        
        let validCode: Valid<Code> = try code.validated()
        code = validCode.value
        return code
    }
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Teacher.all().makeNode().converted(to: JSON.self)
    }
    
    
    func show(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        return teacher
    }
    
    
    func update(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        let new = try request.teacher()
        var teacher = teacher
        teacher.name = new.name
        teacher.grade = new.grade
        let code = String.makeCode(grade: new.grade, name: new.name)
        teacher.code = code
        try teacher.save()
        return teacher
    }
    
    
    func updateWithForm(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        var name: String? = .none
        var grade: String? = .none
        
        if let queryData = request.query {
            guard let aName = queryData["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = queryData["grade"]?.string else { throw Abort.badRequest }
            
            name = aName
            grade = aGrade
        }
        
        guard name != .none && grade != .none else { throw Abort.badRequest }
        
        var aTeacher = teacher
        aTeacher.name = name!
        aTeacher.grade = grade!
        let code = try makeCodeUnique(grade: grade!, name: name!)
        aTeacher.code = code
        
        try aTeacher.save()
        return try Teacher.all().makeNode().converted(to: JSON.self)
    }
    
    
    func delete(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        try teacher.delete()
        return JSON([:])
    }
}


extension Request {
    func teacher() throws -> Teacher {
        guard let json = json else { throw Abort.badRequest }
        
        return try Teacher(node: json)
    }
}


extension String {
    static func makeCode(grade: String, name: String) -> String {
        let nameChar = name.characters
        var code = "Invalid"
        if let firstInitial = nameChar.first?.description {
            code = grade + firstInitial
        }
        return code.uppercased()
    }
    
    
    mutating func uniqueCode(name: String, idx: Int) {
        if self.characters.count > 2 {
            self = String(self.characters.prefix(2))
        }
        var code = "Invalid"
        let count = name.characters.count
        if idx < count {
            let nextInitial = name[name.index(startIndex, offsetBy: idx + 1)].description
            code = self + nextInitial
        }
        self = code.uppercased()
    }
}


class Code: ValidationSuite {
    static func validate(input value: String) throws {
        let range = value.range(of: "^(?=.*[0-9])(?=.*[A-Z])", options: .regularExpression)
        guard let _ = range else {
            throw error(with: value)
        }
    }
}




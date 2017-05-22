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
        var code: String? = .none
        
        if let formData = request.formData {
            guard let aName = formData["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = formData["grade"]?.string else { throw Abort.badRequest }
            guard let aCode = formData["code"]?.string else { throw Abort.badRequest }
            
            name = aName
            grade = aGrade
            code = aCode
        }
        else if let json = request.json {
            guard let aName = json["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = json["grade"]?.string else { throw Abort.badRequest }
            guard let aCode = json["code"]?.string else { throw Abort.badRequest }
            
            name = aName
            grade = aGrade
            code = aCode
        }
        
        guard name != .none && grade != .none && code != .none else { throw Abort.badRequest }
        
        var teacher = Teacher(name: name!, grade: grade!, code: code!.uppercased())
        try teacher.save()
        return try Teacher.all().makeNode().converted(to: JSON.self)
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
        try teacher.save()
        return teacher
    }
    
    
    func updateWithForm(request: Request, teacher: Teacher) throws -> ResponseRepresentable {
        var name: String? = .none
        var grade: String? = .none
        var code: String? = .none
        
        if let queryData = request.query {
            guard let aName = queryData["name"]?.string else { throw Abort.badRequest }
            guard let aGrade = queryData["grade"]?.string else { throw Abort.badRequest }
            guard let aCode = queryData["code"]?.string else { throw Abort.badRequest }
            
            name = aName
            grade = aGrade
            code = aCode
        }
        
        guard name != .none && grade != .none && code != .none else { throw Abort.badRequest }
        
        var aTeacher = teacher
        aTeacher.name = name!
        aTeacher.grade = grade!
        aTeacher.code = code!.uppercased()
        
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

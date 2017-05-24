import Vapor
import HTTP
import Foundation
import VaporPostgreSQL

final class MemberController {
    
    func addRoutes(drop: Droplet) {
        drop.group("members") { group in
            group.post("create", handler: create)
            group.get(handler: index)
            group.get("show", Member.self, handler: show)
            group.patch("update", Member.self, handler: update)
            group.post("delete", Member.self, handler: delete)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        var name: String? = .none
        var email: String? = .none
        
        if let formData = request.formData {
            guard let aName = formData["name"]?.string else { throw Abort.badRequest }
            guard let anEmail = formData["email"]?.string else { throw Abort.badRequest }
            
            name = aName
            email = anEmail
        }
        else if let json = request.json {
            guard let aName = json["name"]?.string else { throw Abort.badRequest }
            guard let anEmail = json["email"]?.string else { throw Abort.badRequest }
            
            name = aName
            email = anEmail
        }
        
        guard name != .none && email != .none else { throw Abort.badRequest }
        
        let validEmail: Valid<Email> = try email!.validated()
        var member = Member(name: name!, email: validEmail.value)
        try member.save()
        return try Member.all().makeNode().converted(to: JSON.self)
    }
    
    
    func index(request: Request) throws -> ResponseRepresentable {
        return try Member.all().makeNode().converted(to: JSON.self)
    }
    
    
    func show(request: Request, member: Member) throws -> ResponseRepresentable {
        return member
    }
    
    
    func update(request: Request, member: Member) throws -> ResponseRepresentable {
        let new = try request.member()
        var member = member
        
        let validEmail: Valid<Email> = try new.email.validated()
        
        member.name = new.name
        member.email = validEmail.value
        try member.save()
        return member
    }
    
    
    func delete(request: Request, member: Member) throws -> ResponseRepresentable {
        try member.delete()
        return JSON([:])
    }
}


extension Request {
    func member() throws -> Member {
        guard let json = json else { throw Abort.badRequest }
        
        return try Member(node: json)
    }
}


extension Date {
    func stringForDate() -> String {
        var dateString = ""
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'at' hh:mm"
        dateString = formatter.string(from: self)
        
        return dateString
    }
}

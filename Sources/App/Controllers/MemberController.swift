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
        guard let name = request.formData?["name"]?.string else { throw Abort.badRequest }
        guard let email = request.formData?["email"]?.string else { throw Abort.badRequest }
        
        
        var member = Member(name: name, email: email)
        try member.save()
        return Response(redirect: "/members")
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
        member.name = new.name
        member.email = new.email
        try member.save()
        return member
    }
    
    
    func delete(request: Request, member: Member) throws -> ResponseRepresentable {
        try member.delete()
        return Response(redirect: "/members")
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

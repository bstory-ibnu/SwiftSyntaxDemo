import SwiftSyntax

/// Finds the required information to generate `using`
public class PerformFinder: SyntaxVisitor {
    let performMark = "// Perform"
    public var functions: [FunctionDeclSyntax] = []
    
    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        if let comments = node.leadingTrivia?.compactMap({ piece -> String? in
            if case let TriviaPiece.lineComment(comment) = piece {
                return comment
            }
            return nil
        }), comments.first(where: { $0 == performMark }) != nil {
            functions.append(node)
        }
        return .skipChildren
    }
}

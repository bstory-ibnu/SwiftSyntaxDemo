//
//  File.swift
//  
//
//  Created by ibnu.sina on 08/11/22.
//

import Foundation
import SwiftSyntax

extension SyntaxFactory {
    private static var performMark: String { "// Perform" }
    
    
    public static func addPerform(_ node: FunctionDeclSyntax) -> FunctionDeclSyntax {
        /// Filter out `// Perfom` commen
        let trivia = node.leadingTrivia?.filter({ piece in
            if case let TriviaPiece.lineComment(comment) = piece, comment == performMark {
                return false
            }
            return true
        })
        
        /// change nothing if `// Perform` not found
        if trivia?.count == node.leadingTrivia?.count {
            return node
        }
        
        
        var newNode = node
        
        /// Assign new comment without `// Peform`
        newNode = node.withLeadingTrivia(Trivia(pieces: trivia ?? []))
        
        /// Add new param to fucntion
        newNode = newNode.withSignature(funcSign(node: node))
        
        /// Wrap function content with Meausure{}
        newNode = newNode.withBody(funcContent(node: node))
        
        return newNode
    }
    
    /// generate `callerFile = #file` param
    private static func callerFileParam() -> FunctionParameterSyntax {
        let param = makeFunctionParameter(
            attributes: nil,
            firstName: nil,
            secondName: makeStringLiteral("callerFile"),
            colon: makeColonToken(),
            type: makeTypeIdentifier("String", leadingTrivia: Trivia.spaces(1), trailingTrivia: Trivia.spaces(1)),
            ellipsis: nil,
            defaultArgument: makeInitializerClause(
                equal: makeEqualToken().withTrailingTrivia(Trivia.spaces(1)),
                value: ExprSyntax(makePoundFileExpr(poundFile: makePoundFileKeyword()))),
            trailingComma: nil)
        return param
    }
    
    
    /// generate `callerFunction = #function` param
    private static func callerFunctionParam() -> FunctionParameterSyntax {
        let param = makeFunctionParameter(
            attributes: nil,
            firstName: nil,
            secondName: makeStringLiteral("callerFunction"),
            colon: makeColonToken(),
            type: makeTypeIdentifier("String", leadingTrivia: Trivia.spaces(1), trailingTrivia: Trivia.spaces(1)),
            ellipsis: nil,
            defaultArgument: makeInitializerClause(
                equal: makeEqualToken().withTrailingTrivia(Trivia.spaces(1)),
                value: ExprSyntax(makePoundFunctionExpr(poundFunction: makePoundFunctionKeyword()))),
            trailingComma: makeCommaToken().withTrailingTrivia(.spaces(1)))
        return param
    }
    
    /// generate new function with new params
    /// `callerFunction = #function, callerFile = #file`
    private static func funcSign(node: FunctionDeclSyntax) -> FunctionSignatureSyntax {
        var newParamList = node.signature.input.parameterList
        if var lastParam = newParamList.last {
            lastParam = lastParam.withTrailingComma(makeCommaToken().withTrailingTrivia(Trivia.spaces(1)))
            newParamList = newParamList.removingLast()
            newParamList = newParamList.appending(lastParam)
        }
        
        newParamList = newParamList.appending(callerFunctionParam())
        newParamList = newParamList.appending(callerFileParam())
        let sign = makeFunctionSignature(
            input: makeParameterClause(
                leftParen: node.signature.input.leftParen,
                parameterList: newParamList,
                rightParen: node.signature.input.rightParen),
            asyncOrReasyncKeyword: node.signature.asyncOrReasyncKeyword,
            throwsOrRethrowsKeyword: node.signature.throwsOrRethrowsKeyword,
            output: node.signature.output
        )
        return sign
    }
    
    /// Wrap function content with `Measure(at: Self) { .... }`
    private static func funcContent(node: FunctionDeclSyntax) -> CodeBlockSyntax? {
        
        guard let oldContent = node.body?.statements,
              let leadingTrivia = oldContent.first?.leadingTrivia
        else {
            return node.body
        }
        
        /// Add additional tab for old content because it will be wrapped inside closure
        let children = oldContent.children.map { syntax -> CodeBlockItemSyntax in
            if let leading = syntax.leadingTrivia {
                return makeCodeBlockItem(item: syntax.withLeadingTrivia(leading.appending(TriviaPiece.tabs(1))), semicolon: nil, errorTokens: nil)
            }
            return  makeCodeBlockItem(item: syntax, semicolon: nil, errorTokens: nil)
        }
        
        let newContent = makeCodeBlockItemList(children)
        
        /// Create new body e.g from
        /// `{
        ///     a
        ///  }`
        ///
        ///  to
        ///
        ///  `{
        ///     {
        ///         a
        ///     }
        ///    }`
        let closure = makeClosureExpr(
            leftBrace: makeLeftBraceToken(),
            signature: nil,
            statements: newContent,
            rightBrace: makeRightBraceToken().withLeadingTrivia(leadingTrivia)
        )
        
        
        /// Create `Measure(at: self)` and append `closure` syntax
        let funcCall = makeFunctionCallExpr(
            calledExpression: ExprSyntax(makeIdentifierExpr(identifier: makeIdentifier("Measure"), declNameArguments: nil)),
            leftParen: makeLeftParenToken(),
            argumentList: makeTupleExprElementList([
                makeTupleExprElement(
                    label: makeStringLiteral("at"),
                    colon: makeColonToken(),
                    expression: ExprSyntax(makeIdentifierExpr(identifier: makeIdentifier(" Self"), declNameArguments: nil)),
                    trailingComma: nil)
            ]),
            rightParen: makeRightParenToken().withTrailingTrivia(Trivia.spaces(1)),
            trailingClosure: closure,
            additionalTrailingClosures: nil
        )
        
        /// check existing `return` statement
        let hasReturn = node.signature.output != nil
        
        /// Add `return` outside `Measure(at: self) {}` if needed
        let syntax: Syntax = hasReturn ?
            Syntax(makeReturnStmt(returnKeyword: makeReturnKeyword(), expression: ExprSyntax(funcCall.withLeadingTrivia(Trivia.spaces(1))))
            ).withLeadingTrivia(leadingTrivia) :
            Syntax(funcCall.withLeadingTrivia(leadingTrivia))
        
        let newStatements = makeCodeBlockItemList([
            makeCodeBlockItem(item: syntax, semicolon: nil, errorTokens: nil)
        ])
        
        let newBody = node.body?.withStatements(newStatements)
        return newBody
    }
    
    
}

extension Trivia {
    static func newLine(indented: Int) -> Trivia {
        let tab = TriviaPiece.tabs(indented)
        return .init(arrayLiteral: .newlines(1), tab)
    }
}

#ifndef AVIALVISITOR
#define AVIALVISITOR 


class DeclarationStatement;
class ForallStatement;
class IfStatement;
class BoolExpr;
class Incandassignstmt;
class Identifier;
class ReturnStmt;
class Function;

class Visitor
{
    public:
        virtual ~Visitor() = default;

        virtual void visitDeclarationStmt(const DeclarationStatement *declStmt) = 0;
        virtual void visitForallStmt(const ForallStatement *forAllStmt) = 0;
        virtual void visitIfStmt(const IfStatement *ifStmt) = 0;
        virtual void visitBoolExpr(const BoolExpr *boolExpr) = 0;
        virtual void visitIncandassignstmt(const Incandassignstmt *incandassignstmt) = 0;
        virtual void visitIdentifier(const Identifier *identifier) = 0;
        virtual void visitReturnStmt(const ReturnStmt *returnStmt) = 0;
        virtual void visitFunction(const Function *function) = 0;
    
};

#endif
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
class Paramlist;
class Arglist;
class Arg;
class Statement;
class Statementlist;
class TypeExpr;
class Number;
class Expression;
class Methodcall;
class Memberaccess;


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
        virtual void visitParamlist(const Paramlist *paramlist) = 0;
        virtual void visitArglist(const Arglist *arglist) = 0;
        virtual void visitArg(const Arg *arg) = 0;
        virtual void visitStatement(const Statement *stmt) = 0;
        virtual void visitStatementlist(const Statementlist *stmt) = 0;
        virtual void visitType(const TypeExpr *type) = 0;
        virtual void visitNumber(const Number *number) = 0;
        virtual void visitExpression(const Expression *expr) = 0;
        virtual void visitMethodcall(const Methodcall *methodcall) = 0;
        virtual void visitMemberaccess(const Memberaccess *methodcall) = 0;
    
};

#endif
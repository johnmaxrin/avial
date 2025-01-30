#include "include/AvialDialect.h"

#include "mlir/IR/Builders.h"  // For mlir::OpBuilder
#include "mlir/IR/Operation.h" // For mlir::Operation
#include "mlir/IR/Dialect.h"   // For mlir::Dialect

#include "mlir/IR/AsmState.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/Verifier.h"
#include "mlir/Parser/Parser.h"

#include "include/AvialTypes.h"
#include "include/AvialOps.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/Arith/IR/Arith.h"

class MLIRCodeGen : public Visitor
{

public:
    MLIRCodeGen() : result(0),
                    context(),
                    builder(&context),
                    module(mlir::ModuleOp::create(builder.getUnknownLoc()))
    {
        // Load Dialects here.
        context.getOrLoadDialect<mlir::func::FuncDialect>();
        context.getOrLoadDialect<mlir::arith::ArithDialect>();
        context.getOrLoadDialect<mlir::avial::AvialDialect>();
    }

    virtual void visitDeclarationStmt(const DeclarationStatement *dclstmt) override
    {
    }

    virtual void visitForallStmt(const ForallStatement *forAllStmt) override
    {
    }

    virtual void visitIfStmt(const IfStatement *ifStmt) override
    {
    }

    virtual void visitBoolExpr(const BoolExpr *boolExpr) override
    {
    }

    virtual void visitIncandassignstmt(const Incandassignstmt *incandassignstmt) override
    {
    }

    virtual void visitIdentifier(const Identifier *identifier) override
    {
    }

    virtual void visitReturnStmt(const ReturnStmt *returnStmt) override
    {
    }

    virtual void visitFunction(const Function *function) override
    {

        auto grty = mlir::avial::GraphType::get(builder.getContext());
        auto ndty = mlir::avial::NodeType::get(builder.getContext());

        auto intType = builder.getIntegerType(64);

        auto funcTy = builder.getFunctionType({grty}, intType);
        // auto funcTy = builder.getFunctionType({}, builder.getIntegerType(32));
        llvm::StringRef value = "g";
        llvm::ArrayRef<mlir::NamedAttribute> attrs;
        llvm::ArrayRef<mlir::DictionaryAttr> args;

        llvm::SmallVector<mlir::NamedAttribute, 4> attributes;

        llvm::SmallVector<mlir::DictionaryAttr, 4> arguments;

        auto funcBl = mlir::func::FuncOp::create(builder.getUnknownLoc(), function->getfuncNameIdentifier(), funcTy, attributes, arguments);
        module.push_back(funcBl);

        auto *entryBlock = funcBl.addEntryBlock();
        builder.setInsertionPointToStart(entryBlock);


        auto valueAttr = builder.getIntegerAttr(builder.getIntegerType(64), 0);
        builder.create<mlir::arith::ConstantOp>(builder.getUnknownLoc(), builder.getIntegerType(64), valueAttr);
        
        auto garphvar = builder.create<mlir::avial::createCSRGraph>(builder.getUnknownLoc(), grty, builder.getStringAttr("Grapg"));
        builder.create<mlir::avial::GetNodes>(builder.getUnknownLoc(), ndty, garphvar);


        auto valueAttr2 = builder.getIntegerAttr(builder.getIntegerType(64), 0);


        auto forallOp = builder.create<mlir::avial::forAll>(builder.getUnknownLoc(), valueAttr2);

        mlir::Region &bodyRegion = forallOp.getBody();
        bodyRegion.push_back(new mlir::Block);
        mlir::Block &block = bodyRegion.back();

        builder.setInsertionPointToStart(&block);

        
    }

    virtual void visitParamlist(const Paramlist *paramlist) override
    {
    }

    virtual void visitMethodcall(const Methodcall *methodcall) override
    {
    }

    virtual void visitMemberaccess(const Memberaccess *memberaccess) override
    {
    }

    virtual void visitArglist(const Arglist *arglist) override
    {
    }

    virtual void visitArg(const Arg *arg) override
    {
    }

    virtual void visitStatement(const Statement *statement) override
    {
    }

    virtual void visitStatementlist(const Statementlist *stmtlist) override
    {
    }

    virtual void visitType(const TypeExpr *type) override
    {
    }

    virtual void visitNumber(const Number *number) override
    {
    }

    virtual void visitExpression(const Expression *expr) override
    {
    }

    void printModule()
    {
        module.dump();
    }

private:
    int result;
    map<string, int> variables;

    mlir::MLIRContext context;
    mlir::OpBuilder builder;
    mlir::ModuleOp module;
};

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include "ast/ast.h"
#include "ast/visitor.h"
#include "codegen/astdump.h"
#include "codegen/mlirgen.h"
#include "avial.tab.h"

#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"

extern int yyparse();
extern FILE *yyin;
ASTNode* root;

int main(int argc, char *argv[])
{
    root = nullptr;

    if (argc < 2)
    {
        printf("%s usage\n%s <file name>\n", argv[0], argv[0]);
        return 0;
    }

    FILE *file = fopen(argv[1], "r");
    if (!file)
    {
        printf("Cannot open file. \n");
        return 0;
    }

    yyin = file;
    yyparse();
    fclose(file);

    // CodeGen *gen = new CodeGen;


    MLIRCodeGen *MLIRgen = new MLIRCodeGen;

    if(root!= nullptr)
        root->Accept(MLIRgen);
    
    MLIRgen->printModule();
    

    return 0;
}
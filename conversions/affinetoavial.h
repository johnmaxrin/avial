#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"


#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include "mlir/Conversion/Passes.h"

#include "analysis/polyHedralAnalysis.h"

#include <string>

using namespace mlir;
using namespace avial;





namespace mlir
{
    namespace avial
    {

#define GEN_PASS_DEF_CONVERTAFFINETOAVIALPASS 

#include "dialect/Passes.h.inc"

        struct ConvertAffineToAvialPass : public mlir::avial::impl::ConvertAffineToAvialPassBase<ConvertAffineToAvialPass>
        {
            using ConvertAffineToAvialPassBase::ConvertAffineToAvialPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
               
                // Do the analysis on ForLoop and if there isn't any dependence, a particular nest, Wrap it with avial.replicate 
                
                llvm::outs() << "Hello from Affine to Avial\n";

            }
        };
    }

}
#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/avialDialect.h"

namespace mlir
{
    namespace avial
    {
#define GEN_PASS_DEF_CONVERTAVIALIRTOMPIPASS
#include "dialect/Passes.h.inc"

    struct ConvertAvialIRToMPIPass : public mlir::avial::impl::ConvertAvialIRToMPIPassBase<ConvertAvialIRToMPIPass>
    {
        using ConvertAvialIRToMPIPassBase::ConvertAvialIRToMPIPassBase;
        void runOnOperation() override
        {
           llvm::outs() << "Hello\n"; 
        }
    };

    }

}
#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

using namespace mlir;
using namespace avial;

namespace mlir
{
    namespace avial
    {
#define GEN_PASS_DEF_CONVERTSTDTOAVIALPASS
#include "dialect/Passes.h.inc"

        struct ConvertStdToAvialPass : public mlir::avial::impl::ConvertStdToAvialPassBase<ConvertStdToAvialPass>
        {
            using ConvertStdToAvialPassBase::ConvertStdToAvialPassBase;
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();

                llvm::outs() <<"Hello\n";

            }
        };

    }

}

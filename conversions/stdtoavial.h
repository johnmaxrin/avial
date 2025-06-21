#include "mlir/Pass/PassManager.h"
#include "mlir/IR/PatternMatch.h"

#include "includes/avialDialect.h"
#include "includes/avialTypes.h"

#include "mlir/Transforms/DialectConversion.h"

#include "mlir/Conversion/LLVMCommon/ConversionTarget.h"
#include "mlir/Conversion/Passes.h"

#include "llvm/Support/Casting.h"

#include "mlir/Dialect/Func/IR/FuncOps.h"

#include "includes/avialDialect.h"
#include "includes/avialOps.h"
#include "includes/avialTypes.h"

#include "mlir/Dialect/DLTI/DLTI.h"
#include "mlir/IR/Builders.h"

#include <string>

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
                mlir::OpBuilder builder(context);

                module->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op)
                {
                    if (mlir::isa<mlir::func::FuncOp>(op))
                    {

                        auto funcOp = llvm::dyn_cast<mlir::func::FuncOp>(op);
                        
                        // auto archAttr = builder.getStringAttr("arch");
                        // auto archVal = builder.getStringAttr("sm_90");
                        // auto entry1 = mlir::DataLayoutEntryAttr::get(archAttr, archVal);
                        // auto targetDlti = mlir::TargetDeviceSpecAttr::get(context, {entry1});

                        // auto cpu = builder.create<avial::TargetOp>(builder.getUnknownLoc(), avial::TargetRefType::get(builder.getContext(), "CPU"), "CPU", "0", targetDlti);
                        // mlir::TargetDeviceSpecAttr tar =  mlir::dyn_cast<mlir::TargetDeviceSpecAttr>(cpu->getAttr("dlti"));
                        
                        // auto mapAttr = tar.getSpecForIdentifier(builder.getStringAttr("arch"));
                        // mapAttr.getValue().dump();
                        

                       
                       

                        
                        if (auto attr = funcOp->getAttrOfType<mlir::StringAttr>("sym_name"))
                        {
                            if(attr.getValue().str().find("cpu") != std::string::npos)
                            {
                                llvm::outs() << "Found a CPU Task\n";
                            }
                            
                            else if(attr.getValue().str().find("gpu") != std::string::npos)
                            {
                                llvm::outs() << "Found a GPU Task\n";
                            }

                            else 
                            {
                                llvm::outs() << "Unknown Type of Task\n";
                            }
                            
                        }
                            // op->dumpPretty();

                            // Take Every Functions.
                            // Check if we have CPU_ or GPU_
                            // If we don;t have, emit the same IR.
                            // If we have any functions like that, distribute it!
                    }

                   

                });
                

            
            }
            };
        }

    }

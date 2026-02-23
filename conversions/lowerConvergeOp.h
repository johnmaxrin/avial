#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "mlir/Conversion/Passes.h"
#include "includes/avialDialect.h"
#include "includes/avialTypes.h"
#include "includes/utils.h"
#include "analysis/arrayPartitionAnalysis.h"
#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/Arith/IR/Arith.h"
#include "mlir/Dialect/LLVMIR/LLVMDialect.h"
#include "mlir/Dialect/OpenMP/OpenMPDialect.h"

using namespace mlir;

struct ConvertConvergeOp : public OpConversionPattern<mlir::avial::ConvergeOp>
{
    using OpConversionPattern::OpConversionPattern;
    
    LogicalResult matchAndRewrite(
        mlir::avial::ConvergeOp op, OpAdaptor adaptor,
        ConversionPatternRewriter &rewriter) const override
    {
        llvm::errs() << "---- Processing ConvergeOp ----\n";
        
        // Collect all TaskOps in the ConvergeOp's body
        llvm::SmallVector<mlir::avial::TaskOp> allTasks;
        
        op.getBodyRegion().walk([&](mlir::avial::TaskOp taskOp) {
            allTasks.push_back(taskOp);
        });
        
        if (allTasks.empty()) {
            llvm::errs() << "No TaskOps found in ConvergeOp\n";
        } else {
            llvm::errs() << "Found " << allTasks.size() << " TaskOps\n";
            
            // Find the highest repId among all tasks
            int64_t maxRepId = -1;
            
            for (auto taskOp : allTasks) {
                auto repIdAttr = taskOp->getAttrOfType<mlir::IntegerAttr>("repId");
                if (repIdAttr) {
                    int64_t repId = repIdAttr.getInt();
                    if (repId > maxRepId) {
                        maxRepId = repId;
                    }
                }
            }
            
            if (maxRepId >= 0) {
                llvm::errs() << "Highest repId found: " << maxRepId << "\n";
                
                // Find all tasks with the highest repId and set needBroadcast to true
                int taskCount = 0;
                for (auto taskOp : allTasks) {
                    auto repIdAttr = taskOp->getAttrOfType<mlir::IntegerAttr>("repId");
                    if (repIdAttr && repIdAttr.getInt() == maxRepId) {
                        auto needBroadcastAttr = taskOp->getAttrOfType<mlir::BoolAttr>("needBroadcast");
                        bool currentNeedBroadcast = needBroadcastAttr ? needBroadcastAttr.getValue() : false;
                        
                        auto nameAttr = taskOp->getAttrOfType<mlir::StringAttr>("name");
                        std::string taskName = nameAttr ? nameAttr.getValue().str() : "<unnamed>";
                        
                        if (!currentNeedBroadcast) {
                            llvm::errs() << "Setting needBroadcast=true for TaskOp '" 
                                         << taskName << "' (repId=" << maxRepId << ")\n";
                            taskOp->setAttr("needBroadcast", rewriter.getBoolAttr(true));
                            taskCount++;
                        } else {
                            llvm::errs() << "TaskOp '" << taskName 
                                         << "' (repId=" << maxRepId << ") already has needBroadcast=true\n";
                        }
                    }
                }
                
                llvm::errs() << "Updated " << taskCount << " TaskOps with repId=" << maxRepId << "\n";
            } else {
                llvm::errs() << "No valid repId found in any TaskOp\n";
            }
        }
        
        // Inline the ConvergeOp's body operations into the parent block
        Block *convergeBlock = &op.getBodyRegion().front();
        Block *parentBlock = op->getBlock();
        
        // Get the terminator (YieldOp) from the ConvergeOp's block
        Operation *terminator = convergeBlock->getTerminator();
        
        llvm::errs() << "Inlining ConvergeOp body into parent block\n";
        
        // Move all operations except the terminator before the ConvergeOp
        rewriter.setInsertionPoint(op);
        auto &operations = convergeBlock->getOperations();
        while (!operations.empty() && &operations.front() != terminator) {
            Operation *opToMove = &operations.front();
            opToMove->moveBefore(op);
        }
        
        llvm::errs() << "Erasing ConvergeOp scaffolding\n";
        
        // Erase the ConvergeOp
        rewriter.eraseOp(op);
        
        llvm::errs() << "---- End Processing ConvergeOp ----\n";
        
        return success();
    }
};

namespace mlir
{
    namespace avial
    {
        #define GEN_PASS_DEF_LOWERCONVERGEOPPASS
        #include "dialect/Passes.h.inc"
        
        struct LowerConvergeOpPass
            : public mlir::avial::impl::LowerConvergeOpPassBase<LowerConvergeOpPass>
        {
            using LowerConvergeOpPassBase::LowerConvergeOpPassBase;
            
            void runOnOperation() override
            {
                mlir::MLIRContext *context = &getContext();
                auto *module = getOperation();
                
                ConversionTarget targetReplicateOp(getContext());
                targetReplicateOp.addLegalDialect<mlir::arith::ArithDialect>();
                targetReplicateOp.addLegalDialect<mlir::scf::SCFDialect>();
                targetReplicateOp.addLegalDialect<mlir::affine::AffineDialect>();
                targetReplicateOp.addLegalOp<mlir::avial::TaskOp>();
                targetReplicateOp.addLegalOp<mlir::avial::YieldOp>();
                targetReplicateOp.addLegalOp<mlir::avial::ScheduleOp>();
                targetReplicateOp.addLegalDialect<mlir::memref::MemRefDialect>();
                
                // Mark ConvergeOp as illegal - it should be removed
                targetReplicateOp.addIllegalOp<mlir::avial::ConvergeOp>();
                
                RewritePatternSet avialpatterns(context);
                avialpatterns.add<ConvertConvergeOp>(context);
                
                if (failed(applyPartialConversion(module, targetReplicateOp, std::move(avialpatterns))))
                {
                    signalPassFailure();
                }
            }
        };
    }
}
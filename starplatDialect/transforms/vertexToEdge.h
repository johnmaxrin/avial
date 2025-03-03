#include "mlir/Conversion/Passes.h"
#include "mlir/Pass/PassManager.h"

#include "includes/StarPlatDialect.h"



namespace mlir
{
    namespace starplat
    {
#define GEN_PASS_DEF_VERTEXTOEDGE
#include "tblgen2/Passes.h.inc"

        struct VertexToEdge : public mlir::starplat::impl::VertexToEdgeBase<VertexToEdge>
        {
            using VertexToEdgeBase::VertexToEdgeBase;

            /*
                TODOs
                1. Add checks for whether we are traversing all the nodes in a gprah g.
            */

            void runOnOperation() override
            {
                auto mod = getOperation();
                mod->walk<mlir::WalkOrder::PreOrder>([&](mlir::Operation *op) {
                   if(llvm::isa<mlir::starplat::ForAllOp>(op))
                   {
                        auto attr = op->getAttr("loopattributes");
                        if(attr)
                        {
                            if(auto arrAttr = attr.dyn_cast<mlir::ArrayAttr>())
                            {
                                for(auto attrElm : arrAttr)
                                {
                                    if(auto strAttr = attrElm.dyn_cast<mlir::StringAttr>())
                                    {
                                        if(strAttr.getValue() == "nodes")
                                        {
                                            llvm::outs() << "We have a forall loop which iterates over all the nodes.\n";
                                            op->walk<mlir::WalkOrder::PreOrder>([&](mlir::starplat::ForAllOp op)
                                            {
                                                auto nbrAttr = op->getAttr("loopattributes");
                                                if(nbrAttr)
                                                {
                                                    if(auto nbrArrAttr = nbrAttr.dyn_cast<mlir::ArrayAttr>())
                                                    {
                                                        for(auto nbrAttrElm : nbrArrAttr)

                                                        if(auto nbrStrAttr = nbrAttrElm.dyn_cast<mlir::StringAttr>())
                                                        {
                                                            if(nbrStrAttr.getValue() == "neighbours")
                                                            {
                                                                llvm::outs() << "We have another forall loop which iterates over all neighbours of a node.\n";
                                                                llvm::outs() << "Vertex to edge transformation is feasible.\n";
                                                            }
                                                        }
                                                    }
                                                }

                                            });


                                        }
                                    }
                                }

                            }
                        }

                        
                   }

                });

                llvm::outs() << "Finished Vertex to Edge Transform\n";
            }
        };

    }
}

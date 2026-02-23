#ifndef BROADCAST_ANALYSIS_H
#define BROADCAST_ANALYSIS_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/IR/SCF.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/BuiltinOps.h"
#include "llvm/Support/raw_ostream.h"
#include <vector>
#include <algorithm>
#include "arrayPartitionAnalysis.h"

#include "includes/avialOps.h"
#include "includes/avialDialect.h"


namespace mlir
{
    namespace avial
    {
    
        // ========================================================================
        // BROADCAST ANALYSIS
        // ========================================================================

        /// Structure to hold broadcast analysis results
        struct BroadcastInfo
        {
            Value memref;                    // The memref being analyzed
            bool needsBroadcast;             // Whether broadcast is needed
            std::string reason;              // Reason for the decision
            ArrayPartitioningInfo partInfo;  // Partitioning info from subsequent usage
            
        };

        /// Helper class for broadcast analysis
        class BroadcastAnalysis
        {
        public:
            BroadcastAnalysis(mlir::Operation *replicateOp) : replicateOp(replicateOp) {}

            /// Perform the broadcast analysis
            bool analyze(std::vector<BroadcastInfo> &results)
            {
                results.clear();

                // Get all write arguments from this replicate operation

                llvm::SmallVector<Value> writeArgs = mlir::dyn_cast<mlir::avial::ReplicateOp>(replicateOp).getWrites();

                if (writeArgs.empty()) {
                    llvm::errs() << "No write arguments found in replicate operation\n";
                    return true; // Not an error, just nothing to analyze
                }

                llvm::errs() << "\n=== Broadcast Analysis ===\n";
                llvm::errs() << "Analyzing " << writeArgs.size() << " write arguments\n";

                // For each write argument, check if it needs broadcasting
                for (Value writeArg : writeArgs) {
                    BroadcastInfo info;
                    info.memref = writeArg;
                    info.needsBroadcast = false;
                    info.reason = "No subsequent usage found";

                    llvm::errs() << "\n--- Analyzing write argument ---\n";

                    // Find subsequent replicate operations that read this output
                    llvm::SmallVector<mlir::Operation *> subsequentReplicates = 
                        findSubsequentReplicates(writeArg);

                    if (subsequentReplicates.empty()) {
                        llvm::errs() << "  No subsequent replicate operations found\n";
                        info.reason = "No subsequent replicate operations use this output";
                        results.push_back(info);
                        continue;
                    }

                    llvm::errs() << "  Found " << subsequentReplicates.size() 
                                << " subsequent replicate(s)\n";

                    // Analyze the first subsequent replicate that uses this output
                    // (You can extend this to analyze all of them if needed)
                    mlir::Operation *nextReplicate = subsequentReplicates[0];

                    // Use the existing partitioning analysis to determine if the 
                    // subsequent replicate needs partitioning for this memref
                    ArrayPartitioningInfo partInfo = 
                        analyzeArrayForPartitioning(nextReplicate, writeArg);

                    info.partInfo = partInfo;

                    // Determine if broadcast is needed based on partitioning strategy
                    if (needsBroadcast(partInfo)) {
                        info.needsBroadcast = true;
                        info.reason = "Subsequent replicate needs NO_PARTITION (replicate/broadcast)";
                        llvm::errs() << "  ✓ BROADCAST NEEDED: " << info.reason << "\n";
                    } else {
                        info.needsBroadcast = false;
                        
                        if (partInfo.strategy == ArrayPartitioningInfo::ROW_PARTITION) {
                            info.reason = "Subsequent replicate uses ROW_PARTITION (no broadcast)";
                        } else if (partInfo.strategy == ArrayPartitioningInfo::COL_PARTITION) {
                            info.reason = "Subsequent replicate uses COL_PARTITION (no broadcast)";
                        } else {
                            info.reason = "Partitioning strategy allows direct usage";
                        }
                        
                        llvm::errs() << "  ✗ NO BROADCAST: " << info.reason << "\n";
                    }

                    results.push_back(info);
                }

                llvm::errs() << "\n=== Analysis Complete ===\n";
                llvm::errs() << "Total decisions: " << results.size() << "\n";
                int broadcastCount = 0;
                for (const auto &info : results) {
                    if (info.needsBroadcast) broadcastCount++;
                }
                llvm::errs() << "Broadcast needed for: " << broadcastCount << " outputs\n\n";

                return true;
            }

        private:
            mlir::Operation *replicateOp;

            // Find subsequent replicate operations that use the given memref
            llvm::SmallVector<mlir::Operation *> findSubsequentReplicates(Value memref)
            {
                llvm::SmallVector<mlir::Operation *> result;

                // Get the parent operation (e.g., function, module)
                mlir::Operation *parentOp = replicateOp->getParentOp();
                if (!parentOp)
                    return result;

                bool foundCurrentReplicate = false;

                // Walk through all operations in the parent
                
                parentOp->walk([&](mlir::avial::ReplicateOp op) {
                    // Skip until we find the current replicate operation
                    if (op == replicateOp) {
                        foundCurrentReplicate = true;
                        return;
                    }

                    // Only look at operations after the current replicate
                    if (!foundCurrentReplicate)
                        return;

                    // Check if this operation is a replicate that reads our memref
                    if (isReadByReplicate(op, memref)) {
                        result.push_back(op);
                    }
                });

                return result;
            }

            // Check if a memref is read by a replicate operation
            bool isReadByReplicate(mlir::Operation *replicate, Value memref)
            {
                llvm::SmallVector<Value> readArgs = mlir::dyn_cast<mlir::avial::ReplicateOp>(replicate).getReads(); 
                llvm::errs() << "Memref: ";
                memref.dump();
                for (Value readArg : readArgs) {
                    readArg.dump();
                    if (readArg == memref)
                        return true;
                }

                llvm::errs() << "\n";
                llvm::errs() << "\n";
                return false;
            }



            // Determine if broadcast is needed based on partitioning strategy
            bool needsBroadcast(const ArrayPartitioningInfo &partInfo)
            {
                // If the subsequent replicate needs NO_PARTITION (replicate strategy),
                // then we need to broadcast the data so all nodes get the processed data
                return partInfo.strategy == ArrayPartitioningInfo::NO_PARTITION;
            }
        };

        /// Analyzes whether outputs of a replicate operation need broadcasting
        /// based on how they are used in subsequent replicate operations.
        ///
        /// @param replicateOp The replicate operation to analyze
        /// @param broadcastDecisions Output vector of broadcast decisions for each write argument
        /// @return true if analysis was successful, false otherwise
        inline bool analyzeBroadcastRequirements(mlir::Operation *replicateOp,
                                                std::vector<BroadcastInfo> &broadcastDecisions)
        {
            BroadcastAnalysis analysis(replicateOp);
            return analysis.analyze(broadcastDecisions);
        }

        /// Helper function: Check if a specific output needs broadcasting
        inline bool doesOutputNeedBroadcast(mlir::Operation *replicateOp, Value outputMemref)
        {
            std::vector<BroadcastInfo> broadcastDecisions;
            
            if (!analyzeBroadcastRequirements(replicateOp, broadcastDecisions)) {
                return false; // Default to no broadcast on error
            }

            // Find the decision for this specific memref
            for (const BroadcastInfo &info : broadcastDecisions) {
                if (info.memref == outputMemref) {
                    return info.needsBroadcast;
                }
            }

            return false; // Not found, default to no broadcast
        }

    } // namespace avial
} // namespace mlir

/*
 * =============================================================================
 * USAGE EXAMPLE
 * =============================================================================
 *
 * #include "BroadcastAnalysis.h"
 *
 * void processReplicateOp(mlir::Operation *replicateOp) {
 *     std::vector<mlir::avial::BroadcastInfo> broadcastDecisions;
 *     
 *     // Analyze the replicate operation
 *     if (!mlir::avial::analyzeBroadcastRequirements(replicateOp, broadcastDecisions)) {
 *         llvm::errs() << "Broadcast analysis failed!\n";
 *         return;
 *     }
 *     
 *     // Process each output
 *     for (const auto &info : broadcastDecisions) {
 *         if (info.needsBroadcast) {
 *             llvm::errs() << "Output needs broadcast: " << info.reason << "\n";
 *             // Insert broadcast operation
 *             insertBroadcast(info.memref);
 *         } else {
 *             llvm::errs() << "No broadcast needed: " << info.reason << "\n";
 *             // Setup partitioned transfer
 *             setupPartitionedTransfer(info.memref, info.partInfo);
 *         }
 *     }
 * }
 *
 *
 * =============================================================================
 * HOW IT WORKS
 * =============================================================================
 *
 * 1. Extracts all write arguments (outputs) from the replicate operation
 * 2. For each output:
 *    a. Finds subsequent replicate operations that read this output
 *    b. Uses analyzeArrayForPartitioning() to check partitioning requirement
 *    c. If NO_PARTITION → broadcast needed (all nodes need full data)
 *    d. If ROW_PARTITION or COL_PARTITION → no broadcast (data distributed)
 * 3. Returns vector of BroadcastInfo with decisions and reasons
 *
 * =============================================================================
 */

#endif // BROADCAST_ANALYSIS_H
//===- MergeFunctions.h - Merge Identical Functions -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This pass transforms simple global variables that never have their address
// taken.  If obviously true, it marks read/write globals as constant, deletes
// variables only stored to, etc.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_TRANSFORMS_IPO_MERGEFUNCTIONS_H
#define LLVM_TRANSFORMS_IPO_MERGEFUNCTIONS_H

#include "llvm/IR/PassManager.h"
#include "llvm/Support/Compiler.h"

namespace llvm {

class Module;
class Function;

/// Merge identical functions.
class MergeFunctionsPass : public PassInfoMixin<MergeFunctionsPass> {
public:
  LLVM_ABI PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);

  LLVM_ABI static bool runOnModule(Module &M);
  LLVM_ABI static DenseMap<Function *, Function *>
  runOnFunctions(ArrayRef<Function *> F);
};

} // end namespace llvm

#endif // LLVM_TRANSFORMS_IPO_MERGEFUNCTIONS_H

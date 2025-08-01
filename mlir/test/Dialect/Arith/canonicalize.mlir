// RUN: mlir-opt %s -canonicalize="test-convergence" --split-input-file | FileCheck %s

// CHECK-LABEL: @select_same_val
//       CHECK:   return %arg1
func.func @select_same_val(%arg0: i1, %arg1: i64) -> i64 {
  %0 = arith.select %arg0, %arg1, %arg1 : i64
  return %0 : i64
}

// CHECK-LABEL: @select_cmp_eq_select
//       CHECK:   return %arg1
func.func @select_cmp_eq_select(%arg0: i64, %arg1: i64) -> i64 {
  %0 = arith.cmpi eq, %arg0, %arg1 : i64
  %1 = arith.select %0, %arg0, %arg1 : i64
  return %1 : i64
}

// CHECK-LABEL: @select_cmp_ne_select
//       CHECK:   return %arg0
func.func @select_cmp_ne_select(%arg0: i64, %arg1: i64) -> i64 {
  %0 = arith.cmpi ne, %arg0, %arg1 : i64
  %1 = arith.select %0, %arg0, %arg1 : i64
  return %1 : i64
}

// CHECK-LABEL: @select_extui
//       CHECK:   %[[res:.+]] = arith.extui %arg0 : i1 to i64
//       CHECK:   return %[[res]]
func.func @select_extui(%arg0: i1) -> i64 {
  %c0_i64 = arith.constant 0 : i64
  %c1_i64 = arith.constant 1 : i64
  %res = arith.select %arg0, %c1_i64, %c0_i64 : i64
  return %res : i64
}

// CHECK-LABEL: @select_extui2
// CHECK-DAG:  %true = arith.constant true
// CHECK-DAG:  %[[xor:.+]] = arith.xori %arg0, %true : i1
// CHECK-DAG:  %[[res:.+]] = arith.extui %[[xor]] : i1 to i64
//       CHECK:   return %[[res]]
func.func @select_extui2(%arg0: i1) -> i64 {
  %c0_i64 = arith.constant 0 : i64
  %c1_i64 = arith.constant 1 : i64
  %res = arith.select %arg0, %c0_i64, %c1_i64 : i64
  return %res : i64
}

// CHECK-LABEL: @select_extui_i1
//  CHECK-NEXT:   return %arg0
func.func @select_extui_i1(%arg0: i1) -> i1 {
  %c0_i1 = arith.constant false
  %c1_i1 = arith.constant true
  %res = arith.select %arg0, %c1_i1, %c0_i1 : i1
  return %res : i1
}

// CHECK-LABEL: @select_no_fold_ui1
//       CHECK:  %[[CONST_0:.+]] = "test.constant"() <{value = 0 : i32}> : () -> ui1
//       CHECK:  %[[CONST_1:.+]] = "test.constant"() <{value = 1 : i32}> : () -> ui1
//  CHECK-NEXT:  %[[RES:.+]] = arith.select %arg0, %[[CONST_1]], %[[CONST_0]] : ui1
//  CHECK-NEXT:   return %[[RES]]
func.func @select_no_fold_ui1(%arg0: i1) -> ui1 {
  %c0_i1 = "test.constant"() {value = 0 : i32} : () -> ui1
  %c1_i1 = "test.constant"() {value = 1 : i32} : () -> ui1
  %res = arith.select %arg0, %c1_i1, %c0_i1 : ui1
  return %res : ui1
}

// CHECK-LABEL: @select_cst_false_scalar
//  CHECK-SAME:   (%[[ARG0:.+]]: i32, %[[ARG1:.+]]: i32)
//  CHECK-NEXT:   return %[[ARG1]]
func.func @select_cst_false_scalar(%arg0: i32, %arg1: i32) -> i32 {
  %false = arith.constant false
  %res = arith.select %false, %arg0, %arg1 : i32
  return %res : i32
}

// CHECK-LABEL: @select_cst_true_scalar
//  CHECK-SAME:   (%[[ARG0:.+]]: i32, %[[ARG1:.+]]: i32)
//  CHECK-NEXT:   return %[[ARG0]]
func.func @select_cst_true_scalar(%arg0: i32, %arg1: i32) -> i32 {
  %true = arith.constant true
  %res = arith.select %true, %arg0, %arg1 : i32
  return %res : i32
}

// CHECK-LABEL: @select_cst_true_splat
//       CHECK:   %[[A:.+]] = arith.constant dense<[1, 2, 3]> : vector<3xi32>
//  CHECK-NEXT:   return %[[A]]
func.func @select_cst_true_splat() -> vector<3xi32> {
  %cond = arith.constant dense<true> : vector<3xi1>
  %a = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %b = arith.constant dense<[4, 5, 6]> : vector<3xi32>
  %res = arith.select %cond, %a, %b : vector<3xi1>, vector<3xi32>
  return %res : vector<3xi32>
}

// CHECK-LABEL: @select_cst_vector_i32
//       CHECK:   %[[RES:.+]] = arith.constant dense<[1, 5, 3]> : vector<3xi32>
//  CHECK-NEXT:   return %[[RES]]
func.func @select_cst_vector_i32() -> vector<3xi32> {
  %cond = arith.constant dense<[true, false, true]> : vector<3xi1>
  %a = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %b = arith.constant dense<[4, 5, 6]> : vector<3xi32>
  %res = arith.select %cond, %a, %b : vector<3xi1>, vector<3xi32>
  return %res : vector<3xi32>
}

// CHECK-LABEL: @select_cst_vector_f32
//       CHECK:   %[[RES:.+]] = arith.constant dense<[4.000000e+00, 2.000000e+00, 6.000000e+00]> : vector<3xf32>
//  CHECK-NEXT:   return %[[RES]]
func.func @select_cst_vector_f32() -> vector<3xf32> {
  %cond = arith.constant dense<[false, true, false]> : vector<3xi1>
  %a = arith.constant dense<[1.0, 2.0, 3.0]> : vector<3xf32>
  %b = arith.constant dense<[4.0, 5.0, 6.0]> : vector<3xf32>
  %res = arith.select %cond, %a, %b : vector<3xi1>, vector<3xf32>
  return %res : vector<3xf32>
}

// CHECK-LABEL: @selToNot
//       CHECK:       %[[trueval:.+]] = arith.constant true
//       CHECK:       %[[res:.+]] = arith.xori %arg0, %[[trueval]] : i1
//       CHECK:   return %[[res]]
func.func @selToNot(%arg0: i1) -> i1 {
  %true = arith.constant true
  %false = arith.constant false
  %res = arith.select %arg0, %false, %true : i1
  return %res : i1
}

// CHECK-LABEL: @redundantSelectTrue
//       CHECK-NEXT: %[[res:.+]] = arith.select %arg0, %arg1, %arg3
//       CHECK-NEXT: return %[[res]]
func.func @redundantSelectTrue(%arg0: i1, %arg1 : i32, %arg2 : i32, %arg3 : i32) -> i32 {
  %0 = arith.select %arg0, %arg1, %arg2 : i32
  %res = arith.select %arg0, %0, %arg3 : i32
  return %res : i32
}

// CHECK-LABEL: @redundantSelectFalse
//       CHECK-NEXT: %[[res:.+]] = arith.select %arg0, %arg3, %arg2
//       CHECK-NEXT: return %[[res]]
func.func @redundantSelectFalse(%arg0: i1, %arg1 : i32, %arg2 : i32, %arg3 : i32) -> i32 {
  %0 = arith.select %arg0, %arg1, %arg2 : i32
  %res = arith.select %arg0, %arg3, %0 : i32
  return %res : i32
}

// CHECK-LABEL: @selNotCond
//       CHECK-NEXT: %[[res1:.+]] = arith.select %arg0, %arg2, %arg1
//       CHECK-NEXT: %[[res2:.+]] = arith.select %arg0, %arg4, %arg3
//       CHECK-NEXT: return %[[res1]], %[[res2]]
func.func @selNotCond(%arg0: i1, %arg1 : i32, %arg2 : i32, %arg3 : i32, %arg4 : i32) -> (i32, i32) {
  %one = arith.constant 1 : i1
  %cond1 = arith.xori %arg0, %one : i1
  %cond2 = arith.xori %one, %arg0 : i1

  %res1 = arith.select %cond1, %arg1, %arg2 : i32
  %res2 = arith.select %cond2, %arg3, %arg4 : i32
  return %res1, %res2 : i32, i32
}

// CHECK-LABEL: @cmpiI1eq
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK: return %[[ARG]]
func.func @cmpiI1eq(%arg0: i1) -> i1 {
  %one = arith.constant 1 : i1
  %res = arith.cmpi eq, %arg0, %one : i1
  return %res : i1
}

// CHECK-LABEL: @cmpiI1eqVec
//  CHECK-SAME: (%[[ARG:.*]]: vector<4xi1>)
//       CHECK: return %[[ARG]]
func.func @cmpiI1eqVec(%arg0: vector<4xi1>) -> vector<4xi1> {
  %one = arith.constant dense<1> : vector<4xi1>
  %res = arith.cmpi eq, %arg0, %one : vector<4xi1>
  return %res : vector<4xi1>
}

// CHECK-LABEL: @cmpiI1ne
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK: return %[[ARG]]
func.func @cmpiI1ne(%arg0: i1) -> i1 {
  %zero = arith.constant 0 : i1
  %res = arith.cmpi ne, %arg0, %zero : i1
  return %res : i1
}

// CHECK-LABEL: @cmpiI1neVec
//  CHECK-SAME: (%[[ARG:.*]]: vector<4xi1>)
//       CHECK: return %[[ARG]]
func.func @cmpiI1neVec(%arg0: vector<4xi1>) -> vector<4xi1> {
  %zero = arith.constant dense<0> : vector<4xi1>
  %res = arith.cmpi ne, %arg0, %zero : vector<4xi1>
  return %res : vector<4xi1>
}

// CHECK-LABEL: @cmpiI1eqLhs
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK: return %[[ARG]]
func.func @cmpiI1eqLhs(%arg0: i1) -> i1 {
  %one = arith.constant 1 : i1
  %res = arith.cmpi eq, %one, %arg0  : i1
  return %res : i1
}

// CHECK-LABEL: @cmpiI1eqVecLhs
//  CHECK-SAME: (%[[ARG:.*]]: vector<4xi1>)
//       CHECK: return %[[ARG]]
func.func @cmpiI1eqVecLhs(%arg0: vector<4xi1>) -> vector<4xi1> {
  %one = arith.constant dense<1> : vector<4xi1>
  %res = arith.cmpi eq, %one, %arg0 : vector<4xi1>
  return %res : vector<4xi1>
}

// CHECK-LABEL: @cmpiI1neLhs
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK: return %[[ARG]]
func.func @cmpiI1neLhs(%arg0: i1) -> i1 {
  %zero = arith.constant 0 : i1
  %res = arith.cmpi ne, %zero, %arg0 : i1
  return %res : i1
}

// CHECK-LABEL: @cmpiI1neVecLhs
//  CHECK-SAME: (%[[ARG:.*]]: vector<4xi1>)
//       CHECK: return %[[ARG]]
func.func @cmpiI1neVecLhs(%arg0: vector<4xi1>) -> vector<4xi1> {
  %zero = arith.constant dense<0> : vector<4xi1>
  %res = arith.cmpi ne, %zero, %arg0 : vector<4xi1>
  return %res : vector<4xi1>
}

// Test case: Folding of comparisons with equal operands.
// CHECK-LABEL: @cmpi_equal_operands
//   CHECK-DAG:   %[[T:.*]] = arith.constant true
//   CHECK-DAG:   %[[F:.*]] = arith.constant false
//       CHECK:   return %[[T]], %[[T]], %[[T]], %[[T]], %[[T]],
//  CHECK-SAME:          %[[F]], %[[F]], %[[F]], %[[F]], %[[F]]
func.func @cmpi_equal_operands(%arg0: i64)
    -> (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) {
  %0 = arith.cmpi eq, %arg0, %arg0 : i64
  %1 = arith.cmpi sle, %arg0, %arg0 : i64
  %2 = arith.cmpi sge, %arg0, %arg0 : i64
  %3 = arith.cmpi ule, %arg0, %arg0 : i64
  %4 = arith.cmpi uge, %arg0, %arg0 : i64
  %5 = arith.cmpi ne, %arg0, %arg0 : i64
  %6 = arith.cmpi slt, %arg0, %arg0 : i64
  %7 = arith.cmpi sgt, %arg0, %arg0 : i64
  %8 = arith.cmpi ult, %arg0, %arg0 : i64
  %9 = arith.cmpi ugt, %arg0, %arg0 : i64
  return %0, %1, %2, %3, %4, %5, %6, %7, %8, %9
      : i1, i1, i1, i1, i1, i1, i1, i1, i1, i1
}

// Test case: Folding of comparisons with equal vector operands.
// CHECK-LABEL: @cmpi_equal_vector_operands
//   CHECK-DAG:   %[[T:.*]] = arith.constant dense<true>
//   CHECK-DAG:   %[[F:.*]] = arith.constant dense<false>
//       CHECK:   return %[[T]], %[[T]], %[[T]], %[[T]], %[[T]],
//  CHECK-SAME:          %[[F]], %[[F]], %[[F]], %[[F]], %[[F]]
func.func @cmpi_equal_vector_operands(%arg0: vector<1x8xi64>)
    -> (vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>,
        vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>,
	vector<1x8xi1>, vector<1x8xi1>) {
  %0 = arith.cmpi eq, %arg0, %arg0 : vector<1x8xi64>
  %1 = arith.cmpi sle, %arg0, %arg0 : vector<1x8xi64>
  %2 = arith.cmpi sge, %arg0, %arg0 : vector<1x8xi64>
  %3 = arith.cmpi ule, %arg0, %arg0 : vector<1x8xi64>
  %4 = arith.cmpi uge, %arg0, %arg0 : vector<1x8xi64>
  %5 = arith.cmpi ne, %arg0, %arg0 : vector<1x8xi64>
  %6 = arith.cmpi slt, %arg0, %arg0 : vector<1x8xi64>
  %7 = arith.cmpi sgt, %arg0, %arg0 : vector<1x8xi64>
  %8 = arith.cmpi ult, %arg0, %arg0 : vector<1x8xi64>
  %9 = arith.cmpi ugt, %arg0, %arg0 : vector<1x8xi64>
  return %0, %1, %2, %3, %4, %5, %6, %7, %8, %9
      : vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>,
        vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>, vector<1x8xi1>,
	vector<1x8xi1>, vector<1x8xi1>
}

// -----

// Test case: Move constant to the right side.
// CHECK-LABEL: @cmpi_const_right(
//  CHECK-SAME: %[[ARG:.*]]:
//       CHECK:   %[[C:.*]] = arith.constant 1 : i64
//       CHECK:   %[[R0:.*]] = arith.cmpi eq, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R1:.*]] = arith.cmpi sge, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R2:.*]] = arith.cmpi sle, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R3:.*]] = arith.cmpi uge, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R4:.*]] = arith.cmpi ule, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R5:.*]] = arith.cmpi ne, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R6:.*]] = arith.cmpi sgt, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R7:.*]] = arith.cmpi slt, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R8:.*]] = arith.cmpi ugt, %[[ARG]], %[[C]] : i64
//       CHECK:   %[[R9:.*]] = arith.cmpi ult, %[[ARG]], %[[C]] : i64
//       CHECK:   return %[[R0]], %[[R1]], %[[R2]], %[[R3]], %[[R4]],
//  CHECK-SAME:          %[[R5]], %[[R6]], %[[R7]], %[[R8]], %[[R9]]
func.func @cmpi_const_right(%arg0: i64)
    -> (i1, i1, i1, i1, i1, i1, i1, i1, i1, i1) {
  %c1 = arith.constant 1 : i64
  %0 = arith.cmpi eq, %c1, %arg0 : i64
  %1 = arith.cmpi sle, %c1, %arg0 : i64
  %2 = arith.cmpi sge, %c1, %arg0 : i64
  %3 = arith.cmpi ule, %c1, %arg0 : i64
  %4 = arith.cmpi uge, %c1, %arg0 : i64
  %5 = arith.cmpi ne, %c1, %arg0 : i64
  %6 = arith.cmpi slt, %c1, %arg0 : i64
  %7 = arith.cmpi sgt, %c1, %arg0 : i64
  %8 = arith.cmpi ult, %c1, %arg0 : i64
  %9 = arith.cmpi ugt, %c1, %arg0 : i64
  return %0, %1, %2, %3, %4, %5, %6, %7, %8, %9
      : i1, i1, i1, i1, i1, i1, i1, i1, i1, i1
}

// -----

// CHECK-LABEL: @cmpOfExtSI(
//  CHECK-NEXT:   return %arg0
func.func @cmpOfExtSI(%arg0: i1) -> i1 {
  %ext = arith.extsi %arg0 : i1 to i64
  %c0 = arith.constant 0 : i64
  %res = arith.cmpi ne, %ext, %c0 : i64
  return %res : i1
}

// CHECK-LABEL: @cmpOfExtUI(
//  CHECK-NEXT:   return %arg0
func.func @cmpOfExtUI(%arg0: i1) -> i1 {
  %ext = arith.extui %arg0 : i1 to i64
  %c0 = arith.constant 0 : i64
  %res = arith.cmpi ne, %ext, %c0 : i64
  return %res : i1
}

// -----

// CHECK-LABEL: @cmpOfExtSIVector(
//  CHECK-NEXT:   return %arg0
func.func @cmpOfExtSIVector(%arg0: vector<4xi1>) -> vector<4xi1> {
  %ext = arith.extsi %arg0 : vector<4xi1> to vector<4xi64>
  %c0 = arith.constant dense<0> : vector<4xi64>
  %res = arith.cmpi ne, %ext, %c0 : vector<4xi64>
  return %res : vector<4xi1>
}

// CHECK-LABEL: @cmpOfExtUIVector(
//  CHECK-NEXT:   return %arg0
func.func @cmpOfExtUIVector(%arg0: vector<4xi1>) -> vector<4xi1> {
  %ext = arith.extui %arg0 : vector<4xi1> to vector<4xi64>
  %c0 = arith.constant dense<0> : vector<4xi64>
  %res = arith.cmpi ne, %ext, %c0 : vector<4xi64>
  return %res : vector<4xi1>
}

// -----

// CHECK-LABEL: @extSIOfExtUI
//       CHECK:   %[[res:.+]] = arith.extui %arg0 : i1 to i64
//       CHECK:   return %[[res]]
func.func @extSIOfExtUI(%arg0: i1) -> i64 {
  %ext1 = arith.extui %arg0 : i1 to i8
  %ext2 = arith.extsi %ext1 : i8 to i64
  return %ext2 : i64
}

// CHECK-LABEL: @extUIOfExtUI
//       CHECK:   %[[res:.+]] = arith.extui %arg0 : i1 to i64
//       CHECK:   return %[[res]]
func.func @extUIOfExtUI(%arg0: i1) -> i64 {
  %ext1 = arith.extui %arg0 : i1 to i8
  %ext2 = arith.extui %ext1 : i8 to i64
  return %ext2 : i64
}

// CHECK-LABEL: @extSIOfExtSI
//       CHECK:   %[[res:.+]] = arith.extsi %arg0 : i1 to i64
//       CHECK:   return %[[res]]
func.func @extSIOfExtSI(%arg0: i1) -> i64 {
  %ext1 = arith.extsi %arg0 : i1 to i8
  %ext2 = arith.extsi %ext1 : i8 to i64
  return %ext2 : i64
}

// -----

// CHECK-LABEL: @cmpIExtSINE
//       CHECK:  %[[comb:.+]] = arith.cmpi ne, %arg0, %arg1 : i8
//       CHECK:   return %[[comb]]
func.func @cmpIExtSINE(%arg0: i8, %arg1: i8) -> i1 {
  %ext0 = arith.extsi %arg0 : i8 to i64
  %ext1 = arith.extsi %arg1 : i8 to i64
  %res = arith.cmpi ne, %ext0, %ext1 : i64
  return %res : i1
}

// CHECK-LABEL: @cmpIExtSIEQ
//       CHECK:  %[[comb:.+]] = arith.cmpi eq, %arg0, %arg1 : i8
//       CHECK:   return %[[comb]]
func.func @cmpIExtSIEQ(%arg0: i8, %arg1: i8) -> i1 {
  %ext0 = arith.extsi %arg0 : i8 to i64
  %ext1 = arith.extsi %arg1 : i8 to i64
  %res = arith.cmpi eq, %ext0, %ext1 : i64
  return %res : i1
}

// CHECK-LABEL: @cmpIExtUINE
//       CHECK:  %[[comb:.+]] = arith.cmpi ne, %arg0, %arg1 : i8
//       CHECK:   return %[[comb]]
func.func @cmpIExtUINE(%arg0: i8, %arg1: i8) -> i1 {
  %ext0 = arith.extui %arg0 : i8 to i64
  %ext1 = arith.extui %arg1 : i8 to i64
  %res = arith.cmpi ne, %ext0, %ext1 : i64
  return %res : i1
}

// CHECK-LABEL: @cmpIExtUIEQ
//       CHECK:  %[[comb:.+]] = arith.cmpi eq, %arg0, %arg1 : i8
//       CHECK:   return %[[comb]]
func.func @cmpIExtUIEQ(%arg0: i8, %arg1: i8) -> i1 {
  %ext0 = arith.extui %arg0 : i8 to i64
  %ext1 = arith.extui %arg1 : i8 to i64
  %res = arith.cmpi eq, %ext0, %ext1 : i64
  return %res : i1
}

// CHECK-LABEL: @cmpIFoldEQ
//       CHECK:  %[[res:.+]] = arith.constant dense<[true, true, false]> : vector<3xi1>
//       CHECK:   return %[[res]]
func.func @cmpIFoldEQ() -> vector<3xi1> {
  %lhs = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %rhs = arith.constant dense<[1, 2, 4]> : vector<3xi32>
  %res = arith.cmpi eq, %lhs, %rhs : vector<3xi32>
  return %res : vector<3xi1>
}

// CHECK-LABEL: @cmpIFoldNE
//       CHECK:  %[[res:.+]] = arith.constant dense<[false, false, true]> : vector<3xi1>
//       CHECK:   return %[[res]]
func.func @cmpIFoldNE() -> vector<3xi1> {
  %lhs = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %rhs = arith.constant dense<[1, 2, 4]> : vector<3xi32>
  %res = arith.cmpi ne, %lhs, %rhs : vector<3xi32>
  return %res : vector<3xi1>
}

// CHECK-LABEL: @cmpIFoldSGE
//       CHECK:  %[[res:.+]] = arith.constant dense<[true, true, false]> : vector<3xi1>
//       CHECK:   return %[[res]]
func.func @cmpIFoldSGE() -> vector<3xi1> {
  %lhs = arith.constant dense<2> : vector<3xi32>
  %rhs = arith.constant dense<[1, 2, 4]> : vector<3xi32>
  %res = arith.cmpi sge, %lhs, %rhs : vector<3xi32>
  return %res : vector<3xi1>
}

// CHECK-LABEL: @cmpIFoldULT
//       CHECK:  %[[res:.+]] = arith.constant dense<false> : vector<3xi1>
//       CHECK:   return %[[res]]
func.func @cmpIFoldULT() -> vector<3xi1> {
  %lhs = arith.constant dense<2> : vector<3xi32>
  %rhs = arith.constant dense<1> : vector<3xi32>
  %res = arith.cmpi ult, %lhs, %rhs : vector<3xi32>
  return %res : vector<3xi1>
}

// -----

// CHECK-LABEL: @andOfExtSI
//       CHECK:  %[[comb:.+]] = arith.andi %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extsi %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @andOfExtSI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extsi %arg0 : i8 to i64
  %ext1 = arith.extsi %arg1 : i8 to i64
  %res = arith.andi %ext0, %ext1 : i64
  return %res : i64
}

// CHECK-LABEL: @andOfExtUI
//       CHECK:  %[[comb:.+]] = arith.andi %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extui %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @andOfExtUI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extui %arg0 : i8 to i64
  %ext1 = arith.extui %arg1 : i8 to i64
  %res = arith.andi %ext0, %ext1 : i64
  return %res : i64
}

// CHECK-LABEL: @orOfExtSI
//       CHECK:  %[[comb:.+]] = arith.ori %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extsi %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @orOfExtSI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extsi %arg0 : i8 to i64
  %ext1 = arith.extsi %arg1 : i8 to i64
  %res = arith.ori %ext0, %ext1 : i64
  return %res : i64
}

// CHECK-LABEL: @orOfExtUI
//       CHECK:  %[[comb:.+]] = arith.ori %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extui %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @orOfExtUI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extui %arg0 : i8 to i64
  %ext1 = arith.extui %arg1 : i8 to i64
  %res = arith.ori %ext0, %ext1 : i64
  return %res : i64
}

// -----

// CHECK-LABEL: @indexCastOfSignExtend
//       CHECK:   %[[res:.+]] = arith.index_cast %arg0 : i8 to index
//       CHECK:   return %[[res]]
func.func @indexCastOfSignExtend(%arg0: i8) -> index {
  %ext = arith.extsi %arg0 : i8 to i16
  %idx = arith.index_cast %ext : i16 to index
  return %idx : index
}

// CHECK-LABEL: @indexCastUIOfUnsignedExtend
//       CHECK:   %[[res:.+]] = arith.index_castui %arg0 : i8 to index
//       CHECK:   return %[[res]]
func.func @indexCastUIOfUnsignedExtend(%arg0: i8) -> index {
  %ext = arith.extui %arg0 : i8 to i16
  %idx = arith.index_castui %ext : i16 to index
  return %idx : index
}

// CHECK-LABEL: @indexCastFold
//       CHECK:   %[[res:.*]] = arith.constant -2 : index
//       CHECK:   return %[[res]]
func.func @indexCastFold() -> index {
  %c-2 = arith.constant -2 : i8
  %idx = arith.index_cast %c-2 : i8 to index
  return %idx : index
}

// CHECK-LABEL: @indexCastFoldIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant 1 : i32
//       CHECK:   return %[[res]]
func.func @indexCastFoldIndexToInt() -> i32 {
  %c1 = arith.constant 1 : index
  %int = arith.index_cast %c1 : index to i32
  return %int : i32
}

// CHECK-LABEL: @indexCastFoldSplatVector
//       CHECK:   %[[res:.*]] = arith.constant dense<42> : vector<3xindex>
//       CHECK:   return %[[res]] : vector<3xindex>
func.func @indexCastFoldSplatVector() -> vector<3xindex> {
  %cst = arith.constant dense<42> : vector<3xi32>
  %int = arith.index_cast %cst : vector<3xi32> to vector<3xindex>
  return %int : vector<3xindex>
}

// CHECK-LABEL: @indexCastFoldVector
//       CHECK:   %[[res:.*]] = arith.constant dense<[1, 2, 3]> : vector<3xindex>
//       CHECK:   return %[[res]] : vector<3xindex>
func.func @indexCastFoldVector() -> vector<3xindex> {
  %cst = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %int = arith.index_cast %cst : vector<3xi32> to vector<3xindex>
  return %int : vector<3xindex>
}

// CHECK-LABEL: @indexCastFoldSplatVectorIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant dense<42> : vector<3xi32>
//       CHECK:   return %[[res]] : vector<3xi32>
func.func @indexCastFoldSplatVectorIndexToInt() -> vector<3xi32> {
  %cst = arith.constant dense<42> : vector<3xindex>
  %int = arith.index_cast %cst : vector<3xindex> to vector<3xi32>
  return %int : vector<3xi32>
}

// CHECK-LABEL: @indexCastFoldVectorIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant dense<[1, 2, 3]> : vector<3xi32>
//       CHECK:   return %[[res]] : vector<3xi32>
func.func @indexCastFoldVectorIndexToInt() -> vector<3xi32> {
  %cst = arith.constant dense<[1, 2, 3]> : vector<3xindex>
  %int = arith.index_cast %cst : vector<3xindex> to vector<3xi32>
  return %int : vector<3xi32>
}

// CHECK-LABEL: @indexCastUIFold
//       CHECK:   %[[res:.*]] = arith.constant 254 : index
//       CHECK:   return %[[res]]
func.func @indexCastUIFold() -> index {
  %c-2 = arith.constant -2 : i8
  %idx = arith.index_castui %c-2 : i8 to index
  return %idx : index
}

// CHECK-LABEL: @indexCastUIFoldSplatVector
//       CHECK:   %[[res:.*]] = arith.constant dense<42> : vector<3xindex>
//       CHECK:   return %[[res]] : vector<3xindex>
func.func @indexCastUIFoldSplatVector() -> vector<3xindex> {
  %cst = arith.constant dense<42> : vector<3xi32>
  %int = arith.index_castui %cst : vector<3xi32> to vector<3xindex>
  return %int : vector<3xindex>
}

// CHECK-LABEL: @indexCastUIFoldVector
//       CHECK:   %[[res:.*]] = arith.constant dense<[1, 2, 3]> : vector<3xindex>
//       CHECK:   return %[[res]] : vector<3xindex>
func.func @indexCastUIFoldVector() -> vector<3xindex> {
  %cst = arith.constant dense<[1, 2, 3]> : vector<3xi32>
  %int = arith.index_castui %cst : vector<3xi32> to vector<3xindex>
  return %int : vector<3xindex>
}

// CHECK-LABEL: @indexCastUIFoldIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant 1 : i32
//       CHECK:   return %[[res]]
func.func @indexCastUIFoldIndexToInt() -> i32 {
  %c1 = arith.constant 1 : index
  %int = arith.index_castui %c1 : index to i32
  return %int : i32
}

// CHECK-LABEL: @indexCastUIFoldSplatVectorIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant dense<42> : vector<3xi32>
//       CHECK:   return %[[res]] : vector<3xi32>
func.func @indexCastUIFoldSplatVectorIndexToInt() -> vector<3xi32> {
  %cst = arith.constant dense<42> : vector<3xindex>
  %int = arith.index_castui %cst : vector<3xindex> to vector<3xi32>
  return %int : vector<3xi32>
}

// CHECK-LABEL: @indexCastUIFoldVectorIndexToInt
//       CHECK:   %[[res:.*]] = arith.constant dense<[1, 2, 3]> : vector<3xi32>
//       CHECK:   return %[[res]] : vector<3xi32>
func.func @indexCastUIFoldVectorIndexToInt() -> vector<3xi32> {
  %cst = arith.constant dense<[1, 2, 3]> : vector<3xindex>
  %int = arith.index_castui %cst : vector<3xindex> to vector<3xi32>
  return %int : vector<3xi32>
}

// CHECK-LABEL: @signExtendConstant
//       CHECK:   %[[cres:.+]] = arith.constant -2 : i16
//       CHECK:   return %[[cres]]
func.func @signExtendConstant() -> i16 {
  %c-2 = arith.constant -2 : i8
  %ext = arith.extsi %c-2 : i8 to i16
  return %ext : i16
}

// CHECK-LABEL: @signExtendConstantSplat
//       CHECK:   %[[cres:.+]] = arith.constant dense<-2> : vector<4xi16>
//       CHECK:   return %[[cres]]
func.func @signExtendConstantSplat() -> vector<4xi16> {
  %c-2 = arith.constant -2 : i8
  %splat = vector.splat %c-2 : vector<4xi8>
  %ext = arith.extsi %splat : vector<4xi8> to vector<4xi16>
  return %ext : vector<4xi16>
}

// CHECK-LABEL: @signExtendConstantVector
//       CHECK:   %[[cres:.+]] = arith.constant dense<[1, 3, 5, 7]> : vector<4xi16>
//       CHECK:   return %[[cres]]
func.func @signExtendConstantVector() -> vector<4xi16> {
  %vector = arith.constant dense<[1, 3, 5, 7]> : vector<4xi8>
  %ext = arith.extsi %vector : vector<4xi8> to vector<4xi16>
  return %ext : vector<4xi16>
}

// CHECK-LABEL: @unsignedExtendConstant
//       CHECK:   %[[cres:.+]] = arith.constant 2 : i16
//       CHECK:   return %[[cres]]
func.func @unsignedExtendConstant() -> i16 {
  %c2 = arith.constant 2 : i8
  %ext = arith.extui %c2 : i8 to i16
  return %ext : i16
}

// CHECK-LABEL: @unsignedExtendConstantSplat
//       CHECK:   %[[cres:.+]] = arith.constant dense<2> : vector<4xi16>
//       CHECK:   return %[[cres]]
func.func @unsignedExtendConstantSplat() -> vector<4xi16> {
  %c2 = arith.constant 2 : i8
  %splat = vector.splat %c2 : vector<4xi8>
  %ext = arith.extui %splat : vector<4xi8> to vector<4xi16>
  return %ext : vector<4xi16>
}

// CHECK-LABEL: @unsignedExtendConstantVector
//       CHECK:   %[[cres:.+]] = arith.constant dense<[1, 3, 5, 7]> : vector<4xi16>
//       CHECK:   return %[[cres]]
func.func @unsignedExtendConstantVector() -> vector<4xi16> {
  %vector = arith.constant dense<[1, 3, 5, 7]> : vector<4xi8>
  %ext = arith.extui %vector : vector<4xi8> to vector<4xi16>
  return %ext : vector<4xi16>
}

// CHECK-LABEL: @extFPConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : f64
//       CHECK:   return %[[cres]]
func.func @extFPConstant() -> f64 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.extf %cst : f32 to f64
  return %0 : f64
}

// CHECK-LABEL: @extFPVectorConstant
//       CHECK:   %[[cres:.+]] = arith.constant dense<[0.000000e+00, 1.000000e+00]> : vector<2xf128>
//       CHECK:   return %[[cres]]
func.func @extFPVectorConstant() -> vector<2xf128> {
  %cst = arith.constant dense<[0.000000e+00, 1.000000e+00]> : vector<2xf80>
  %0 = arith.extf %cst : vector<2xf80> to vector<2xf128>
  return %0 : vector<2xf128>
}

// CHECK-LABEL: @truncExtf
//       CHECK-NOT:  truncf
//       CHECK:   return  %arg0
func.func @truncExtf(%arg0: f32) -> f32 {
  %extf = arith.extf %arg0 : f32 to f64
  %trunc = arith.truncf %extf : f64 to f32
  return %trunc : f32
}

// CHECK-LABEL: @truncExtf1
//       CHECK-NOT:  truncf
//       CHECK:   return  %arg0
func.func @truncExtf1(%arg0: bf16) -> bf16 {
  %extf = arith.extf %arg0 : bf16 to f32
  %trunc = arith.truncf %extf : f32 to bf16
  return %trunc : bf16
}

// CHECK-LABEL: @truncExtf2
//       CHECK:  %[[ARG0:.+]]: bf16
//       CHECK:  %[[EXTF:.*]] = arith.extf %[[ARG0:.+]] : bf16 to f32
//       CHECK:  %[[TRUNCF:.*]] = arith.truncf %[[EXTF:.*]] : f32 to f16
//       CHECK:   return  %[[TRUNCF:.*]]
func.func @truncExtf2(%arg0: bf16) -> f16 {
  %extf = arith.extf %arg0 : bf16 to f32
  %trunc = arith.truncf %extf : f32 to f16
  return %trunc : f16
}

// CHECK-LABEL: @truncExtf3
//       CHECK:  %[[ARG0:.+]]: f32
//       CHECK:  %[[CST:.*]] = arith.truncf %[[ARG0:.+]] : f32 to f16
//       CHECK:   return  %[[CST:.*]]
func.func @truncExtf3(%arg0: f32) -> f16 {
  %extf = arith.extf %arg0 : f32 to f64
  %truncf = arith.truncf %extf : f64 to f16
  return %truncf : f16
}

// CHECK-LABEL: @truncSitofp
//       CHECK:     %[[SITOFP:.*]] = arith.sitofp %[[ARG0:.*]] : i32 to f32
//       CHECK-NOT: truncf
//       CHECK:     return %[[SITOFP]]
func.func @truncSitofp(%arg0: i32) -> f32 {
  %sitofp = arith.sitofp %arg0 : i32 to f64
  %trunc = arith.truncf %sitofp : f64 to f32
  return %trunc : f32
}

// CHECK-LABEL: @truncSitofpConstrained
//       CHECK: truncf
func.func @truncSitofpConstrained(%arg0: i32) -> f32 {
  %sitofp = arith.sitofp %arg0 : i32 to f64
  %trunc = arith.truncf %sitofp to_nearest_even : f64 to f32
  return %trunc : f32
}

// TODO: We should also add a test for not folding arith.extf on information loss.
// This may happen when extending f8E5M2FNUZ to f16.

// CHECK-LABEL: @truncConstant
//       CHECK:   %[[cres:.+]] = arith.constant -2 : i16
//       CHECK:   return %[[cres]]
func.func @truncConstant(%arg0: i8) -> i16 {
  %c-2 = arith.constant -2 : i32
  %tr = arith.trunci %c-2 : i32 to i16
  return %tr : i16
}

// CHECK-LABEL: @truncExtui
//       CHECK-NOT:  trunci
//       CHECK:   return  %arg0
func.func @truncExtui(%arg0: i32) -> i32 {
  %extui = arith.extui %arg0 : i32 to i64
  %trunci = arith.trunci %extui : i64 to i32
  return %trunci : i32
}

// CHECK-LABEL: @truncExtui2
//       CHECK:  %[[ARG0:.+]]: i32
//       CHECK:  %[[CST:.*]] = arith.trunci %[[ARG0:.+]] : i32 to i16
//       CHECK:   return  %[[CST:.*]]
func.func @truncExtui2(%arg0: i32) -> i16 {
  %extui = arith.extui %arg0 : i32 to i64
  %trunci = arith.trunci %extui : i64 to i16
  return %trunci : i16
}

// CHECK-LABEL: @truncExtui3
//       CHECK:  %[[ARG0:.+]]: i8
//       CHECK:  %[[CST:.*]] = arith.extui %[[ARG0:.+]] : i8 to i16
//       CHECK:   return  %[[CST:.*]] : i16
func.func @truncExtui3(%arg0: i8) -> i16 {
  %extui = arith.extui %arg0 : i8 to i32
  %trunci = arith.trunci %extui : i32 to i16
  return %trunci : i16
}

// CHECK-LABEL: @truncExtuiVector
//       CHECK:  %[[ARG0:.+]]: vector<2xi32>
//       CHECK:  %[[CST:.*]] = arith.trunci %[[ARG0:.+]] : vector<2xi32> to vector<2xi16>
//       CHECK:   return  %[[CST:.*]]
func.func @truncExtuiVector(%arg0: vector<2xi32>) -> vector<2xi16> {
  %extsi = arith.extui %arg0 : vector<2xi32> to vector<2xi64>
  %trunci = arith.trunci %extsi : vector<2xi64> to vector<2xi16>
  return %trunci : vector<2xi16>
}

// CHECK-LABEL: @truncExtsi
//       CHECK-NOT:  trunci
//       CHECK:   return  %arg0
func.func @truncExtsi(%arg0: i32) -> i32 {
  %extsi = arith.extsi %arg0 : i32 to i64
  %trunci = arith.trunci %extsi : i64 to i32
  return %trunci : i32
}

// CHECK-LABEL: @truncExtsi2
//       CHECK:  %[[ARG0:.+]]: i32
//       CHECK:  %[[CST:.*]] = arith.trunci %[[ARG0:.+]] : i32 to i16
//       CHECK:   return  %[[CST:.*]]
func.func @truncExtsi2(%arg0: i32) -> i16 {
  %extsi = arith.extsi %arg0 : i32 to i64
  %trunci = arith.trunci %extsi : i64 to i16
  return %trunci : i16
}

// CHECK-LABEL: @truncExtsi3
//       CHECK:  %[[ARG0:.+]]: i8
//       CHECK:  %[[CST:.*]] = arith.extsi %[[ARG0:.+]] : i8 to i16
//       CHECK:   return  %[[CST:.*]] : i16
func.func @truncExtsi3(%arg0: i8) -> i16 {
  %extsi = arith.extsi %arg0 : i8 to i32
  %trunci = arith.trunci %extsi : i32 to i16
  return %trunci : i16
}

// CHECK-LABEL: @truncExtsiVector
//       CHECK:  %[[ARG0:.+]]: vector<2xi32>
//       CHECK:  %[[CST:.*]] = arith.trunci %[[ARG0:.+]] : vector<2xi32> to vector<2xi16>
//       CHECK:   return  %[[CST:.*]]
func.func @truncExtsiVector(%arg0: vector<2xi32>) -> vector<2xi16> {
  %extsi = arith.extsi %arg0 : vector<2xi32> to vector<2xi64>
  %trunci = arith.trunci %extsi : vector<2xi64> to vector<2xi16>
  return %trunci : vector<2xi16>
}

// CHECK-LABEL: @truncConstantSplat
//       CHECK:   %[[cres:.+]] = arith.constant dense<-2> : vector<4xi8>
//       CHECK:   return %[[cres]]
func.func @truncConstantSplat() -> vector<4xi8> {
  %c-2 = arith.constant -2 : i16
  %splat = vector.splat %c-2 : vector<4xi16>
  %trunc = arith.trunci %splat : vector<4xi16> to vector<4xi8>
  return %trunc : vector<4xi8>
}

// CHECK-LABEL: @truncConstantVector
//       CHECK:   %[[cres:.+]] = arith.constant dense<[1, 3, 5, 7]> : vector<4xi8>
//       CHECK:   return %[[cres]]
func.func @truncConstantVector() -> vector<4xi8> {
  %vector = arith.constant dense<[1, 3, 5, 7]> : vector<4xi16>
  %trunc = arith.trunci %vector : vector<4xi16> to vector<4xi8>
  return %trunc : vector<4xi8>
}

// CHECK-LABEL: @truncTrunc
//       CHECK:   %[[cres:.+]] = arith.trunci %arg0 : i64 to i8
//       CHECK:   return %[[cres]]
func.func @truncTrunc(%arg0: i64) -> i8 {
  %tr1 = arith.trunci %arg0 : i64 to i32
  %tr2 = arith.trunci %tr1 : i32 to i8
  return %tr2 : i8
}

// CHECK-LABEL: @truncFPConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPToNearestEvenConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPToNearestEvenConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst to_nearest_even : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPDownwardConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPDownwardConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst downward : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPUpwardConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPUpwardConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst upward : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPTowardZeroConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPTowardZeroConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst toward_zero : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPToNearestAwayConstant
//       CHECK:   %[[cres:.+]] = arith.constant 1.000000e+00 : bf16
//       CHECK:   return %[[cres]]
func.func @truncFPToNearestAwayConstant() -> bf16 {
  %cst = arith.constant 1.000000e+00 : f32
  %0 = arith.truncf %cst to_nearest_away : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @truncFPVectorConstant
//       CHECK:   %[[cres:.+]] = arith.constant dense<[0.000000e+00, 1.000000e+00]> : vector<2xbf16>
//       CHECK:   return %[[cres]]
func.func @truncFPVectorConstant() -> vector<2xbf16> {
  %cst = arith.constant dense<[0.000000e+00, 1.000000e+00]> : vector<2xf32>
  %0 = arith.truncf %cst : vector<2xf32> to vector<2xbf16>
  return %0 : vector<2xbf16>
}

// Test that cases with rounding are NOT propagated
// CHECK-LABEL: @truncFPConstantRounding
//       CHECK:   arith.constant 1.444000e+25 : f32
//       CHECK:   truncf
func.func @truncFPConstantRounding() -> bf16 {
  %cst = arith.constant 1.444000e+25 : f32
  %0 = arith.truncf %cst : f32 to bf16
  return %0 : bf16
}

// CHECK-LABEL: @tripleAddAdd
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleAddAdd(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 : index
  %add2 = arith.addi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleAddAddOvf1
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleAddAddOvf1(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 overflow<nsw, nuw> : index
  %add2 = arith.addi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleAddAddOvf2
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleAddAddOvf2(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 overflow<nsw> : index
  %add2 = arith.addi %c42, %add1 overflow<nuw> : index
  return %add2 : index
}


// CHECK-LABEL: @foldSubXX_tensor
//       CHECK:   %[[c0:.+]] = arith.constant dense<0> : tensor<10xi32>
//       CHECK:   %[[sub:.+]] = arith.subi
//       CHECK:   return %[[c0]], %[[sub]]
func.func @foldSubXX_tensor(%static : tensor<10xi32>, %dyn : tensor<?x?xi32>) -> (tensor<10xi32>, tensor<?x?xi32>) {
  %static_sub = arith.subi %static, %static : tensor<10xi32>
  %dyn_sub = arith.subi %dyn, %dyn : tensor<?x?xi32>
  return %static_sub, %dyn_sub : tensor<10xi32>, tensor<?x?xi32>
}

// CHECK-LABEL: @foldSubXX_vector
//       CHECK-DAG:  %[[c0:.+]] = arith.constant dense<0> : vector<8xi32>
//       CHECK-DAG:  %[[c0_scalable:.+]] = arith.constant dense<0> : vector<[4]xi32>
//       CHECK:   return %[[c0]], %[[c0_scalable]]
func.func @foldSubXX_vector(%static : vector<8xi32>, %dyn : vector<[4]xi32>) -> (vector<8xi32>, vector<[4]xi32>) {
  %static_sub = arith.subi %static, %static : vector<8xi32>
  %dyn_sub = arith.subi %dyn, %dyn : vector<[4]xi32>
  return %static_sub, %dyn_sub : vector<8xi32>, vector<[4]xi32>
}

// CHECK-LABEL: @tripleAddSub0
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 : index
//       CHECK:   return %[[add]]
func.func @tripleAddSub0(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 : index
  %add2 = arith.addi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleAddSub0Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleAddSub0Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 overflow<nsw, nuw> : index
  %add2 = arith.addi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleAddSub1
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleAddSub1(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 : index
  %add2 = arith.addi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleAddSub1Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleAddSub1Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 overflow<nsw, nuw> : index
  %add2 = arith.addi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubAdd0
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 : index
//       CHECK:   return %[[add]]
func.func @tripleSubAdd0(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 : index
  %add2 = arith.subi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubAdd0Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleSubAdd0Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 overflow<nsw, nuw> : index
  %add2 = arith.subi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubAdd1
//       CHECK:   %[[cres:.+]] = arith.constant -25 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleSubAdd1(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.addi %c17, %arg0 : index
  %add2 = arith.subi %add1, %c42 : index
  return %add2 : index
}

// CHECK-LABEL: @subSub0
//       CHECK:   %[[c0:.+]] = arith.constant 0 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[c0]], %arg1 : index
//       CHECK:   return %[[add]]
func.func @subSub0(%arg0: index, %arg1: index) -> index {
  %sub1 = arith.subi %arg0, %arg1 : index
  %sub2 = arith.subi %sub1, %arg0 : index
  return %sub2 : index
}

// CHECK-LABEL: @subSub0Ovf
//       CHECK:   %[[c0:.+]] = arith.constant 0 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[c0]], %arg1 overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @subSub0Ovf(%arg0: index, %arg1: index) -> index {
  %sub1 = arith.subi %arg0, %arg1 overflow<nsw, nuw> : index
  %sub2 = arith.subi %sub1, %arg0 overflow<nsw, nuw> : index
  return %sub2 : index
}

// CHECK-LABEL: @tripleSubSub0
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub0(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 : index
  %add2 = arith.subi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub0Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 25 : index
//       CHECK:   %[[add:.+]] = arith.addi %arg0, %[[cres]] overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub0Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 overflow<nsw, nuw> : index
  %add2 = arith.subi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}


// CHECK-LABEL: @tripleSubSub1
//       CHECK:   %[[cres:.+]] = arith.constant -25 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub1(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 : index
  %add2 = arith.subi %add1, %c42 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub1Ovf
//       CHECK:   %[[cres:.+]] = arith.constant -25 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub1Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %c17, %arg0 overflow<nsw, nuw> : index
  %add2 = arith.subi %add1, %c42 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub2
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub2(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 : index
  %add2 = arith.subi %c42, %add1 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub2Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %[[cres]], %arg0 overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub2Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 overflow<nsw, nuw> : index
  %add2 = arith.subi %c42, %add1 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub3
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %arg0, %[[cres]] : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub3(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 : index
  %add2 = arith.subi %add1, %c42 : index
  return %add2 : index
}

// CHECK-LABEL: @tripleSubSub3Ovf
//       CHECK:   %[[cres:.+]] = arith.constant 59 : index
//       CHECK:   %[[add:.+]] = arith.subi %arg0, %[[cres]] overflow<nsw, nuw> : index
//       CHECK:   return %[[add]]
func.func @tripleSubSub3Ovf(%arg0: index) -> index {
  %c17 = arith.constant 17 : index
  %c42 = arith.constant 42 : index
  %add1 = arith.subi %arg0, %c17 overflow<nsw, nuw> : index
  %add2 = arith.subi %add1, %c42 overflow<nsw, nuw> : index
  return %add2 : index
}

// CHECK-LABEL: @subAdd1
//  CHECK-NEXT:   return %arg0
func.func @subAdd1(%arg0: index, %arg1 : index) -> index {
  %add = arith.addi %arg0, %arg1 : index
  %sub = arith.subi %add, %arg1 : index
  return %sub : index
}

// CHECK-LABEL: @subAdd2
//  CHECK-NEXT:   return %arg1
func.func @subAdd2(%arg0: index, %arg1 : index) -> index {
  %add = arith.addi %arg0, %arg1 : index
  %sub = arith.subi %add, %arg0 : index
  return %sub : index
}

// CHECK-LABEL: @doubleAddSub1
//  CHECK-NEXT:   return %arg0
func.func @doubleAddSub1(%arg0: index, %arg1 : index) -> index {
  %sub = arith.subi %arg0, %arg1 : index
  %add = arith.addi %sub, %arg1 : index
  return %add : index
}

// CHECK-LABEL: @doubleAddSub2
//  CHECK-NEXT:   return %arg0
func.func @doubleAddSub2(%arg0: index, %arg1 : index) -> index {
  %sub = arith.subi %arg0, %arg1 : index
  %add = arith.addi %arg1, %sub : index
  return %add : index
}

// Negative test case to ensure no further folding is performed when there's a type mismatch between the values and the result.
// CHECK-LABEL:   func.func @nested_muli() -> i32 {
// CHECK:           %[[VAL_0:.*]] = "test.constant"() <{value = 2147483647 : i64}> : () -> i32
// CHECK:           %[[VAL_1:.*]] = "test.constant"() <{value = -2147483648 : i64}> : () -> i32
// CHECK:           %[[VAL_2:.*]] = "test.constant"() <{value = 2147483648 : i64}> : () -> i32
// CHECK:           %[[VAL_3:.*]] = arith.muli %[[VAL_0]], %[[VAL_1]] : i32
// CHECK:           %[[VAL_4:.*]] = arith.muli %[[VAL_3]], %[[VAL_2]] : i32
// CHECK:           return %[[VAL_4]] : i32
// CHECK:         }
func.func @nested_muli() -> (i32) {
  %0 = "test.constant"() {value = 0x7fffffff} : () -> i32
  %1 = "test.constant"() {value = -2147483648} : () -> i32
  %2 = "test.constant"() {value = 0x80000000} : () -> i32
  %4 = arith.muli %0, %1 : i32
  %5 = arith.muli %4, %2 : i32
  return %5 : i32
}

// CHECK-LABEL: @tripleMulIMulIIndex
//       CHECK:   %[[cres:.+]] = arith.constant 15 : index
//       CHECK:   %[[muli:.+]] = arith.muli %arg0, %[[cres]] : index
//       CHECK:   return %[[muli]]
func.func @tripleMulIMulIIndex(%arg0: index) -> index {
  %c3 = arith.constant 3 : index
  %c5 = arith.constant 5 : index
  %mul1 = arith.muli %arg0, %c3 : index
  %mul2 = arith.muli %mul1, %c5 : index
  return %mul2 : index
}

// CHECK-LABEL: @tripleMulIMulII32
//       CHECK:   %[[cres:.+]] = arith.constant -21 : i32
//       CHECK:   %[[muli:.+]] = arith.muli %arg0, %[[cres]] : i32
//       CHECK:   return %[[muli]]
func.func @tripleMulIMulII32(%arg0: i32) -> i32 {
  %c_n3 = arith.constant -3 : i32
  %c7 = arith.constant 7 : i32
  %mul1 = arith.muli %arg0, %c_n3 : i32
  %mul2 = arith.muli %mul1, %c7 : i32
  return %mul2 : i32
}

// CHECK-LABEL: @tripleMulLargeInt
//       CHECK:   %[[cres:.+]] = arith.constant 3618502788666131213697322783095070105623107215331596699973092056135872020482 : i256
//       CHECK:   %[[addi:.+]] = arith.addi %arg0, %[[cres]] : i256
//       CHECK:   return %[[addi]]
func.func @tripleMulLargeInt(%arg0: i256) -> i256 {
  %0 = arith.constant 3618502788666131213697322783095070105623107215331596699973092056135872020481 : i256
  %1 = arith.constant 1 : i256
  %2 = arith.addi %arg0, %0 : i256
  %3 = arith.addi %2, %1 : i256
  return %3 : i256
}

// CHECK-LABEL: @addiMuliToSubiRhsI32
//  CHECK-SAME:   (%[[ARG0:.+]]: i32, %[[ARG1:.+]]: i32)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : i32
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiRhsI32(%arg0: i32, %arg1: i32) -> i32 {
  %c-1 = arith.constant -1 : i32
  %neg = arith.muli %arg1, %c-1 : i32
  %add = arith.addi %arg0, %neg : i32
  return %add : i32
}

// CHECK-LABEL: @addiMuliToSubiRhsIndex
//  CHECK-SAME:   (%[[ARG0:.+]]: index, %[[ARG1:.+]]: index)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : index
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiRhsIndex(%arg0: index, %arg1: index) -> index {
  %c-1 = arith.constant -1 : index
  %neg = arith.muli %arg1, %c-1 : index
  %add = arith.addi %arg0, %neg : index
  return %add : index
}

// CHECK-LABEL: @addiMuliToSubiRhsVector
//  CHECK-SAME:   (%[[ARG0:.+]]: vector<3xi64>, %[[ARG1:.+]]: vector<3xi64>)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : vector<3xi64>
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiRhsVector(%arg0: vector<3xi64>, %arg1: vector<3xi64>) -> vector<3xi64> {
  %c-1 = arith.constant dense<-1> : vector<3xi64>
  %neg = arith.muli %arg1, %c-1 : vector<3xi64>
  %add = arith.addi %arg0, %neg : vector<3xi64>
  return %add : vector<3xi64>
}

// CHECK-LABEL: @addiMuliToSubiLhsI32
//  CHECK-SAME:   (%[[ARG0:.+]]: i32, %[[ARG1:.+]]: i32)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : i32
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiLhsI32(%arg0: i32, %arg1: i32) -> i32 {
  %c-1 = arith.constant -1 : i32
  %neg = arith.muli %arg1, %c-1 : i32
  %add = arith.addi %neg, %arg0 : i32
  return %add : i32
}

// CHECK-LABEL: @addiMuliToSubiLhsIndex
//  CHECK-SAME:   (%[[ARG0:.+]]: index, %[[ARG1:.+]]: index)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : index
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiLhsIndex(%arg0: index, %arg1: index) -> index {
  %c-1 = arith.constant -1 : index
  %neg = arith.muli %arg1, %c-1 : index
  %add = arith.addi %neg, %arg0 : index
  return %add : index
}

// CHECK-LABEL: @addiMuliToSubiLhsVector
//  CHECK-SAME:   (%[[ARG0:.+]]: vector<3xi64>, %[[ARG1:.+]]: vector<3xi64>)
//       CHECK:   %[[SUB:.+]] = arith.subi %[[ARG0]], %[[ARG1]] : vector<3xi64>
//       CHECK:   return %[[SUB]]
func.func @addiMuliToSubiLhsVector(%arg0: vector<3xi64>, %arg1: vector<3xi64>) -> vector<3xi64> {
  %c-1 = arith.constant dense<-1> : vector<3xi64>
  %neg = arith.muli %arg1, %c-1 : vector<3xi64>
  %add = arith.addi %neg, %arg0 : vector<3xi64>
  return %add : vector<3xi64>
}

// CHECK-LABEL: @adduiExtendedZeroRhs
//  CHECK-NEXT:   %[[false:.+]] = arith.constant false
//  CHECK-NEXT:   return %arg0, %[[false]]
func.func @adduiExtendedZeroRhs(%arg0: i32) -> (i32, i1) {
  %zero = arith.constant 0 : i32
  %sum, %overflow = arith.addui_extended %arg0, %zero: i32, i1
  return %sum, %overflow : i32, i1
}

// CHECK-LABEL: @adduiExtendedZeroRhsSplat
//  CHECK-NEXT:   %[[false:.+]] = arith.constant dense<false> : vector<4xi1>
//  CHECK-NEXT:   return %arg0, %[[false]]
func.func @adduiExtendedZeroRhsSplat(%arg0: vector<4xi32>) -> (vector<4xi32>, vector<4xi1>) {
  %zero = arith.constant dense<0> : vector<4xi32>
  %sum, %overflow = arith.addui_extended %arg0, %zero: vector<4xi32>, vector<4xi1>
  return %sum, %overflow : vector<4xi32>, vector<4xi1>
}

// CHECK-LABEL: @adduiExtendedZeroLhs
//  CHECK-NEXT:   %[[false:.+]] = arith.constant false
//  CHECK-NEXT:   return %arg0, %[[false]]
func.func @adduiExtendedZeroLhs(%arg0: i32) -> (i32, i1) {
  %zero = arith.constant 0 : i32
  %sum, %overflow = arith.addui_extended %zero, %arg0: i32, i1
  return %sum, %overflow : i32, i1
}

// CHECK-LABEL: @adduiExtendedUnusedOverflowScalar
//  CHECK-SAME:   (%[[LHS:.+]]: i32, %[[RHS:.+]]: i32) -> i32
//  CHECK-NEXT:   %[[RES:.+]] = arith.addi %[[LHS]], %[[RHS]] : i32
//  CHECK-NEXT:   return %[[RES]] : i32
func.func @adduiExtendedUnusedOverflowScalar(%arg0: i32, %arg1: i32) -> i32 {
  %sum, %overflow = arith.addui_extended %arg0, %arg1: i32, i1
  return %sum : i32
}

// CHECK-LABEL: @adduiExtendedUnusedOverflowVector
//  CHECK-SAME:   (%[[LHS:.+]]: vector<3xi32>, %[[RHS:.+]]: vector<3xi32>) -> vector<3xi32>
//  CHECK-NEXT:   %[[RES:.+]] = arith.addi %[[LHS]], %[[RHS]] : vector<3xi32>
//  CHECK-NEXT:   return %[[RES]] : vector<3xi32>
func.func @adduiExtendedUnusedOverflowVector(%arg0: vector<3xi32>, %arg1: vector<3xi32>) -> vector<3xi32> {
  %sum, %overflow = arith.addui_extended %arg0, %arg1: vector<3xi32>, vector<3xi1>
  return %sum : vector<3xi32>
}

// CHECK-LABEL: @adduiExtendedConstants
//  CHECK-DAG:    %[[false:.+]] = arith.constant false
//  CHECK-DAG:    %[[c50:.+]] = arith.constant 50 : i32
//  CHECK-NEXT:   return %[[c50]], %[[false]]
func.func @adduiExtendedConstants() -> (i32, i1) {
  %c13 = arith.constant 13 : i32
  %c37 = arith.constant 37 : i32
  %sum, %overflow = arith.addui_extended %c13, %c37: i32, i1
  return %sum, %overflow : i32, i1
}

// CHECK-LABEL: @adduiExtendedConstantsOverflow1
//  CHECK-DAG:    %[[true:.+]] = arith.constant true
//  CHECK-DAG:    %[[c0:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[c0]], %[[true]]
func.func @adduiExtendedConstantsOverflow1() -> (i32, i1) {
  %max = arith.constant 4294967295 : i32
  %c1 = arith.constant 1 : i32
  %sum, %overflow = arith.addui_extended %max, %c1: i32, i1
  return %sum, %overflow : i32, i1
}

// CHECK-LABEL: @adduiExtendedConstantsOverflow2
//  CHECK-DAG:    %[[true:.+]] = arith.constant true
//  CHECK-DAG:    %[[c_2:.+]] = arith.constant -2 : i32
// CHECK-NEXT:    return %[[c_2]], %[[true]]
func.func @adduiExtendedConstantsOverflow2() -> (i32, i1) {
  %max = arith.constant 4294967295 : i32
  %sum, %overflow = arith.addui_extended %max, %max: i32, i1
  return %sum, %overflow : i32, i1
}

// CHECK-LABEL: @adduiExtendedConstantsOverflowVector
//  CHECK-DAG:    %[[sum:.+]] = arith.constant dense<[1, 6, 2, 14]> : vector<4xi32>
//  CHECK-DAG:    %[[overflow:.+]] = arith.constant dense<[false, false, true, false]> : vector<4xi1>
// CHECK-NEXT:    return %[[sum]], %[[overflow]]
func.func @adduiExtendedConstantsOverflowVector() -> (vector<4xi32>, vector<4xi1>) {
  %v1 = arith.constant dense<[1, 3, 3, 7]> : vector<4xi32>
  %v2 = arith.constant dense<[0, 3, 4294967295, 7]> : vector<4xi32>
  %sum, %overflow = arith.addui_extended %v1, %v2 : vector<4xi32>, vector<4xi1>
  return %sum, %overflow : vector<4xi32>, vector<4xi1>
}

// CHECK-LABEL: @adduiExtendedConstantsSplatVector
//   CHECK-DAG:   %[[sum:.+]] = arith.constant dense<3> : vector<4xi32>
//   CHECK-DAG:   %[[overflow:.+]] = arith.constant dense<false> : vector<4xi1>
//  CHECK-NEXT:   return %[[sum]], %[[overflow]]
func.func @adduiExtendedConstantsSplatVector() -> (vector<4xi32>, vector<4xi1>) {
  %v1 = arith.constant dense<1> : vector<4xi32>
  %v2 = arith.constant dense<2> : vector<4xi32>
  %sum, %overflow = arith.addui_extended %v1, %v2 : vector<4xi32>, vector<4xi1>
  return %sum, %overflow : vector<4xi32>, vector<4xi1>
}

// CHECK-LABEL: @mulsiExtendedZeroRhs
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @mulsiExtendedZeroRhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 0 : i32
  %low, %high = arith.mulsi_extended %arg0, %zero: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @mulsiExtendedZeroRhsSplat
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant dense<0> : vector<3xi32>
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @mulsiExtendedZeroRhsSplat(%arg0: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>) {
  %zero = arith.constant dense<0> : vector<3xi32>
  %low, %high = arith.mulsi_extended %arg0, %zero: vector<3xi32>
  return %low, %high : vector<3xi32>, vector<3xi32>
}

// CHECK-LABEL: @mulsiExtendedZeroLhs
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @mulsiExtendedZeroLhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 0 : i32
  %low, %high = arith.mulsi_extended %zero, %arg0: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @mulsiExtendedOneRhs
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> (i32, i32)
//  CHECK-NEXT:   %[[C0:.+]]  = arith.constant 0 : i32
//  CHECK-NEXT:   %[[CMP:.+]] = arith.cmpi slt, %[[ARG]], %[[C0]] : i32
//  CHECK-NEXT:   %[[EXT:.+]] = arith.extsi %[[CMP]] : i1 to i32
//  CHECK-NEXT:   return %[[ARG]], %[[EXT]] : i32, i32
func.func @mulsiExtendedOneRhs(%arg0: i32) -> (i32, i32) {
  %one = arith.constant 1 : i32
  %low, %high = arith.mulsi_extended %arg0, %one: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @mulsiExtendedOneRhsSplat
//  CHECK-SAME:   (%[[ARG:.+]]: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>)
//  CHECK-NEXT:   %[[C0:.+]]  = arith.constant dense<0> : vector<3xi32>
//  CHECK-NEXT:   %[[CMP:.+]] = arith.cmpi slt, %[[ARG]], %[[C0]] : vector<3xi32>
//  CHECK-NEXT:   %[[EXT:.+]] = arith.extsi %[[CMP]] : vector<3xi1> to vector<3xi32>
//  CHECK-NEXT:   return %[[ARG]], %[[EXT]] : vector<3xi32>, vector<3xi32>
func.func @mulsiExtendedOneRhsSplat(%arg0: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>) {
  %one = arith.constant dense<1> : vector<3xi32>
  %low, %high = arith.mulsi_extended %arg0, %one: vector<3xi32>
  return %low, %high : vector<3xi32>, vector<3xi32>
}

// CHECK-LABEL: @mulsiExtendedOneRhsI1
//  CHECK-SAME:   (%[[ARG:.+]]: i1) -> (i1, i1)
//  CHECK-NEXT:   %[[T:.+]]  = arith.constant true
//  CHECK-NEXT:   %[[LOW:.+]], %[[HIGH:.+]] = arith.mulsi_extended %[[ARG]], %[[T]] : i1
//  CHECK-NEXT:   return %[[LOW]], %[[HIGH]] : i1, i1
func.func @mulsiExtendedOneRhsI1(%arg0: i1) -> (i1, i1) {
  %one = arith.constant true
  %low, %high = arith.mulsi_extended %arg0, %one: i1
  return %low, %high : i1, i1
}

// CHECK-LABEL: @mulsiExtendedOneRhsSplatI1
//  CHECK-SAME:   (%[[ARG:.+]]: vector<3xi1>) -> (vector<3xi1>, vector<3xi1>)
//  CHECK-NEXT:   %[[TS:.+]]  = arith.constant dense<true> : vector<3xi1>
//  CHECK-NEXT:   %[[LOW:.+]], %[[HIGH:.+]] = arith.mulsi_extended %[[ARG]], %[[TS]] : vector<3xi1>
//  CHECK-NEXT:   return %[[LOW]], %[[HIGH]] : vector<3xi1>, vector<3xi1>
func.func @mulsiExtendedOneRhsSplatI1(%arg0: vector<3xi1>) -> (vector<3xi1>, vector<3xi1>) {
  %one = arith.constant dense<true> : vector<3xi1>
  %low, %high = arith.mulsi_extended %arg0, %one: vector<3xi1>
  return %low, %high : vector<3xi1>, vector<3xi1>
}

// CHECK-LABEL: @mulsiExtendedUnusedHigh
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> i32
//  CHECK-NEXT:   %[[RES:.+]] = arith.muli %[[ARG]], %[[ARG]] : i32
//  CHECK-NEXT:   return %[[RES]]
func.func @mulsiExtendedUnusedHigh(%arg0: i32) -> i32 {
  %low, %high = arith.mulsi_extended %arg0, %arg0: i32
  return %low : i32
}

// CHECK-LABEL: @mulsiExtendedScalarConstants
//  CHECK-DAG:    %[[c27:.+]] = arith.constant 27 : i8
//  CHECK-DAG:    %[[c_n3:.+]] = arith.constant -3 : i8
//  CHECK-NEXT:   return %[[c27]], %[[c_n3]]
func.func @mulsiExtendedScalarConstants() -> (i8, i8) {
  %c57 = arith.constant 57 : i8
  %c_n13 = arith.constant -13 : i8
  %low, %high = arith.mulsi_extended %c57, %c_n13: i8
  return %low, %high : i8, i8
}

// CHECK-LABEL: @mulsiExtendedVectorConstants
//  CHECK-DAG:    %[[cstLo:.+]] = arith.constant dense<[65, 79, 34]> : vector<3xi8>
//  CHECK-DAG:    %[[cstHi:.+]] = arith.constant dense<[0, 14, 0]> : vector<3xi8>
//  CHECK-NEXT:   return %[[cstLo]], %[[cstHi]]
func.func @mulsiExtendedVectorConstants() -> (vector<3xi8>, vector<3xi8>) {
  %cstA = arith.constant dense<[5, 37, -17]> : vector<3xi8>
  %cstB = arith.constant dense<[13, 99, -2]> : vector<3xi8>
  %low, %high = arith.mulsi_extended %cstA, %cstB: vector<3xi8>
  return %low, %high : vector<3xi8>, vector<3xi8>
}

// CHECK-LABEL: @muluiExtendedZeroRhs
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @muluiExtendedZeroRhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 0 : i32
  %low, %high = arith.mului_extended %arg0, %zero: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @muluiExtendedZeroRhsSplat
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant dense<0> : vector<3xi32>
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @muluiExtendedZeroRhsSplat(%arg0: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>) {
  %zero = arith.constant dense<0> : vector<3xi32>
  %low, %high = arith.mului_extended %arg0, %zero: vector<3xi32>
  return %low, %high : vector<3xi32>, vector<3xi32>
}

// CHECK-LABEL: @muluiExtendedZeroLhs
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[zero]], %[[zero]]
func.func @muluiExtendedZeroLhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 0 : i32
  %low, %high = arith.mului_extended %zero, %arg0: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @muluiExtendedOneRhs
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> (i32, i32)
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[ARG]], %[[zero]]
func.func @muluiExtendedOneRhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 1 : i32
  %low, %high = arith.mului_extended %arg0, %zero: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @muluiExtendedOneRhsSplat
//  CHECK-SAME:   (%[[ARG:.+]]: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>)
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant dense<0> : vector<3xi32>
//  CHECK-NEXT:   return %[[ARG]], %[[zero]]
func.func @muluiExtendedOneRhsSplat(%arg0: vector<3xi32>) -> (vector<3xi32>, vector<3xi32>) {
  %zero = arith.constant dense<1> : vector<3xi32>
  %low, %high = arith.mului_extended %arg0, %zero: vector<3xi32>
  return %low, %high : vector<3xi32>, vector<3xi32>
}

// CHECK-LABEL: @muluiExtendedOneLhs
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> (i32, i32)
//  CHECK-NEXT:   %[[zero:.+]] = arith.constant 0 : i32
//  CHECK-NEXT:   return %[[ARG]], %[[zero]]
func.func @muluiExtendedOneLhs(%arg0: i32) -> (i32, i32) {
  %zero = arith.constant 1 : i32
  %low, %high = arith.mului_extended %zero, %arg0: i32
  return %low, %high : i32, i32
}

// CHECK-LABEL: @muluiExtendedUnusedHigh
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> i32
//  CHECK-NEXT:   %[[RES:.+]] = arith.muli %[[ARG]], %[[ARG]] : i32
//  CHECK-NEXT:   return %[[RES]]
func.func @muluiExtendedUnusedHigh(%arg0: i32) -> i32 {
  %low, %high = arith.mului_extended %arg0, %arg0: i32
  return %low : i32
}

// This shouldn't be folded.
// CHECK-LABEL: @muluiExtendedUnusedLow
//  CHECK-SAME:   (%[[ARG:.+]]: i32) -> i32
//  CHECK-NEXT:   %[[LOW:.+]], %[[HIGH:.+]] = arith.mului_extended %[[ARG]], %[[ARG]] : i32
//  CHECK-NEXT:   return %[[HIGH]]
func.func @muluiExtendedUnusedLow(%arg0: i32) -> i32 {
  %low, %high = arith.mului_extended %arg0, %arg0: i32
  return %high : i32
}

// CHECK-LABEL: @muluiExtendedScalarConstants
//  CHECK-DAG:    %[[c157:.+]] = arith.constant -99 : i8
//  CHECK-DAG:    %[[c29:.+]] = arith.constant 29 : i8
//  CHECK-NEXT:   return %[[c157]], %[[c29]]
func.func @muluiExtendedScalarConstants() -> (i8, i8) {
  %c57 = arith.constant 57 : i8
  %c133 = arith.constant 133 : i8
  %low, %high = arith.mului_extended %c57, %c133: i8 // = 7581
  return %low, %high : i8, i8
}

// CHECK-LABEL: @muluiExtendedVectorConstants
//  CHECK-DAG:    %[[cstLo:.+]] = arith.constant dense<[65, 79, 1]> : vector<3xi8>
//  CHECK-DAG:    %[[cstHi:.+]] = arith.constant dense<[0, 14, -2]> : vector<3xi8>
//  CHECK-NEXT:   return %[[cstLo]], %[[cstHi]]
func.func @muluiExtendedVectorConstants() -> (vector<3xi8>, vector<3xi8>) {
  %cstA = arith.constant dense<[5, 37, 255]> : vector<3xi8>
  %cstB = arith.constant dense<[13, 99, 255]> : vector<3xi8>
  %low, %high = arith.mului_extended %cstA, %cstB: vector<3xi8>
  return %low, %high : vector<3xi8>, vector<3xi8>
}

// CHECK-LABEL: @notCmpEQ
//       CHECK:   %[[cres:.+]] = arith.cmpi ne, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpEQ(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "eq", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpEQ2
//       CHECK:   %[[cres:.+]] = arith.cmpi ne, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpEQ2(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "eq", %arg0, %arg1 : i8
  %ncmp = arith.xori %true, %cmp : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpNE
//       CHECK:   %[[cres:.+]] = arith.cmpi eq, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpNE(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "ne", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpSLT
//       CHECK:   %[[cres:.+]] = arith.cmpi sge, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpSLT(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "slt", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpSLE
//       CHECK:   %[[cres:.+]] = arith.cmpi sgt, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpSLE(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "sle", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpSGT
//       CHECK:   %[[cres:.+]] = arith.cmpi sle, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpSGT(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "sgt", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpSGE
//       CHECK:   %[[cres:.+]] = arith.cmpi slt, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpSGE(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "sge", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpULT
//       CHECK:   %[[cres:.+]] = arith.cmpi uge, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpULT(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "ult", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpULE
//       CHECK:   %[[cres:.+]] = arith.cmpi ugt, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpULE(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "ule", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpUGT
//       CHECK:   %[[cres:.+]] = arith.cmpi ule, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpUGT(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "ugt", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// CHECK-LABEL: @notCmpUGE
//       CHECK:   %[[cres:.+]] = arith.cmpi ult, %arg0, %arg1 : i8
//       CHECK:   return %[[cres]]
func.func @notCmpUGE(%arg0: i8, %arg1: i8) -> i1 {
  %true = arith.constant true
  %cmp = arith.cmpi "uge", %arg0, %arg1 : i8
  %ncmp = arith.xori %cmp, %true : i1
  return %ncmp : i1
}

// -----

// CHECK-LABEL: @xorxor(
//       CHECK-NOT: xori
//       CHECK:   return %arg0
func.func @xorxor(%cmp : i1) -> i1 {
  %true = arith.constant true
  %ncmp = arith.xori %cmp, %true : i1
  %nncmp = arith.xori %ncmp, %true : i1
  return %nncmp : i1
}

// CHECK-LABEL: @xorOfExtSI
//       CHECK:  %[[comb:.+]] = arith.xori %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extsi %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @xorOfExtSI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extsi %arg0 : i8 to i64
  %ext1 = arith.extsi %arg1 : i8 to i64
  %res = arith.xori %ext0, %ext1 : i64
  return %res : i64
}

// CHECK-LABEL: @xorOfExtUI
//       CHECK:  %[[comb:.+]] = arith.xori %arg0, %arg1 : i8
//       CHECK:  %[[ext:.+]] = arith.extui %[[comb]] : i8 to i64
//       CHECK:   return %[[ext]]
func.func @xorOfExtUI(%arg0: i8, %arg1: i8) -> i64 {
  %ext0 = arith.extui %arg0 : i8 to i64
  %ext1 = arith.extui %arg1 : i8 to i64
  %res = arith.xori %ext0, %ext1 : i64
  return %res : i64
}

// -----

// CHECK-LABEL: @bitcastSameType(
// CHECK-SAME: %[[ARG:[a-zA-Z0-9_]*]]
func.func @bitcastSameType(%arg : f32) -> f32 {
  // CHECK: return %[[ARG]]
  %res = arith.bitcast %arg : f32 to f32
  return %res : f32
}

// -----

// CHECK-LABEL: @bitcastConstantFPtoI(
func.func @bitcastConstantFPtoI() -> i32 {
  // CHECK: %[[C0:.+]] = arith.constant 0 : i32
  // CHECK: return %[[C0]]
  %c0 = arith.constant 0.0 : f32
  %res = arith.bitcast %c0 : f32 to i32
  return %res : i32
}

// -----

// CHECK-LABEL: @bitcastConstantItoFP(
func.func @bitcastConstantItoFP() -> f32 {
  // CHECK: %[[C0:.+]] = arith.constant 0.0{{.*}} : f32
  // CHECK: return %[[C0]]
  %c0 = arith.constant 0 : i32
  %res = arith.bitcast %c0 : i32 to f32
  return %res : f32
}

// -----

// CHECK-LABEL: @bitcastConstantFPtoFP(
func.func @bitcastConstantFPtoFP() -> f16 {
  // CHECK: %[[C0:.+]] = arith.constant 0.0{{.*}} : f16
  // CHECK: return %[[C0]]
  %c0 = arith.constant 0.0 : bf16
  %res = arith.bitcast %c0 : bf16 to f16
  return %res : f16
}

// -----

// CHECK-LABEL: @bitcastConstantVecFPtoI(
func.func @bitcastConstantVecFPtoI() -> vector<3xf32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<0.0{{.*}}> : vector<3xf32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant dense<0> : vector<3xi32>
  %res = arith.bitcast %c0 : vector<3xi32> to vector<3xf32>
  return %res : vector<3xf32>
}

// -----

// CHECK-LABEL: @bitcastConstantVecItoFP(
func.func @bitcastConstantVecItoFP() -> vector<3xi32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<0> : vector<3xi32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant dense<0.0> : vector<3xf32>
  %res = arith.bitcast %c0 : vector<3xf32> to vector<3xi32>
  return %res : vector<3xi32>
}

// -----

// CHECK-LABEL: @bitcastConstantVecFPtoFP(
func.func @bitcastConstantVecFPtoFP() -> vector<3xbf16> {
  // CHECK: %[[C0:.+]] = arith.constant dense<0.0{{.*}}> : vector<3xbf16>
  // CHECK: return %[[C0]]
  %c0 = arith.constant dense<0.0> : vector<3xf16>
  %res = arith.bitcast %c0 : vector<3xf16> to vector<3xbf16>
  return %res : vector<3xbf16>
}

// -----

// CHECK-LABEL: @bitcastBackAndForth(
// CHECK-SAME: %[[ARG:[a-zA-Z0-9_]*]]
func.func @bitcastBackAndForth(%arg : i32) -> i32 {
  // CHECK: return %[[ARG]]
  %f = arith.bitcast %arg : i32 to f32
  %res = arith.bitcast %f : f32 to i32
  return %res : i32
}

// -----

// CHECK-LABEL: @bitcastOfBitcast(
// CHECK-SAME: %[[ARG:[a-zA-Z0-9_]*]]
func.func @bitcastOfBitcast(%arg : i16) -> i16 {
  // CHECK: return %[[ARG]]
  %f = arith.bitcast %arg : i16 to f16
  %bf = arith.bitcast %f : f16 to bf16
  %res = arith.bitcast %bf : bf16 to i16
  return %res : i16
}

// -----

// CHECK-LABEL: @bitcastPoisonItoFP(
func.func @bitcastPoisonItoFP() -> f32 {
  // CHECK: %[[P:.+]] = ub.poison : f32
  // CHECK: return %[[P]] : f32
  %p = ub.poison : i32
  %res = arith.bitcast %p : i32 to f32
  return %res : f32
}

// -----

// CHECK-LABEL: @bitcastPoisonFPtoI(
func.func @bitcastPoisonFPtoI() -> i32 {
  // CHECK: %[[P:.+]] = ub.poison : i32
  // CHECK: return %[[P]] : i32
  %p = ub.poison : f32
  %res = arith.bitcast %p : f32 to i32
  return %res : i32
}

// -----

// CHECK-LABEL: func @bitcastChain(
//  CHECK-SAME:     %[[arg:.*]]: i16)
//       CHECK:   %[[cast:.*]] = arith.bitcast %[[arg]] : i16 to f16
//       CHECK:   return %[[cast]]
func.func @bitcastChain(%arg: i16) -> f16 {
  %0 = arith.bitcast %arg : i16 to bf16
  %1 = arith.bitcast %0 : bf16 to f16
  return %1 : f16
}

// -----

// CHECK-LABEL: test_maxsi
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MAX_INT_CST:.+]] = arith.constant 127
// CHECK: %[[X:.+]] = arith.maxsi %arg0, %[[C0]]
// CHECK: return %arg0, %[[MAX_INT_CST]], %arg0, %[[X]]
func.func @test_maxsi(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 127 : i8
  %minIntCst = arith.constant -128 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.maxsi %arg0, %arg0 : i8
  %1 = arith.maxsi %arg0, %maxIntCst : i8
  %2 = arith.maxsi %arg0, %minIntCst : i8
  %3 = arith.maxsi %arg0, %c0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// CHECK-LABEL: test_maxsi2
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MAX_INT_CST:.+]] = arith.constant 127
// CHECK: %[[X:.+]] = arith.maxsi %arg0, %[[C0]]
// CHECK: return %arg0, %[[MAX_INT_CST]], %arg0, %[[X]]
func.func @test_maxsi2(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 127 : i8
  %minIntCst = arith.constant -128 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.maxsi %arg0, %arg0 : i8
  %1 = arith.maxsi %maxIntCst, %arg0: i8
  %2 = arith.maxsi %minIntCst, %arg0: i8
  %3 = arith.maxsi %c0, %arg0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// -----

// CHECK-LABEL: test_maxui
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MAX_INT_CST:.+]] = arith.constant -1
// CHECK: %[[X:.+]] = arith.maxui %arg0, %[[C0]]
// CHECK: return %arg0, %[[MAX_INT_CST]], %arg0, %[[X]]
func.func @test_maxui(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 255 : i8
  %minIntCst = arith.constant 0 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.maxui %arg0, %arg0 : i8
  %1 = arith.maxui %arg0, %maxIntCst : i8
  %2 = arith.maxui %arg0, %minIntCst : i8
  %3 = arith.maxui %arg0, %c0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// CHECK-LABEL: test_maxui
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MAX_INT_CST:.+]] = arith.constant -1
// CHECK: %[[X:.+]] = arith.maxui %arg0, %[[C0]]
// CHECK: return %arg0, %[[MAX_INT_CST]], %arg0, %[[X]]
func.func @test_maxui2(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 255 : i8
  %minIntCst = arith.constant 0 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.maxui %arg0, %arg0 : i8
  %1 = arith.maxui %maxIntCst, %arg0 : i8
  %2 = arith.maxui %minIntCst, %arg0 : i8
  %3 = arith.maxui %c0, %arg0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// -----

// CHECK-LABEL: test_minsi
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MIN_INT_CST:.+]] = arith.constant -128
// CHECK: %[[X:.+]] = arith.minsi %arg0, %[[C0]]
// CHECK: return %arg0, %arg0, %[[MIN_INT_CST]], %[[X]]
func.func @test_minsi(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 127 : i8
  %minIntCst = arith.constant -128 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.minsi %arg0, %arg0 : i8
  %1 = arith.minsi %arg0, %maxIntCst : i8
  %2 = arith.minsi %arg0, %minIntCst : i8
  %3 = arith.minsi %arg0, %c0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// CHECK-LABEL: test_minsi
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MIN_INT_CST:.+]] = arith.constant -128
// CHECK: %[[X:.+]] = arith.minsi %arg0, %[[C0]]
// CHECK: return %arg0, %arg0, %[[MIN_INT_CST]], %[[X]]
func.func @test_minsi2(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 127 : i8
  %minIntCst = arith.constant -128 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.minsi %arg0, %arg0 : i8
  %1 = arith.minsi %maxIntCst, %arg0 : i8
  %2 = arith.minsi %minIntCst, %arg0 : i8
  %3 = arith.minsi %c0, %arg0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// -----

// CHECK-LABEL: test_minui
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MIN_INT_CST:.+]] = arith.constant 0
// CHECK: %[[X:.+]] = arith.minui %arg0, %[[C0]]
// CHECK: return %arg0, %arg0, %[[MIN_INT_CST]], %[[X]]
func.func @test_minui(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 255 : i8
  %minIntCst = arith.constant 0 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.minui %arg0, %arg0 : i8
  %1 = arith.minui %arg0, %maxIntCst : i8
  %2 = arith.minui %arg0, %minIntCst : i8
  %3 = arith.minui %arg0, %c0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// CHECK-LABEL: test_minui
// CHECK-DAG: %[[C0:.+]] = arith.constant 42
// CHECK-DAG: %[[MIN_INT_CST:.+]] = arith.constant 0
// CHECK: %[[X:.+]] = arith.minui %arg0, %[[C0]]
// CHECK: return %arg0, %arg0, %[[MIN_INT_CST]], %[[X]]
func.func @test_minui2(%arg0 : i8) -> (i8, i8, i8, i8) {
  %maxIntCst = arith.constant 255 : i8
  %minIntCst = arith.constant 0 : i8
  %c0 = arith.constant 42 : i8
  %0 = arith.minui %arg0, %arg0 : i8
  %1 = arith.minui %maxIntCst, %arg0 : i8
  %2 = arith.minui %minIntCst, %arg0 : i8
  %3 = arith.minui %c0, %arg0 : i8
  return %0, %1, %2, %3: i8, i8, i8, i8
}

// -----

// CHECK-LABEL: @test_minimumf(
func.func @test_minimumf(%arg0 : f32) -> (f32, f32, f32) {
  // CHECK-DAG:   %[[C0:.+]] = arith.constant 0.0
  // CHECK-NEXT:  %[[X:.+]] = arith.minimumf %arg0, %[[C0]]
  // CHECK-NEXT:  return %[[X]], %arg0, %arg0
  %c0 = arith.constant 0.0 : f32
  %inf = arith.constant 0x7F800000 : f32
  %0 = arith.minimumf %c0, %arg0 : f32
  %1 = arith.minimumf %arg0, %arg0 : f32
  %2 = arith.minimumf %inf, %arg0 : f32
  return %0, %1, %2 : f32, f32, f32
}

// -----

// CHECK-LABEL: @test_maximumf(
func.func @test_maximumf(%arg0 : f32) -> (f32, f32, f32) {
  // CHECK-DAG:   %[[C0:.+]] = arith.constant
  // CHECK-NEXT:  %[[X:.+]] = arith.maximumf %arg0, %[[C0]]
  // CHECK-NEXT:   return %[[X]], %arg0, %arg0
  %c0 = arith.constant 0.0 : f32
  %-inf = arith.constant 0xFF800000 : f32
  %0 = arith.maximumf %c0, %arg0 : f32
  %1 = arith.maximumf %arg0, %arg0 : f32
  %2 = arith.maximumf %-inf, %arg0 : f32
  return %0, %1, %2 : f32, f32, f32
}

// -----

// CHECK-LABEL: @test_minnumf(
func.func @test_minnumf(%arg0 : f32) -> (f32, f32, f32, f32) {
  // CHECK-DAG:   %[[C0:.+]] = arith.constant 0.0
  // CHECK-DAG:   %[[INF:.+]] = arith.constant
  // CHECK-NEXT:  %[[X:.+]] = arith.minnumf %arg0, %[[C0]]
  // CHECK-NEXT:  %[[Y:.+]] = arith.minnumf %arg0, %[[INF]]
  // CHECK-NEXT:   return %[[X]], %arg0, %[[Y]], %arg0
  %c0 = arith.constant 0.0 : f32
  %inf = arith.constant 0x7F800000 : f32
  %nan = arith.constant 0x7FC00000 : f32
  %0 = arith.minnumf %c0, %arg0 : f32
  %1 = arith.minnumf %arg0, %arg0 : f32
  %2 = arith.minnumf %inf, %arg0 : f32
  %3 = arith.minnumf %nan, %arg0 : f32
  return %0, %1, %2, %3 : f32, f32, f32, f32
}

// -----

// CHECK-LABEL: @test_maxnumf(
func.func @test_maxnumf(%arg0 : f32) -> (f32, f32, f32, f32) {
  // CHECK-DAG:   %[[C0:.+]] = arith.constant 0.0
  // CHECK-DAG:   %[[NINF:.+]] = arith.constant
  // CHECK-NEXT:  %[[X:.+]] = arith.maxnumf %arg0, %[[C0]]
  // CHECK-NEXT:  %[[Y:.+]] = arith.maxnumf %arg0, %[[NINF]]
  // CHECK-NEXT:   return %[[X]], %arg0, %[[Y]], %arg0
  %c0 = arith.constant 0.0 : f32
  %-inf = arith.constant 0xFF800000 : f32
  %nan = arith.constant 0x7FC00000 : f32
  %0 = arith.maxnumf %c0, %arg0 : f32
  %1 = arith.maxnumf %arg0, %arg0 : f32
  %2 = arith.maxnumf %-inf, %arg0 : f32
  %3 = arith.maxnumf %nan, %arg0 : f32
  return %0, %1, %2, %3 : f32, f32, f32, f32
}

// -----

// CHECK-LABEL: @test_addf(
func.func @test_addf(%arg0 : f32) -> (f32, f32, f32, f32) {
  // CHECK-DAG:   %[[C2:.+]] = arith.constant 2.0
  // CHECK-DAG:   %[[C0:.+]] = arith.constant 0.0
  // CHECK-NEXT:  %[[X:.+]] = arith.addf %arg0, %[[C0]]
  // CHECK-NEXT:   return %[[X]], %arg0, %arg0, %[[C2]]
  %c0 = arith.constant 0.0 : f32
  %c-0 = arith.constant -0.0 : f32
  %c1 = arith.constant 1.0 : f32
  %0 = arith.addf %c0, %arg0 : f32
  %1 = arith.addf %arg0, %c-0 : f32
  %2 = arith.addf %c-0, %arg0 : f32
  %3 = arith.addf %c1, %c1 : f32
  return %0, %1, %2, %3 : f32, f32, f32, f32
}

// -----

// CHECK-LABEL: @test_subf(
func.func @test_subf(%arg0 : f16) -> (f16, f16, f16) {
  // CHECK-DAG:   %[[C1:.+]] = arith.constant -1.0
  // CHECK-DAG:   %[[C0:.+]] = arith.constant -0.0
  // CHECK-NEXT:  %[[X:.+]] = arith.subf %arg0, %[[C0]]
  // CHECK-NEXT:   return %arg0, %[[X]], %[[C1]]
  %c0 = arith.constant 0.0 : f16
  %c-0 = arith.constant -0.0 : f16
  %c1 = arith.constant 1.0 : f16
  %0 = arith.subf %arg0, %c0 : f16
  %1 = arith.subf %arg0, %c-0 : f16
  %2 = arith.subf %c0, %c1 : f16
  return %0, %1, %2 : f16, f16, f16
}

// -----

// CHECK-LABEL: @test_mulf(
func.func @test_mulf(%arg0 : f32) -> (f32, f32, f32, f32) {
  // CHECK-DAG:   %[[C2:.+]] = arith.constant 2.0
  // CHECK-DAG:   %[[C4:.+]] = arith.constant 4.0
  // CHECK-NEXT:  %[[X:.+]] = arith.mulf %arg0, %[[C2]]
  // CHECK-NEXT:  return %[[X]], %arg0, %arg0, %[[C4]]
  %c1 = arith.constant 1.0 : f32
  %c2 = arith.constant 2.0 : f32
  %0 = arith.mulf %c2, %arg0 : f32
  %1 = arith.mulf %arg0, %c1 : f32
  %2 = arith.mulf %c1, %arg0 : f32
  %3 = arith.mulf %c2, %c2 : f32
  return %0, %1, %2, %3 : f32, f32, f32, f32
}

// CHECK-LABEL: @test_mulf1(
func.func @test_mulf1(%arg0 : f32, %arg1 : f32) -> (f32) {
  // CHECK-NEXT:  %[[X:.+]] = arith.mulf %arg0, %arg1 : f32
  // CHECK-NEXT:  return %[[X]]
  %0 = arith.negf %arg0 : f32
  %1 = arith.negf %arg1 : f32
  %2 = arith.mulf %0, %1 : f32
  return %2 : f32
}

// -----

// CHECK-LABEL: @test_divf(
func.func @test_divf(%arg0 : f64) -> (f64, f64) {
  // CHECK-NEXT:  %[[C5:.+]] = arith.constant 5.000000e-01
  // CHECK-NEXT:   return %arg0, %[[C5]]
  %c1 = arith.constant 1.0 : f64
  %c2 = arith.constant 2.0 : f64
  %0 = arith.divf %arg0, %c1 : f64
  %1 = arith.divf %c1, %c2 : f64
  return %0, %1 : f64, f64
}

// CHECK-LABEL: @test_divf1(
func.func @test_divf1(%arg0 : f32, %arg1 : f32) -> (f32) {
  // CHECK-NEXT:  %[[X:.+]] = arith.divf %arg0, %arg1 : f32
  // CHECK-NEXT:  return %[[X]]
  %0 = arith.negf %arg0 : f32
  %1 = arith.negf %arg1 : f32
  %2 = arith.divf %0, %1 : f32
  return %2 : f32
}

// -----

func.func @fold_divui_of_muli_0(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 overflow<nuw> : index
  %1 = arith.divui %0, %arg0 : index
  return %1 : index
}
// CHECK-LABEL: func @fold_divui_of_muli_0(
//  CHECK-SAME:     %[[ARG0:.+]]: index,
//  CHECK-SAME:     %[[ARG1:.+]]: index)
//       CHECK:   return %[[ARG1]]

func.func @fold_divui_of_muli_1(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 overflow<nuw> : index
  %1 = arith.divui %0, %arg1 : index
  return %1 : index
}
// CHECK-LABEL: func @fold_divui_of_muli_1(
//  CHECK-SAME:     %[[ARG0:.+]]: index,
//  CHECK-SAME:     %[[ARG1:.+]]: index)
//       CHECK:   return %[[ARG0]]

func.func @fold_divsi_of_muli_0(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 overflow<nsw> : index
  %1 = arith.divsi %0, %arg0 : index
  return %1 : index
}
// CHECK-LABEL: func @fold_divsi_of_muli_0(
//  CHECK-SAME:     %[[ARG0:.+]]: index,
//  CHECK-SAME:     %[[ARG1:.+]]: index)
//       CHECK:   return %[[ARG1]]

func.func @fold_divsi_of_muli_1(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 overflow<nsw> : index
  %1 = arith.divsi %0, %arg1 : index
  return %1 : index
}
// CHECK-LABEL: func @fold_divsi_of_muli_1(
//  CHECK-SAME:     %[[ARG0:.+]]: index,
//  CHECK-SAME:     %[[ARG1:.+]]: index)
//       CHECK:   return %[[ARG0]]

// Do not fold divui(mul(a, v), v) -> a with nuw attribute.
func.func @no_fold_divui_of_muli(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 : index
  %1 = arith.divui %0, %arg0 : index
  return %1 : index
}
// CHECK-LABEL: func @no_fold_divui_of_muli
//       CHECK:   %[[T0:.+]] = arith.muli
//       CHECK:   %[[T1:.+]] = arith.divui %[[T0]],
//       CHECK:   return %[[T1]]

// Do not fold divsi(mul(a, v), v) -> a with nuw attribute.
func.func @no_fold_divsi_of_muli(%arg0 : index, %arg1 : index) -> index {
  %0 = arith.muli %arg0, %arg1 : index
  %1 = arith.divsi %0, %arg0 : index
  return %1 : index
}
// CHECK-LABEL: func @no_fold_divsi_of_muli
//       CHECK:   %[[T0:.+]] = arith.muli
//       CHECK:   %[[T1:.+]] = arith.divsi %[[T0]],
//       CHECK:   return %[[T1]]

// -----

// CHECK-LABEL: @test_cmpf(
func.func @test_cmpf(%arg0 : f32) -> (i1, i1, i1, i1) {
//   CHECK-DAG:   %[[T:.*]] = arith.constant true
//   CHECK-DAG:   %[[F:.*]] = arith.constant false
//       CHECK:   return %[[F]], %[[F]], %[[T]], %[[T]]
  %nan = arith.constant 0x7fffffff : f32
  %0 = arith.cmpf olt, %nan, %arg0 : f32
  %1 = arith.cmpf olt, %arg0, %nan : f32
  %2 = arith.cmpf ugt, %nan, %arg0 : f32
  %3 = arith.cmpf ugt, %arg0, %nan : f32
  return %0, %1, %2, %3 : i1, i1, i1, i1
}

// -----

// CHECK-LABEL: @constant_FPtoUI(
func.func @constant_FPtoUI() -> i32 {
  // CHECK: %[[C0:.+]] = arith.constant 2 : i32
  // CHECK: return %[[C0]]
  %c0 = arith.constant 2.0 : f32
  %res = arith.fptoui %c0 : f32 to i32
  return %res : i32
}

// CHECK-LABEL: @constant_FPtoUI_splat(
func.func @constant_FPtoUI_splat() -> vector<4xi32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<2> : vector<4xi32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant 2.0 : f32
  %splat = vector.splat %c0 : vector<4xf32>
  %res = arith.fptoui %splat : vector<4xf32> to vector<4xi32>
  return %res : vector<4xi32>
}

// CHECK-LABEL: @constant_FPtoUI_vector(
func.func @constant_FPtoUI_vector() -> vector<4xi32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<[1, 3, 5, 7]> : vector<4xi32>
  // CHECK: return %[[C0]]
  %vector = arith.constant dense<[1.0, 3.0, 5.0, 7.0]> : vector<4xf32>
  %res = arith.fptoui %vector : vector<4xf32> to vector<4xi32>
  return %res : vector<4xi32>
}

// -----
// CHECK-LABEL: @invalid_constant_FPtoUI(
func.func @invalid_constant_FPtoUI() -> i32 {
  // CHECK: %[[C0:.+]] = arith.constant -2.000000e+00 : f32
  // CHECK: %[[C1:.+]] = arith.fptoui %[[C0]] : f32 to i32
  // CHECK: return %[[C1]]
  %c0 = arith.constant -2.0 : f32
  %res = arith.fptoui %c0 : f32 to i32
  return %res : i32
}

// -----
// CHECK-LABEL: @constant_FPtoSI(
func.func @constant_FPtoSI() -> i32 {
  // CHECK: %[[C0:.+]] = arith.constant -2 : i32
  // CHECK: return %[[C0]]
  %c0 = arith.constant -2.0 : f32
  %res = arith.fptosi %c0 : f32 to i32
  return %res : i32
}

// CHECK-LABEL: @constant_FPtoSI_splat(
func.func @constant_FPtoSI_splat() -> vector<4xi32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<-2> : vector<4xi32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant -2.0 : f32
  %splat = vector.splat %c0 : vector<4xf32>
  %res = arith.fptosi %splat : vector<4xf32> to vector<4xi32>
  return %res : vector<4xi32>
}

// CHECK-LABEL: @constant_FPtoSI_vector(
func.func @constant_FPtoSI_vector() -> vector<4xi32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<[-1, -3, -5, -7]> : vector<4xi32>
  // CHECK: return %[[C0]]
  %vector = arith.constant dense<[-1.0, -3.0, -5.0, -7.0]> : vector<4xf32>
  %res = arith.fptosi %vector : vector<4xf32> to vector<4xi32>
  return %res : vector<4xi32>
}

// -----
// CHECK-LABEL: @invalid_constant_FPtoSI(
func.func @invalid_constant_FPtoSI() -> i8 {
  // CHECK: %[[C0:.+]] = arith.constant 2.000000e+10 : f32
  // CHECK: %[[C1:.+]] = arith.fptosi %[[C0]] : f32 to i8
  // CHECK: return %[[C1]]
  %c0 = arith.constant 2.0e10 : f32
  %res = arith.fptosi %c0 : f32 to i8
  return %res : i8
}

// CHECK-LABEL: @constant_SItoFP(
func.func @constant_SItoFP() -> f32 {
  // CHECK: %[[C0:.+]] = arith.constant -2.000000e+00 : f32
  // CHECK: return %[[C0]]
  %c0 = arith.constant -2 : i32
  %res = arith.sitofp %c0 : i32 to f32
  return %res : f32
}

// CHECK-LABEL: @constant_SItoFP_splat(
func.func @constant_SItoFP_splat() -> vector<4xf32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<2.000000e+00> : vector<4xf32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant 2 : i32
  %splat = vector.splat %c0 : vector<4xi32>
  %res = arith.sitofp %splat : vector<4xi32> to vector<4xf32>
  return %res : vector<4xf32>
}

// CHECK-LABEL: @constant_SItoFP_vector(
func.func @constant_SItoFP_vector() -> vector<4xf32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<[1.000000e+00, 3.000000e+00, 5.000000e+00, 7.000000e+00]> : vector<4xf32>
  // CHECK: return %[[C0]]
  %vector = arith.constant dense<[1, 3, 5, 7]> : vector<4xi32>
  %res = arith.sitofp %vector : vector<4xi32> to vector<4xf32>
  return %res : vector<4xf32>
}

// -----
// CHECK-LABEL: @constant_UItoFP(
func.func @constant_UItoFP() -> f32 {
  // CHECK: %[[C0:.+]] = arith.constant 2.000000e+00 : f32
  // CHECK: return %[[C0]]
  %c0 = arith.constant 2 : i32
  %res = arith.uitofp %c0 : i32 to f32
  return %res : f32
}

// CHECK-LABEL: @constant_UItoFP_splat(
func.func @constant_UItoFP_splat() -> vector<4xf32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<2.000000e+00> : vector<4xf32>
  // CHECK: return %[[C0]]
  %c0 = arith.constant 2 : i32
  %splat = vector.splat %c0 : vector<4xi32>
  %res = arith.uitofp %splat : vector<4xi32> to vector<4xf32>
  return %res : vector<4xf32>
}

// CHECK-LABEL: @constant_UItoFP_vector(
func.func @constant_UItoFP_vector() -> vector<4xf32> {
  // CHECK: %[[C0:.+]] = arith.constant dense<[1.000000e+00, 3.000000e+00, 5.000000e+00, 7.000000e+00]> : vector<4xf32>
  // CHECK: return %[[C0]]
  %vector = arith.constant dense<[1, 3, 5, 7]> : vector<4xi32>
  %res = arith.uitofp %vector : vector<4xi32> to vector<4xf32>
  return %res : vector<4xf32>
}

// -----

// Tests rewritten from https://github.com/llvm/llvm-project/blob/main/llvm/test/Transforms/InstCombine/2008-11-08-FCmp.ll
// When inst combining an FCMP with the LHS coming from a arith.uitofp instruction, we
// can lower it to signed ICMP instructions.

// CHECK-LABEL: @test1(
// CHECK-SAME: %[[arg0:.+]]:
func.func @test1(%arg0: i32) -> i1 {
  %cst = arith.constant 0.000000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf ole, %1, %cst : f64
  // CHECK: %[[c0:.+]] = arith.constant 0 : i32
  // CHECK: arith.cmpi ule, %[[arg0]], %[[c0]] : i32
  return %2 : i1
}

// CHECK-LABEL: @test2(
// CHECK-SAME: %[[arg0:.+]]:
func.func @test2(%arg0: i32) -> i1 {
  %cst = arith.constant 0.000000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf olt, %1, %cst : f64
  return %2 : i1
  // CHECK: %[[c0:.+]] = arith.constant 0 : i32
  // CHECK: arith.cmpi ult, %[[arg0]], %[[c0]] : i32
}

// CHECK-LABEL: @test3(
// CHECK-SAME: %[[arg0:.+]]:
func.func @test3(%arg0: i32) -> i1 {
  %cst = arith.constant 0.000000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf oge, %1, %cst : f64
  return %2 : i1
  // CHECK: %[[c0:.+]] = arith.constant 0 : i32
  // CHECK: arith.cmpi uge, %[[arg0]], %[[c0]] : i32
}

// CHECK-LABEL: @test4(
// CHECK-SAME: %[[arg0:.+]]:
func.func @test4(%arg0: i32) -> i1 {
  %cst = arith.constant 0.000000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf ogt, %1, %cst : f64
  // CHECK: %[[c0:.+]] = arith.constant 0 : i32
  // CHECK: arith.cmpi ugt, %[[arg0]], %[[c0]] : i32
  return %2 : i1
}

// CHECK-LABEL: @test5(
func.func @test5(%arg0: i32) -> i1 {
  %cst = arith.constant -4.400000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf ogt, %1, %cst : f64
  return %2 : i1
  // CHECK: %[[true:.+]] = arith.constant true
  // CHECK: return %[[true]] : i1
}

// CHECK-LABEL: @test6(
func.func @test6(%arg0: i32) -> i1 {
  %cst = arith.constant -4.400000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf olt, %1, %cst : f64
  return %2 : i1
  // CHECK: %[[false:.+]] = arith.constant false
  // CHECK: return %[[false]] : i1
}

// Check that optimizing unsigned >= comparisons correctly distinguishes
// positive and negative constants.
// CHECK-LABEL: @test7(
// CHECK-SAME: %[[arg0:.+]]:
func.func @test7(%arg0: i32) -> i1 {
  %cst = arith.constant 3.200000e+00 : f64
  %1 = arith.uitofp %arg0: i32 to f64
  %2 = arith.cmpf oge, %1, %cst : f64
  return %2 : i1
  // CHECK: %[[c3:.+]] = arith.constant 3 : i32
  // CHECK: arith.cmpi ugt, %[[arg0]], %[[c3]] : i32
}

// -----

// CHECK-LABEL: @foldShl(
// CHECK: %[[res:.+]] = arith.constant 4294967296 : i64
// CHECK: return %[[res]]
func.func @foldShl() -> i64 {
  %c1 = arith.constant 1 : i64
  %c32 = arith.constant 32 : i64
  %r = arith.shli %c1, %c32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShl(
// CHECK: %[[res:.+]] = arith.shli
// CHECK: return %[[res]]
func.func @nofoldShl() -> i64 {
  %c1 = arith.constant 1 : i64
  %c132 = arith.constant 132 : i64
  %r = arith.shli %c1, %c132 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShl2(
// CHECK: %[[res:.+]] = arith.shli
// CHECK: return %[[res]]
func.func @nofoldShl2() -> i64 {
  %c1 = arith.constant 1 : i64
  %cm32 = arith.constant -32 : i64
  %r = arith.shli %c1, %cm32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShl3(
// CHECK: %[[res:.+]] = arith.shli
// CHECK: return %[[res]]
func.func @nofoldShl3() -> i64 {
  %c1 = arith.constant 1 : i64
  %c64 = arith.constant 64 : i64
  // Note that this should return Poison in the future.
  %r = arith.shli %c1, %c64 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShru(
// CHECK: %[[res:.+]] = arith.constant 2 : i64
// CHECK: return %[[res]]
func.func @foldShru() -> i64 {
  %c1 = arith.constant 8 : i64
  %c32 = arith.constant 2 : i64
  %r = arith.shrui %c1, %c32 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShru2(
// CHECK: %[[res:.+]] = arith.constant 9223372036854775807 : i64
// CHECK: return %[[res]]
func.func @foldShru2() -> i64 {
  %c1 = arith.constant -2 : i64
  %c32 = arith.constant 1 : i64
  %r = arith.shrui %c1, %c32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShru(
// CHECK: %[[res:.+]] = arith.shrui
// CHECK: return %[[res]]
func.func @nofoldShru() -> i64 {
  %c1 = arith.constant 8 : i64
  %c132 = arith.constant 132 : i64
  %r = arith.shrui %c1, %c132 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShru2(
// CHECK: %[[res:.+]] = arith.shrui
// CHECK: return %[[res]]
func.func @nofoldShru2() -> i64 {
  %c1 = arith.constant 8 : i64
  %cm32 = arith.constant -32 : i64
  %r = arith.shrui %c1, %cm32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShru3(
// CHECK: %[[res:.+]] = arith.shrui
// CHECK: return %[[res]]
func.func @nofoldShru3() -> i64 {
  %c1 = arith.constant 8 : i64
  %c64 = arith.constant 64 : i64
  // Note that this should return Poison in the future.
  %r = arith.shrui %c1, %c64 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShrs(
// CHECK: %[[res:.+]] = arith.constant 2 : i64
// CHECK: return %[[res]]
func.func @foldShrs() -> i64 {
  %c1 = arith.constant 8 : i64
  %c32 = arith.constant 2 : i64
  %r = arith.shrsi %c1, %c32 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShrs2(
// CHECK: %[[res:.+]] = arith.constant -1 : i64
// CHECK: return %[[res]]
func.func @foldShrs2() -> i64 {
  %c1 = arith.constant -2 : i64
  %c32 = arith.constant 1 : i64
  %r = arith.shrsi %c1, %c32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShrs(
// CHECK: %[[res:.+]] = arith.shrsi
// CHECK: return %[[res]]
func.func @nofoldShrs() -> i64 {
  %c1 = arith.constant 8 : i64
  %c132 = arith.constant 132 : i64
  %r = arith.shrsi %c1, %c132 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShrs2(
// CHECK: %[[res:.+]] = arith.shrsi
// CHECK: return %[[res]]
func.func @nofoldShrs2() -> i64 {
  %c1 = arith.constant 8 : i64
  %cm32 = arith.constant -32 : i64
  %r = arith.shrsi %c1, %cm32 : i64
  return %r : i64
}

// CHECK-LABEL: @nofoldShrs3(
// CHECK: %[[res:.+]] = arith.shrsi
// CHECK: return %[[res]]
func.func @nofoldShrs3() -> i64 {
  %c1 = arith.constant 8 : i64
  %c64 = arith.constant 64 : i64
  // Note that this should return Poison in the future.
  %r = arith.shrsi %c1, %c64 : i64
  return %r : i64
}

// -----

// CHECK-LABEL: @test_negf(
// CHECK: %[[res:.+]] = arith.constant -2.0
// CHECK: return %[[res]]
func.func @test_negf() -> (f32) {
  %c = arith.constant 2.0 : f32
  %0 = arith.negf %c : f32
  return %0: f32
}

// CHECK-LABEL: @test_negf1(
// CHECK-SAME: %[[arg0:.+]]:
// CHECK: return %[[arg0]]
func.func @test_negf1(%f : f32) -> (f32) {
  %0 = arith.negf %f : f32
  %1 = arith.negf %0 : f32
  return %1: f32
}

// -----

// CHECK-LABEL: @test_remui(
// CHECK: %[[res:.+]] = arith.constant dense<[0, 0, 4, 2]> : vector<4xi32>
// CHECK: return %[[res]]
func.func @test_remui() -> (vector<4xi32>) {
  %v1 = arith.constant dense<[9, 9, 9, 9]> : vector<4xi32>
  %v2 = arith.constant dense<[1, 3, 5, 7]> : vector<4xi32>
  %0 = arith.remui %v1, %v2 : vector<4xi32>
  return %0 : vector<4xi32>
}

// // -----

// CHECK-LABEL: @test_remui_1(
// CHECK: %[[res:.+]] = arith.constant dense<0> : vector<4xi32>
// CHECK: return %[[res]]
func.func @test_remui_1(%arg : vector<4xi32>) -> (vector<4xi32>) {
  %v = arith.constant dense<[1, 1, 1, 1]> : vector<4xi32>
  %0 = arith.remui %arg, %v : vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

// CHECK-LABEL: @test_remsi(
// CHECK: %[[res:.+]] = arith.constant dense<[0, 0, 4, 2]> : vector<4xi32>
// CHECK: return %[[res]]
func.func @test_remsi() -> (vector<4xi32>) {
  %v1 = arith.constant dense<[9, 9, 9, 9]> : vector<4xi32>
  %v2 = arith.constant dense<[1, 3, 5, 7]> : vector<4xi32>
  %0 = arith.remsi %v1, %v2 : vector<4xi32>
  return %0 : vector<4xi32>
}

// // -----

// CHECK-LABEL: @test_remsi_1(
// CHECK: %[[res:.+]] = arith.constant dense<0> : vector<4xi32>
// CHECK: return %[[res]]
func.func @test_remsi_1(%arg : vector<4xi32>) -> (vector<4xi32>) {
  %v = arith.constant dense<[1, 1, 1, 1]> : vector<4xi32>
  %0 = arith.remsi %arg, %v : vector<4xi32>
  return %0 : vector<4xi32>
}

// -----

// CHECK-LABEL: @test_remf(
// CHECK: %[[res:.+]] = arith.constant 1.000000e+00 : f32
// CHECK: return %[[res]]
func.func @test_remf() -> (f32) {
  %v1 = arith.constant 3.0 : f32
  %v2 = arith.constant 2.0 : f32
  %0 = arith.remf %v1, %v2 : f32
  return %0 : f32
}

// CHECK-LABEL: @test_remf2(
// CHECK: %[[respos:.+]] = arith.constant 1.000000e+00 : f32
// CHECK: %[[resneg:.+]] = arith.constant -1.000000e+00 : f32
// CHECK: return %[[respos]], %[[resneg]]
func.func @test_remf2() -> (f32, f32) {
  %v1 = arith.constant 3.0 : f32
  %v2 = arith.constant -2.0 : f32
  %v3 = arith.constant -3.0 : f32
  %0 = arith.remf %v1, %v2 : f32
  %1 = arith.remf %v3, %v2 : f32
  return %0, %1 : f32, f32
}

// CHECK-LABEL: @test_remf_vec(
// CHECK: %[[res:.+]] = arith.constant dense<[1.000000e+00, 0.000000e+00, -1.000000e+00, 0.000000e+00]> : vector<4xf32>
// CHECK: return %[[res]]
func.func @test_remf_vec() -> (vector<4xf32>) {
  %v1 = arith.constant dense<[1.0, 2.0, -3.0, 4.0]> : vector<4xf32>
  %v2 = arith.constant dense<[2.0, 2.0, 2.0, 2.0]> : vector<4xf32>
  %0 = arith.remf %v1, %v2 : vector<4xf32>
  return %0 : vector<4xf32>
}

// -----

// CHECK-LABEL: @test_andi_not_fold_rhs(
// CHECK-SAME: %[[ARG0:[[:alnum:]]+]]
// CHECK: %[[C:.*]] = arith.constant 0 : index
// CHECK: return %[[C]]

func.func @test_andi_not_fold_rhs(%arg0 : index) -> index {
    %0 = arith.constant -1 : index
    %1 = arith.xori %arg0, %0 : index
    %2 = arith.andi %arg0, %1 : index
    return %2 : index
}


// CHECK-LABEL: @test_andi_not_fold_lhs(
// CHECK-SAME: %[[ARG0:[[:alnum:]]+]]
// CHECK: %[[C:.*]] = arith.constant 0 : index
// CHECK: return %[[C]]

func.func @test_andi_not_fold_lhs(%arg0 : index) -> index {
    %0 = arith.constant -1 : index
    %1 = arith.xori %arg0, %0 : index
    %2 = arith.andi %1, %arg0 : index
    return %2 : index
}

// -----

// CHECK-LABEL: @test_andi_not_fold_rhs_vec(
// CHECK-SAME: %[[ARG0:[[:alnum:]]+]]
// CHECK: %[[C:.*]] = arith.constant dense<0> : vector<2xi32>
// CHECK: return %[[C]]

func.func @test_andi_not_fold_rhs_vec(%arg0 : vector<2xi32>) -> vector<2xi32> {
    %0 = arith.constant dense<[-1, -1]> : vector<2xi32>
    %1 = arith.xori %arg0, %0 : vector<2xi32>
    %2 = arith.andi %arg0, %1 : vector<2xi32>
    return %2 : vector<2xi32>
}


// CHECK-LABEL: @test_andi_not_fold_lhs_vec(
// CHECK-SAME: %[[ARG0:[[:alnum:]]+]]
// CHECK: %[[C:.*]] = arith.constant dense<0> : vector<2xi32>
// CHECK: return %[[C]]

func.func @test_andi_not_fold_lhs_vec(%arg0 : vector<2xi32>) -> vector<2xi32> {
    %0 = arith.constant dense<[-1, -1]> : vector<2xi32>
    %1 = arith.xori %arg0, %0 : vector<2xi32>
    %2 = arith.andi %1, %arg0 : vector<2xi32>
    return %2 : vector<2xi32>
}

// -----
/// xor(xor(x, a), a) -> x

// CHECK-LABEL: @xorxor0(
//       CHECK-NOT: xori
//       CHECK:   return %arg0
func.func @xorxor0(%a : i32, %b : i32) -> i32 {
  %c = arith.xori %a, %b : i32
  %res = arith.xori %c, %b : i32
  return %res : i32
}

// -----
/// xor(xor(a, x), a) -> x

// CHECK-LABEL: @xorxor1(
//       CHECK-NOT: xori
//       CHECK:   return %arg0
func.func @xorxor1(%a : i32, %b : i32) -> i32 {
  %c = arith.xori %b, %a : i32
  %res = arith.xori %c, %b : i32
  return %res : i32
}

// -----
/// xor(a, xor(x, a)) -> x

// CHECK-LABEL: @xorxor2(
//       CHECK-NOT: xori
//       CHECK:   return %arg0
func.func @xorxor2(%a : i32, %b : i32) -> i32 {
  %c = arith.xori %a, %b : i32
  %res = arith.xori %b, %c : i32
  return %res : i32
}

// -----
/// xor(a, xor(a, x)) -> x

// CHECK-LABEL: @xorxor3(
//       CHECK-NOT: xori
//       CHECK:   return %arg0
func.func @xorxor3(%a : i32, %b : i32) -> i32 {
  %c = arith.xori %b, %a : i32
  %res = arith.xori %b, %c : i32
  return %res : i32
}

// -----

/// and(a, and(a, b)) -> and(a, b)

// CHECK-LABEL: @andand0
//  CHECK-SAME:   (%[[A:.*]]: i32, %[[B:.*]]: i32)
//       CHECK:   %[[RES:.*]] = arith.andi %[[A]], %[[B]] : i32
//       CHECK:   return %[[RES]]
func.func @andand0(%a : i32, %b : i32) -> i32 {
  %c = arith.andi %a, %b : i32
  %res = arith.andi %a, %c : i32
  return %res : i32
}

// CHECK-LABEL: @andand1
//  CHECK-SAME:   (%[[A:.*]]: i32, %[[B:.*]]: i32)
//       CHECK:   %[[RES:.*]] = arith.andi %[[A]], %[[B]] : i32
//       CHECK:   return %[[RES]]
func.func @andand1(%a : i32, %b : i32) -> i32 {
  %c = arith.andi %a, %b : i32
  %res = arith.andi %c, %a : i32
  return %res : i32
}

// CHECK-LABEL: @andand2
//  CHECK-SAME:   (%[[A:.*]]: i32, %[[B:.*]]: i32)
//       CHECK:   %[[RES:.*]] = arith.andi %[[A]], %[[B]] : i32
//       CHECK:   return %[[RES]]
func.func @andand2(%a : i32, %b : i32) -> i32 {
  %c = arith.andi %a, %b : i32
  %res = arith.andi %b, %c : i32
  return %res : i32
}

// CHECK-LABEL: @andand3
//  CHECK-SAME:   (%[[A:.*]]: i32, %[[B:.*]]: i32)
//       CHECK:   %[[RES:.*]] = arith.andi %[[A]], %[[B]] : i32
//       CHECK:   return %[[RES]]
func.func @andand3(%a : i32, %b : i32) -> i32 {
  %c = arith.andi %a, %b : i32
  %res = arith.andi %c, %b : i32
  return %res : i32
}

// -----

// CHECK-LABEL: @truncIShrSIToTrunciShrUI
//  CHECK-SAME:   (%[[A:.+]]: i64)
//  CHECK-NEXT:   %[[C32:.+]] = arith.constant 32 : i64
//  CHECK-NEXT:   %[[SHR:.+]] = arith.shrui %[[A]], %[[C32]] : i64
//  CHECK-NEXT:   %[[TRU:.+]] = arith.trunci %[[SHR]] : i64 to i32
//  CHECK-NEXT:   return %[[TRU]] : i32
func.func @truncIShrSIToTrunciShrUI(%a: i64) -> i32 {
  %c32 = arith.constant 32: i64
  %sh = arith.shrsi %a, %c32 : i64
  %hi = arith.trunci %sh: i64 to i32
  return %hi : i32
}

// CHECK-LABEL: @truncIShrSIToTrunciShrUIBadShiftAmt1
//       CHECK:   arith.shrsi
func.func @truncIShrSIToTrunciShrUIBadShiftAmt1(%a: i64) -> i32 {
  %c33 = arith.constant 33: i64
  %sh = arith.shrsi %a, %c33 : i64
  %hi = arith.trunci %sh: i64 to i32
  return %hi : i32
}

// CHECK-LABEL: @truncIShrSIToTrunciShrUIBadShiftAmt2
//  CHECK:        arith.shrsi
func.func @truncIShrSIToTrunciShrUIBadShiftAmt2(%a: i64) -> i32 {
  %c31 = arith.constant 31: i64
  %sh = arith.shrsi %a, %c31 : i64
  %hi = arith.trunci %sh: i64 to i32
  return %hi : i32
}

// CHECK-LABEL: @foldShli0
// CHECK-SAME: (%[[ARG:.*]]: i64)
//       CHECK:   return %[[ARG]] : i64
func.func @foldShli0(%x : i64) -> i64 {
  %c0 = arith.constant 0 : i64
  %r = arith.shli %x, %c0 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShrui0
// CHECK-SAME: (%[[ARG:.*]]: i64)
//       CHECK:   return %[[ARG]] : i64
func.func @foldShrui0(%x : i64) -> i64 {
  %c0 = arith.constant 0 : i64
  %r = arith.shrui %x, %c0 : i64
  return %r : i64
}

// CHECK-LABEL: @foldShrsi0
// CHECK-SAME: (%[[ARG:.*]]: i64)
//       CHECK:   return %[[ARG]] : i64
func.func @foldShrsi0(%x : i64) -> i64 {
  %c0 = arith.constant 0 : i64
  %r = arith.shrsi %x, %c0 : i64
  return %r : i64
}

// CHECK-LABEL: @foldOrXor1
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK:   %[[ONE:.*]] = arith.constant true
//       CHECK:   return %[[ONE]]
func.func @foldOrXor1(%arg0: i1) -> i1 {
  %0 = arith.constant true
  %1 = arith.xori %arg0, %0 : i1
  %2 = arith.ori %arg0, %1 : i1
  return %2 : i1
}

// CHECK-LABEL: @foldOrXor2
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK:   %[[ONE:.*]] = arith.constant true
//       CHECK:   return %[[ONE]]
func.func @foldOrXor2(%arg0: i1) -> i1 {
  %0 = arith.constant true
  %1 = arith.xori %0, %arg0 : i1
  %2 = arith.ori %arg0, %1 : i1
  return %2 : i1
}

// CHECK-LABEL: @foldOrXor3
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK:   %[[ONE:.*]] = arith.constant true
//       CHECK:   return %[[ONE]]
func.func @foldOrXor3(%arg0: i1) -> i1 {
  %0 = arith.constant true
  %1 = arith.xori %arg0, %0 : i1
  %2 = arith.ori %1, %arg0 : i1
  return %2 : i1
}

// CHECK-LABEL: @foldOrXor4
//  CHECK-SAME: (%[[ARG:.*]]: i1)
//       CHECK:   %[[ONE:.*]] = arith.constant true
//       CHECK:   return %[[ONE]]
func.func @foldOrXor4(%arg0: i1) -> i1 {
  %0 = arith.constant true
  %1 = arith.xori %0, %arg0 : i1
  %2 = arith.ori %1, %arg0 : i1
  return %2 : i1
}

// CHECK-LABEL: @foldOrXor5
//  CHECK-SAME: (%[[ARG:.*]]: i32)
//       CHECK:   %[[ONE:.*]] = arith.constant -1
//       CHECK:   return %[[ONE]]
func.func @foldOrXor5(%arg0: i32) -> i32 {
  %0 = arith.constant -1 : i32
  %1 = arith.xori %arg0, %0 : i32
  %2 = arith.ori %arg0, %1 : i32
  return %2 : i32
}

// CHECK-LABEL: @foldOrXor6
//  CHECK-SAME: (%[[ARG:.*]]: index)
//       CHECK:   %[[ONE:.*]] = arith.constant -1
//       CHECK:   return %[[ONE]]
func.func @foldOrXor6(%arg0: index) -> index {
  %0 = arith.constant -1 : index
  %1 = arith.xori %arg0, %0 : index
  %2 = arith.ori %arg0, %1 : index
  return %2 : index
}

// CHECK-LABEL: @selectOfPoison
// CHECK-SAME: %[[ARG:[[:alnum:]]+]]: i32
// CHECK: %[[UB:.*]] = ub.poison : i32
// CHECK: return %[[ARG]], %[[ARG]], %[[UB]], %[[ARG]]
func.func @selectOfPoison(%cond : i1, %arg: i32) -> (i32, i32, i32, i32) {
  %poison = ub.poison : i32
  %select1 = arith.select %cond, %poison, %arg : i32
  %select2 = arith.select %cond, %arg, %poison : i32

  // Check that constant folding is applied prior to poison handling.
  %true = arith.constant true
  %false = arith.constant false
  %select3 = arith.select %true, %poison, %arg : i32
  %select4 = arith.select %false, %poison, %arg : i32
  return %select1, %select2, %select3, %select4 : i32, i32, i32, i32
}

// CHECK-LABEL: @addi_poison1
//       CHECK:   %[[P:.*]] = ub.poison : i32
//       CHECK:   return %[[P]]
func.func @addi_poison1(%arg: i32) -> i32 {
  %0 = ub.poison : i32
  %1 = arith.addi %0, %arg : i32
  return %1 : i32
}

// CHECK-LABEL: @addi_poison2
//       CHECK:   %[[P:.*]] = ub.poison : i32
//       CHECK:   return %[[P]]
func.func @addi_poison2(%arg: i32) -> i32 {
  %0 = ub.poison : i32
  %1 = arith.addi %arg, %0 : i32
  return %1 : i32
}

// CHECK-LABEL: @addf_poison1
//       CHECK:   %[[P:.*]] = ub.poison : f32
//       CHECK:   return %[[P]]
func.func @addf_poison1(%arg: f32) -> f32 {
  %0 = ub.poison : f32
  %1 = arith.addf %0, %arg : f32
  return %1 : f32
}

// CHECK-LABEL: @addf_poison2
//       CHECK:   %[[P:.*]] = ub.poison : f32
//       CHECK:   return %[[P]]
func.func @addf_poison2(%arg: f32) -> f32 {
  %0 = ub.poison : f32
  %1 = arith.addf %arg, %0 : f32
  return %1 : f32
}


// CHECK-LABEL: @negf_poison
//       CHECK:   %[[P:.*]] = ub.poison : f32
//       CHECK:   return %[[P]]
func.func @negf_poison() -> f32 {
  %0 = ub.poison : f32
  %1 = arith.negf %0 : f32
  return %1 : f32
}

// CHECK-LABEL: @extsi_poison
//       CHECK:   %[[P:.*]] = ub.poison : i64
//       CHECK:   return %[[P]]
func.func @extsi_poison() -> i64 {
  %0 = ub.poison : i32
  %1 = arith.extsi %0 : i32 to i64
  return %1 : i64
}

// Just checks that this doesn't crash.
// CHECK-LABEL: @unsignedExtendConstantResource
func.func @unsignedExtendConstantResource() -> tensor<i16> {
  %c2 = arith.constant dense_resource<blob1> : tensor<i8>
  %ext = arith.extui %c2 : tensor<i8> to tensor<i16>
  return %ext : tensor<i16>
}

// CHECK-LABEL: @extsi_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i16
//       CHECK:   return %[[ZERO]] : i16
func.func @extsi_i0() -> i16 {
  %c0 = arith.constant 0 : i0
  %extsi = arith.extsi %c0 : i0 to i16
  return %extsi : i16
}

// CHECK-LABEL: @extui_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i16
//       CHECK:   return %[[ZERO]] : i16
func.func @extui_i0() -> i16 {
  %c0 = arith.constant 0 : i0
  %extui = arith.extui %c0 : i0 to i16
  return %extui : i16
}

// CHECK-LABEL: @trunc_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @trunc_i0() -> i0 {
  %cFF = arith.constant 0xFF : i8
  %trunc = arith.trunci %cFF : i8 to i0
  return %trunc : i0
}

// CHECK-LABEL: @shli_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @shli_i0() -> i0 {
  %c0 = arith.constant 0 : i0
  %shli = arith.shli %c0, %c0 : i0
  return %shli : i0
}

// CHECK-LABEL: @shrsi_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @shrsi_i0() -> i0 {
  %c0 = arith.constant 0 : i0
  %shrsi = arith.shrsi %c0, %c0 : i0
  return %shrsi : i0
}

// CHECK-LABEL: @shrui_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @shrui_i0() -> i0 {
  %c0 = arith.constant 0 : i0
  %shrui = arith.shrui %c0, %c0 : i0
  return %shrui : i0
}

// CHECK-LABEL: @maxsi_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @maxsi_i0() -> i0 {
  %c0 = arith.constant 0 : i0
  %maxsi = arith.maxsi %c0, %c0 : i0
  return %maxsi : i0
}

// CHECK-LABEL: @minsi_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]] : i0
func.func @minsi_i0() -> i0 {
  %c0 = arith.constant 0 : i0
  %minsi = arith.minsi %c0, %c0 : i0
  return %minsi : i0
}

// CHECK-LABEL: @mulsi_extended_i0
//       CHECK:   %[[ZERO:.*]] = arith.constant 0 : i0
//       CHECK:   return %[[ZERO]], %[[ZERO]] : i0
func.func @mulsi_extended_i0() -> (i0, i0) {
  %c0 = arith.constant 0 : i0
  %mulsi_extended:2 = arith.mulsi_extended %c0, %c0 : i0
  return %mulsi_extended#0, %mulsi_extended#1 : i0, i0
}

// CHECK-LABEL: @sequences_fastmath_contract
// CHECK-SAME: ([[ARG0:%.+]]: bf16)
// CHECK: [[EXTF:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF]]
// CHECK: [[SIN:%.+]] = math.sin [[ABSF]]
// CHECK: [[TRUNCF:%.+]] = arith.truncf [[SIN]]
// CHECK: return [[TRUNCF]] : bf16
func.func @sequences_fastmath_contract(%arg0: bf16) -> bf16 {
  %0 = arith.extf %arg0 fastmath<contract> : bf16 to f32
  %1 = math.absf %0 : f32
  %2 = arith.truncf %1 fastmath<contract> : f32 to bf16
  %3 = arith.extf %2 fastmath<contract> : bf16 to f32
  %4 = math.sin %3 : f32
  %5 = arith.truncf %4 fastmath<contract> : f32 to bf16
  return %5 : bf16
}

// CHECK-LABEL: @sequences_no_fastmath
// CHECK-SAME: ([[ARG0:%.+]]: bf16)
// CHECK: [[EXTF:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF]]
// CHECK: [[TRUNCF1:%.+]] = arith.truncf [[ABSF]]
// CHECK: [[EXTF1:%.+]] = arith.extf [[TRUNCF1]]
// CHECK: [[SIN:%.+]] = math.sin [[EXTF1]]
// CHECK: [[TRUNCF:%.+]] = arith.truncf [[SIN]]
// CHECK: return [[TRUNCF]] : bf16
func.func @sequences_no_fastmath(%arg0: bf16) -> bf16 {
  %0 = arith.extf %arg0 : bf16 to f32
  %1 = math.absf %0 : f32
  %2 = arith.truncf %1 : f32 to bf16
  %3 = arith.extf %2 : bf16 to f32
  %4 = math.sin %3 : f32
  %5 = arith.truncf %4 : f32 to bf16
  return %5 : bf16
}

// CHECK-LABEL: @eliminate_cast_to_f16
// CHECK: return [[arg0:%.+]] : f32
func.func @eliminate_cast_to_f16(%arg0: f32) -> f32 {
  %0 = arith.truncf %arg0 fastmath<contract> : f32 to f16
  %1 = arith.extf %0 fastmath<contract> : f16 to f32
  return %1 : f32
}

// CHECK-LABEL: @eliminate_cast_to_bf16
// CHECK: return [[arg0:%.+]] : f32
func.func @eliminate_cast_to_bf16(%arg0: f32) -> f32 {
  %0 = arith.truncf %arg0 fastmath<contract> : f32 to bf16
  %1 = arith.extf %0 fastmath<contract> : bf16 to f32
  return %1 : f32
}

// CHECK-LABEL: @bf16_sin_vector
// CHECK-SAME: ([[ARG0:%.+]]: vector<32x32x32xbf16>)
// CHECK: [[EXTF:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF]]
// CHECK: [[SIN:%.+]] = math.sin [[ABSF]]
// CHECK: [[TRUNCF:%.+]] = arith.truncf [[SIN]]
// CHECK: return [[TRUNCF]] : vector<32x32x32xbf16>
func.func @bf16_sin_vector(%arg0: vector<32x32x32xbf16>) -> vector<32x32x32xbf16> {
  %0 = arith.extf %arg0 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %1 = math.absf %0 : vector<32x32x32xf32>
  %2 = arith.truncf %1 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %3 = arith.extf %2 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %4 = math.sin %3 : vector<32x32x32xf32>
  %5 = arith.truncf %4 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  return %5 : vector<32x32x32xbf16>
}

// CHECK-LABEL: @f16_sin_vector
// CHECK-SAME: ([[ARG0:%.+]]: vector<32x32x32xf16>)
// CHECK: [[EXTF:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF]]
// CHECK: [[SIN:%.+]] = math.sin [[ABSF]]
// CHECK: [[TRUNCF:%.+]] = arith.truncf [[SIN]]
// CHECK: return [[TRUNCF]] : vector<32x32x32xf16>
func.func @f16_sin_vector(%arg0: vector<32x32x32xf16>) -> vector<32x32x32xf16> {
  %0 = arith.extf %arg0 fastmath<contract> : vector<32x32x32xf16> to vector<32x32x32xf32>
  %1 = math.absf %0 : vector<32x32x32xf32>
  %2 = arith.truncf %1 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xf16>
  %3 = arith.extf %2 fastmath<contract> : vector<32x32x32xf16> to vector<32x32x32xf32>
  %4 = math.sin %3 : vector<32x32x32xf32>
  %5 = arith.truncf %4 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xf16>
  return %5 : vector<32x32x32xf16>
}

// CHECK-LABEL: @bf16_branch_vector
// CHECK-SAME: ([[ARG0:%.+]]: vector<32x32x32xbf16>)
// CHECK: [[EXTF:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF]]
// CHECK-DAG: [[SIN:%.+]] = math.sin [[ABSF]]
// CHECK-DAG: [[COS:%.+]] = math.cos [[ABSF]]
// CHECK: [[ADDF:%.+]] = arith.addf [[SIN]], [[COS]]
// CHECK: [[TRUNCF:%.+]] = arith.truncf [[ADDF]]
// CHECK: return [[TRUNCF]] : vector<32x32x32xbf16>
func.func @bf16_branch_vector(%arg0: vector<32x32x32xbf16>) -> vector<32x32x32xbf16> {
  %0 = arith.extf %arg0 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %1 = math.absf %0 : vector<32x32x32xf32>
  %2 = arith.truncf %1 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %3 = arith.extf %2 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %4 = math.sin %3 : vector<32x32x32xf32>
  %5 = arith.truncf %4 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %6 = arith.extf %5 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %7 = math.cos %3 : vector<32x32x32xf32>
  %8 = arith.truncf %7 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %9 = arith.extf %8 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %10 = arith.addf %6, %9 : vector<32x32x32xf32>
  %11 = arith.truncf %10 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  return %11 : vector<32x32x32xbf16>
}

// CHECK-LABEL: @bf16_fma
// CHECK-SAME: ([[ARG0:%.+]]: vector<32x32x32xbf16>, [[ARG1:%.+]]: vector<32x32x32xbf16>, [[ARG2:%.+]]: vector<32x32x32xbf16>)
// CHECK: [[EXTF0:%.+]] = arith.extf [[ARG0]]
// CHECK: [[ABSF:%.+]] = math.absf [[EXTF0]]
// CHECK-DAG: [[SIN:%.+]] = math.sin [[ABSF]]
// CHECK: [[TRUNCF0:%.+]] = arith.truncf [[SIN]]
// CHECK-DAG: [[FMA:%.+]] = math.fma [[TRUNCF0]], [[ARG1]], [[ARG2]]
// CHECK: [[EXTF1:%.+]] = arith.extf [[FMA]]
// CHECK: [[ADDF:%.+]] = arith.addf [[EXTF1]], [[SIN]]
// CHECK: [[TRUNCF1:%.+]] = arith.truncf [[ADDF]]
// CHECK: return [[TRUNCF1]] : vector<32x32x32xbf16>
func.func @bf16_fma(%arg0: vector<32x32x32xbf16>, %arg1: vector<32x32x32xbf16>, %arg2: vector<32x32x32xbf16>) -> vector<32x32x32xbf16> {
  %0 = arith.extf %arg0 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %1 = math.absf %0 : vector<32x32x32xf32>
  %2 = arith.truncf %1 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %3 = arith.extf %2 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %4 = math.sin %3 : vector<32x32x32xf32>
  %5 = arith.truncf %4 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  %6 = arith.extf %5 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %7 = math.fma %5, %arg1, %arg2 : vector<32x32x32xbf16>
  %8 = arith.extf %7 fastmath<contract> : vector<32x32x32xbf16> to vector<32x32x32xf32>
  %9 = arith.addf %8, %6 : vector<32x32x32xf32>
  %10 = arith.truncf %9 fastmath<contract> : vector<32x32x32xf32> to vector<32x32x32xbf16>
  return %10 : vector<32x32x32xbf16>
}

{-#
  dialect_resources: {
    builtin: {
      // Note: This is just copied blob, the actual value isn't used or checked.
      blob1: "0x08000000010000000000000002000000000000000300000000000000"
    }
  }
#-}

; NOTE: Assertions have been autogenerated by utils/update_analyze_test_checks.py UTC_ARGS: --version 5
; RUN: opt < %s -mtriple=aarch64--linux-gnu -passes="print<cost-model>" 2>&1 -disable-output | FileCheck %s --check-prefix=COST

target datalayout = "e-m:e-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128"

define <8 x i8> @sel_v8i8(<8 x i8> %v0, <8 x i8> %v1) {
; COST-LABEL: 'sel_v8i8'
; COST-NEXT:  Cost Model: Found an estimated cost of 28 for instruction: %tmp0 = shufflevector <8 x i8> %v0, <8 x i8> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i8> %tmp0
;
  %tmp0 = shufflevector <8 x i8> %v0, <8 x i8> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x i8> %tmp0
}

define <16 x i8> @sel_v16i8(<16 x i8> %v0, <16 x i8> %v1) {
; COST-LABEL: 'sel_v16i8'
; COST-NEXT:  Cost Model: Found an estimated cost of 60 for instruction: %tmp0 = shufflevector <16 x i8> %v0, <16 x i8> %v1, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <16 x i8> %tmp0
;
  %tmp0 = shufflevector <16 x i8> %v0, <16 x i8> %v1, <16 x i32> <i32 0, i32 17, i32 2, i32 19, i32 4, i32 21, i32 6, i32 23, i32 8, i32 25, i32 10, i32 27, i32 12, i32 29, i32 14, i32 31>
  ret <16 x i8> %tmp0
}

define <4 x i16> @sel_v4i16(<4 x i16> %v0, <4 x i16> %v1) {
; COST-LABEL: 'sel_v4i16'
; COST-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %tmp0 = shufflevector <4 x i16> %v0, <4 x i16> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i16> %tmp0
;
  %tmp0 = shufflevector <4 x i16> %v0, <4 x i16> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x i16> %tmp0
}

define <8 x i16> @sel_v8i16(<8 x i16> %v0, <8 x i16> %v1) {
; COST-LABEL: 'sel_v8i16'
; COST-NEXT:  Cost Model: Found an estimated cost of 28 for instruction: %tmp0 = shufflevector <8 x i16> %v0, <8 x i16> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x i16> %tmp0
;
  %tmp0 = shufflevector <8 x i16> %v0, <8 x i16> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x i16> %tmp0
}

define <2 x i32> @sel_v2i32(<2 x i32> %v0, <2 x i32> %v1) {
; COST-LABEL: 'sel_v2i32'
; COST-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %tmp0 = shufflevector <2 x i32> %v0, <2 x i32> %v1, <2 x i32> <i32 0, i32 3>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i32> %tmp0
;
  %tmp0 = shufflevector <2 x i32> %v0, <2 x i32> %v1, <2 x i32> <i32 0, i32 3>
  ret <2 x i32> %tmp0
}

define <4 x i32> @sel_v4i32(<4 x i32> %v0, <4 x i32> %v1) {
; COST-LABEL: 'sel_v4i32'
; COST-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %tmp0 = shufflevector <4 x i32> %v0, <4 x i32> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x i32> %tmp0
;
  %tmp0 = shufflevector <4 x i32> %v0, <4 x i32> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x i32> %tmp0
}

define <2 x i64> @sel_v2i64(<2 x i64> %v0, <2 x i64> %v1) {
; COST-LABEL: 'sel_v2i64'
; COST-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %tmp0 = shufflevector <2 x i64> %v0, <2 x i64> %v1, <2 x i32> <i32 0, i32 3>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x i64> %tmp0
;
  %tmp0 = shufflevector <2 x i64> %v0, <2 x i64> %v1, <2 x i32> <i32 0, i32 3>
  ret <2 x i64> %tmp0
}

define <4 x half> @sel_v4f16(<4 x half> %v0, <4 x half> %v1) {
; COST-LABEL: 'sel_v4f16'
; COST-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %tmp0 = shufflevector <4 x half> %v0, <4 x half> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x half> %tmp0
;
  %tmp0 = shufflevector <4 x half> %v0, <4 x half> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x half> %tmp0
}

define <8 x half> @sel_v8f16(<8 x half> %v0, <8 x half> %v1) {
; COST-LABEL: 'sel_v8f16'
; COST-NEXT:  Cost Model: Found an estimated cost of 28 for instruction: %tmp0 = shufflevector <8 x half> %v0, <8 x half> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <8 x half> %tmp0
;
  %tmp0 = shufflevector <8 x half> %v0, <8 x half> %v1, <8 x i32> <i32 0, i32 9, i32 2, i32 11, i32 4, i32 13, i32 6, i32 15>
  ret <8 x half> %tmp0
}

define <2 x float> @sel_v2f32(<2 x float> %v0, <2 x float> %v1) {
; COST-LABEL: 'sel_v2f32'
; COST-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %tmp0 = shufflevector <2 x float> %v0, <2 x float> %v1, <2 x i32> <i32 0, i32 3>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x float> %tmp0
;
  %tmp0 = shufflevector <2 x float> %v0, <2 x float> %v1, <2 x i32> <i32 0, i32 3>
  ret <2 x float> %tmp0
}

define <4 x float> @sel_v4f32(<4 x float> %v0, <4 x float> %v1) {
; COST-LABEL: 'sel_v4f32'
; COST-NEXT:  Cost Model: Found an estimated cost of 2 for instruction: %tmp0 = shufflevector <4 x float> %v0, <4 x float> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <4 x float> %tmp0
;
  %tmp0 = shufflevector <4 x float> %v0, <4 x float> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x float> %tmp0
}

define <2 x double> @sel_v2f64(<2 x double> %v0, <2 x double> %v1) {
; COST-LABEL: 'sel_v2f64'
; COST-NEXT:  Cost Model: Found an estimated cost of 1 for instruction: %tmp0 = shufflevector <2 x double> %v0, <2 x double> %v1, <2 x i32> <i32 0, i32 3>
; COST-NEXT:  Cost Model: Found an estimated cost of 0 for instruction: ret <2 x double> %tmp0
;
  %tmp0 = shufflevector <2 x double> %v0, <2 x double> %v1, <2 x i32> <i32 0, i32 3>
  ret <2 x double> %tmp0
}

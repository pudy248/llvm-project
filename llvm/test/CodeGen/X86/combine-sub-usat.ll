; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.1 | FileCheck %s --check-prefixes=CHECK,SSE,SSE41
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+sse4.2 | FileCheck %s --check-prefixes=CHECK,SSE,SSE42
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx | FileCheck %s --check-prefixes=CHECK,AVX,AVX1
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx2 | FileCheck %s --check-prefixes=CHECK,AVX,AVX2
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512f | FileCheck %s --check-prefixes=CHECK,AVX,AVX512
; RUN: llc < %s -mtriple=x86_64-unknown-unknown -mattr=+avx512bw | FileCheck %s --check-prefixes=CHECK,AVX,AVX512

declare  i32 @llvm.usub.sat.i32  (i32, i32)
declare  i64 @llvm.usub.sat.i64  (i64, i64)
declare  <8 x i16> @llvm.usub.sat.v8i16(<8 x i16>, <8 x i16>)
declare  <8 x i32> @llvm.usub.sat.v8i32(<8 x i32>, <8 x i32>)

; fold (usub_sat x, undef) -> 0
define i32 @combine_undef_i32(i32 %a0) {
; CHECK-LABEL: combine_undef_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
  %res = call i32 @llvm.usub.sat.i32(i32 %a0, i32 undef)
  ret i32 %res
}

define <8 x i16> @combine_undef_v8i16(<8 x i16> %a0) {
; SSE-LABEL: combine_undef_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_undef_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> undef, <8 x i16> %a0)
  ret <8 x i16> %res
}

; fold (usub_sat c1, c2) -> c3
define i32 @combine_constfold_i32() {
; CHECK-LABEL: combine_constfold_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
  %res = call i32 @llvm.usub.sat.i32(i32 100, i32 4294967295)
  ret i32 %res
}

define <8 x i16> @combine_constfold_v8i16() {
; SSE-LABEL: combine_constfold_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [0,0,254,0,65534,0,0,0]
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_constfold_v8i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovaps {{.*#+}} xmm0 = [0,0,254,0,65534,0,0,0]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_constfold_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovaps {{.*#+}} xmm0 = [0,0,254,0,65534,0,0,0]
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_constfold_v8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovzxwd {{.*#+}} xmm0 = [0,254,65534,0]
; AVX512-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> <i16 0, i16 1, i16 255, i16 65535, i16 -1, i16 -255, i16 -65535, i16 1>, <8 x i16> <i16 1, i16 65535, i16 1, i16 65535, i16 1, i16 65535, i16 1, i16 65535>)
  ret <8 x i16> %res
}

define <8 x i16> @combine_constfold_undef_v8i16() {
; SSE-LABEL: combine_constfold_undef_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    movaps {{.*#+}} xmm0 = [0,0,u,0,65534,0,0,0]
; SSE-NEXT:    retq
;
; AVX1-LABEL: combine_constfold_undef_v8i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vmovaps {{.*#+}} xmm0 = [0,0,u,0,65534,0,0,0]
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_constfold_undef_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vmovaps {{.*#+}} xmm0 = [0,0,u,0,65534,0,0,0]
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_constfold_undef_v8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    vpmovzxwq {{.*#+}} xmm0 = [0,65534]
; AVX512-NEXT:    retq
  %res = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> <i16 undef, i16 1, i16 undef, i16 65535, i16 -1, i16 -255, i16 -65535, i16 1>, <8 x i16> <i16 1, i16 undef, i16 undef, i16 65535, i16 1, i16 65535, i16 1, i16 65535>)
  ret <8 x i16> %res
}

; fold (usub_sat x, 0) -> x
define i32 @combine_zero_i32(i32 %a0) {
; CHECK-LABEL: combine_zero_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movl %edi, %eax
; CHECK-NEXT:    retq
  %1 = call i32 @llvm.usub.sat.i32(i32 %a0, i32 0)
  ret i32 %1
}

define <8 x i16> @combine_zero_v8i16(<8 x i16> %a0) {
; CHECK-LABEL: combine_zero_v8i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    retq
  %1 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %a0, <8 x i16> zeroinitializer)
  ret <8 x i16> %1
}

; fold (usub_sat x, x) -> 0
define i32 @combine_self_i32(i32 %a0) {
; CHECK-LABEL: combine_self_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    retq
  %1 = call i32 @llvm.usub.sat.i32(i32 %a0, i32 %a0)
  ret i32 %1
}

define <8 x i16> @combine_self_v8i16(<8 x i16> %a0) {
; SSE-LABEL: combine_self_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    xorps %xmm0, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_self_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vxorps %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %a0, <8 x i16> %a0)
  ret <8 x i16> %1
}

; fold (usub_sat x, y) -> (sub x, y) iff no overflow
define i32 @combine_no_overflow_i32(i32 %a0, i32 %a1) {
; CHECK-LABEL: combine_no_overflow_i32:
; CHECK:       # %bb.0:
; CHECK-NEXT:    shrl $16, %edi
; CHECK-NEXT:    shrl $16, %esi
; CHECK-NEXT:    xorl %eax, %eax
; CHECK-NEXT:    subl %esi, %edi
; CHECK-NEXT:    cmovael %edi, %eax
; CHECK-NEXT:    retq
  %1 = lshr i32 %a0, 16
  %2 = lshr i32 %a1, 16
  %3 = call i32 @llvm.usub.sat.i32(i32 %1, i32 %2)
  ret i32 %3
}

define <8 x i16> @combine_no_overflow_v8i16(<8 x i16> %a0, <8 x i16> %a1) {
; SSE-LABEL: combine_no_overflow_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    psrlw $10, %xmm0
; SSE-NEXT:    psrlw $10, %xmm1
; SSE-NEXT:    psubusw %xmm1, %xmm0
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_no_overflow_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsrlw $10, %xmm0, %xmm0
; AVX-NEXT:    vpsrlw $10, %xmm1, %xmm1
; AVX-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = lshr <8 x i16> %a0, <i16 10, i16 10, i16 10, i16 10, i16 10, i16 10, i16 10, i16 10>
  %2 = lshr <8 x i16> %a1, <i16 10, i16 10, i16 10, i16 10, i16 10, i16 10, i16 10, i16 10>
  %3 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %1, <8 x i16> %2)
  ret <8 x i16> %3
}

; FIXME: fold (trunc (usub_sat zext(x), y)) -> usub_sat(x, trunc(umin(y,satlimit)))
define i16 @combine_trunc_i32_i16(i16 %a0, i32 %a1) {
; CHECK-LABEL: combine_trunc_i32_i16:
; CHECK:       # %bb.0:
; CHECK-NEXT:    movzwl %di, %eax
; CHECK-NEXT:    xorl %ecx, %ecx
; CHECK-NEXT:    subl %esi, %eax
; CHECK-NEXT:    cmovbl %ecx, %eax
; CHECK-NEXT:    # kill: def $ax killed $ax killed $eax
; CHECK-NEXT:    retq
  %1 = zext i16 %a0 to i32
  %2 = call i32 @llvm.usub.sat.i32(i32 %1, i32 %a1)
  %3 = trunc i32 %2 to i16
  ret i16 %3
}

define <8 x i8> @combine_trunc_v8i16_v8i8(<8 x i8> %a0, <8 x i16> %a1) {
; SSE2-LABEL: combine_trunc_v8i16_v8i8:
; SSE2:       # %bb.0:
; SSE2-NEXT:    pxor %xmm2, %xmm2
; SSE2-NEXT:    punpcklbw {{.*#+}} xmm0 = xmm0[0],xmm2[0],xmm0[1],xmm2[1],xmm0[2],xmm2[2],xmm0[3],xmm2[3],xmm0[4],xmm2[4],xmm0[5],xmm2[5],xmm0[6],xmm2[6],xmm0[7],xmm2[7]
; SSE2-NEXT:    psubusw %xmm1, %xmm0
; SSE2-NEXT:    packuswb %xmm0, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_trunc_v8i16_v8i8:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE41-NEXT:    psubusw %xmm1, %xmm0
; SSE41-NEXT:    packuswb %xmm0, %xmm0
; SSE41-NEXT:    retq
;
; SSE42-LABEL: combine_trunc_v8i16_v8i8:
; SSE42:       # %bb.0:
; SSE42-NEXT:    pmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; SSE42-NEXT:    psubusw %xmm1, %xmm0
; SSE42-NEXT:    packuswb %xmm0, %xmm0
; SSE42-NEXT:    retq
;
; AVX-LABEL: combine_trunc_v8i16_v8i8:
; AVX:       # %bb.0:
; AVX-NEXT:    vpmovzxbw {{.*#+}} xmm0 = xmm0[0],zero,xmm0[1],zero,xmm0[2],zero,xmm0[3],zero,xmm0[4],zero,xmm0[5],zero,xmm0[6],zero,xmm0[7],zero
; AVX-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpackuswb %xmm0, %xmm0, %xmm0
; AVX-NEXT:    retq
  %1 = zext <8 x i8> %a0 to <8 x i16>
  %2 = call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %1, <8 x i16> %a1)
  %3 = trunc <8 x i16> %2 to <8 x i8>
  ret <8 x i8> %3
}

define <8 x i16> @combine_trunc_v8i32_v8i16(<8 x i16> %a0, <8 x i32> %a1) {
; SSE2-LABEL: combine_trunc_v8i32_v8i16:
; SSE2:       # %bb.0:
; SSE2-NEXT:    movdqa {{.*#+}} xmm3 = [2147483648,2147483648,2147483648,2147483648]
; SSE2-NEXT:    movdqa %xmm2, %xmm4
; SSE2-NEXT:    pxor %xmm3, %xmm4
; SSE2-NEXT:    movdqa {{.*#+}} xmm5 = [2147549183,2147549183,2147549183,2147549183]
; SSE2-NEXT:    movdqa %xmm5, %xmm6
; SSE2-NEXT:    pcmpgtd %xmm4, %xmm6
; SSE2-NEXT:    pcmpeqd %xmm4, %xmm4
; SSE2-NEXT:    pand %xmm6, %xmm2
; SSE2-NEXT:    pxor %xmm4, %xmm6
; SSE2-NEXT:    por %xmm2, %xmm6
; SSE2-NEXT:    pslld $16, %xmm6
; SSE2-NEXT:    psrad $16, %xmm6
; SSE2-NEXT:    pxor %xmm1, %xmm3
; SSE2-NEXT:    pcmpgtd %xmm3, %xmm5
; SSE2-NEXT:    pxor %xmm5, %xmm4
; SSE2-NEXT:    pand %xmm1, %xmm5
; SSE2-NEXT:    por %xmm4, %xmm5
; SSE2-NEXT:    pslld $16, %xmm5
; SSE2-NEXT:    psrad $16, %xmm5
; SSE2-NEXT:    packssdw %xmm6, %xmm5
; SSE2-NEXT:    psubusw %xmm5, %xmm0
; SSE2-NEXT:    retq
;
; SSE41-LABEL: combine_trunc_v8i32_v8i16:
; SSE41:       # %bb.0:
; SSE41-NEXT:    pmovsxbw {{.*#+}} xmm3 = [65535,0,65535,0,65535,0,65535,0]
; SSE41-NEXT:    pminud %xmm3, %xmm2
; SSE41-NEXT:    pminud %xmm3, %xmm1
; SSE41-NEXT:    packusdw %xmm2, %xmm1
; SSE41-NEXT:    psubusw %xmm1, %xmm0
; SSE41-NEXT:    retq
;
; SSE42-LABEL: combine_trunc_v8i32_v8i16:
; SSE42:       # %bb.0:
; SSE42-NEXT:    pmovsxbw {{.*#+}} xmm3 = [65535,0,65535,0,65535,0,65535,0]
; SSE42-NEXT:    pminud %xmm3, %xmm2
; SSE42-NEXT:    pminud %xmm3, %xmm1
; SSE42-NEXT:    packusdw %xmm2, %xmm1
; SSE42-NEXT:    psubusw %xmm1, %xmm0
; SSE42-NEXT:    retq
;
; AVX1-LABEL: combine_trunc_v8i32_v8i16:
; AVX1:       # %bb.0:
; AVX1-NEXT:    vextractf128 $1, %ymm1, %xmm2
; AVX1-NEXT:    vbroadcastss {{.*#+}} xmm3 = [65535,65535,65535,65535]
; AVX1-NEXT:    vpminud %xmm3, %xmm2, %xmm2
; AVX1-NEXT:    vpminud %xmm3, %xmm1, %xmm1
; AVX1-NEXT:    vpackusdw %xmm2, %xmm1, %xmm1
; AVX1-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX1-NEXT:    vzeroupper
; AVX1-NEXT:    retq
;
; AVX2-LABEL: combine_trunc_v8i32_v8i16:
; AVX2:       # %bb.0:
; AVX2-NEXT:    vpbroadcastd {{.*#+}} ymm2 = [65535,65535,65535,65535,65535,65535,65535,65535]
; AVX2-NEXT:    vpminud %ymm2, %ymm1, %ymm1
; AVX2-NEXT:    vextracti128 $1, %ymm1, %xmm2
; AVX2-NEXT:    vpackusdw %xmm2, %xmm1, %xmm1
; AVX2-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX2-NEXT:    vzeroupper
; AVX2-NEXT:    retq
;
; AVX512-LABEL: combine_trunc_v8i32_v8i16:
; AVX512:       # %bb.0:
; AVX512-NEXT:    # kill: def $ymm1 killed $ymm1 def $zmm1
; AVX512-NEXT:    vpmovusdw %zmm1, %ymm1
; AVX512-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX512-NEXT:    vzeroupper
; AVX512-NEXT:    retq
  %1 = zext <8 x i16> %a0 to <8 x i32>
  %2 = call <8 x i32> @llvm.usub.sat.v8i32(<8 x i32> %1, <8 x i32> %a1)
  %3 = trunc <8 x i32> %2 to <8 x i16>
  ret <8 x i16> %3
}

; fold (usub_sat (shuffle x, u, m), (shuffle y, u, m)) -> (shuffle (usub_sat x, y), u, m)
define <8 x i16> @combine_shuffle_shuffle_v8i16(<8 x i16> %x0, <8 x i16> %y0) {
; SSE-LABEL: combine_shuffle_shuffle_v8i16:
; SSE:       # %bb.0:
; SSE-NEXT:    psubusw %xmm1, %xmm0
; SSE-NEXT:    pshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; SSE-NEXT:    retq
;
; AVX-LABEL: combine_shuffle_shuffle_v8i16:
; AVX:       # %bb.0:
; AVX-NEXT:    vpsubusw %xmm1, %xmm0, %xmm0
; AVX-NEXT:    vpshuflw {{.*#+}} xmm0 = xmm0[3,2,1,0,4,5,6,7]
; AVX-NEXT:    retq
  %x1= shufflevector <8 x i16> %x0, <8 x i16> poison, <8 x i32> <i32 3, i32 2, i32 1, i32 0, i32 4, i32 5, i32 6, i32 7>
  %y1 = shufflevector <8 x i16> %y0, <8 x i16> poison, <8 x i32> <i32 3, i32 2, i32 1, i32 0, i32 4, i32 5, i32 6, i32 7>
  %res = tail call <8 x i16> @llvm.usub.sat.v8i16(<8 x i16> %x1, <8 x i16> %y1)
  ret <8 x i16> %res
}

# REQUIRES: x86
# RUN: llvm-mc -filetype=obj -triple=x86_64 %s -o %t.o
# RUN: echo '.tbss; .globl a; a:' | llvm-mc -filetype=obj -triple=x86_64 - -o %t1.o
# RUN: ld.lld -shared %t1.o -o %t1.so

## GD to LE relaxation.
# RUN: not ld.lld %t.o %t1.o -o /dev/null 2>&1 | FileCheck -DINPUT=%t.o %s
## GD to IE relaxation.
# RUN: not ld.lld %t.o %t1.so -o /dev/null 2>&1 | FileCheck -DINPUT=%t.o %s

# CHECK: error: [[INPUT]]:(.text+0x0): R_X86_64_GOTPC32_TLSDESC/R_X86_64_CODE_4_GOTPC32_TLSDESC must be used in leaq x@tlsdesc(%rip), %REG
# CHECK-NEXT: error: [[INPUT]]:(.text+0xd): R_X86_64_GOTPC32_TLSDESC/R_X86_64_CODE_4_GOTPC32_TLSDESC must be used in leaq x@tlsdesc(%rip), %REG

leaq a@tlsdesc(%rbx), %rdx
call *a@tlscall(%rdx)
movl %fs:(%rax), %eax

leaq a@tlsdesc(%r16), %r20
call *a@tlscall(%r20)
movl %fs:(%rax), %eax
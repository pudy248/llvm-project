default: configure build

remake: rm configure build

rm:
	rm -rf build/*

configure:
	cmake -B build llvm -G Ninja -DCMAKE_C_FLAGS="-O3 -march=native" -DCMAKE_CXX_FLAGS="-O3 -march=native -lstdc++ -Wno-unused-command-line-argument" \
    -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang -DCMAKE_BUILD_TYPE=Release -DLLVM_ABI_BREAKING_CHECKS="FORCE_ON" -DLLVM_ENABLE_LLD=True -DLLVM_ENABLE_LTO=Thin \
    -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra;lld;lldb;compiler-rt" -DLLVM_ENABLE_RUNTIMES="libcxx;libcxxabi;compiler-rt" -DLLVM_TARGETS_TO_BUILD="X86;NVPTX" \
    -DLLVM_UNREACHABLE_OPTIMIZE="OFF"

build: configure
	cmake --build build

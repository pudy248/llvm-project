// RUN: %clang_cc1 -fsyntax-only -verify=expected,precxx17 %std_cxx98-14 %s
// RUN: %clang_cc1 -fsyntax-only -verify=expected,cxx17 -std=c++17 %s

template<template<typename T> class X> struct A; // #A
// expected-note@-1 2{{previous template template parameter is here}}

template<template<typename T, int I> class X> struct B; // expected-note{{previous template template parameter is here}}

template<template<int I> class X> struct C;
// expected-error@-1 {{conversion from 'int' to 'const int &' in converted constant expression would bind reference to a temporary}}
// expected-note@-2 {{previous template template parameter is here}}

template<class> struct X; // expected-note {{template is declared here}}
template<int N> struct Y; // expected-note {{template parameter is declared here}}
template<long N> struct Ylong;
template<const int &N> struct Yref; // expected-note {{template parameter is declared here}}

namespace N {
  template<class> struct Z;
}
template<class, class> struct TooMany; // expected-note{{template is declared here}}


A<X> *a1;
A<N::Z> *a2;
A< ::N::Z> *a3;

A<Y> *a4; // expected-error@#A {{template argument for non-type template parameter must be an expression}}
          // expected-note@-1 {{different template parameters}}
A<TooMany> *a5; // expected-error {{too few template arguments for class template 'TooMany'}}
                // expected-note@-1 {{different template parameters}}
B<X> *a6; // expected-error {{too many template arguments for class template 'X'}}
          // expected-note@-1 {{different template parameters}}
C<Y> *a7;
C<Ylong> *a8;
C<Yref> *a9; // expected-note {{different template parameters}}

template<typename T> void f(int);

A<f> *a9; // expected-error{{must be a class template}}

// Evil digraph '<:' is parsed as '[', expect error.
A<::N::Z> *a10;
#if __cplusplus <= 199711L
// expected-error@-2 {{found '<::' after a template name which forms the digraph '<:' (aka '[') and a ':', did you mean '< ::'?}}
#endif

// Do not do a digraph correction here.
A<: :N::Z> *a11;  // expected-error{{expected expression}} \
                     precxx17-error{{a type specifier is required for all declarations}} \
                     cxx17-error{{expected unqualified-id}}

// PR7807
namespace N {
  template <typename, typename = int>
  struct X
  { };

  template <typename ,int>
  struct Y
  { X<int> const_ref(); };

  template <template<typename,int> class TT, typename T, int N>
  int operator<<(int, TT<T, N> a) { // expected-note{{candidate template ignored}}
    0 << a.const_ref(); // expected-error{{invalid operands to binary expression ('int' and 'X<int>')}}
  }

  void f0( Y<int,1> y){ 1 << y; } // expected-note{{in instantiation of function template specialization 'N::operator<<<N::Y, int, 1>' requested here}}
}

// PR12179
template <typename Primitive, template <Primitive...> class F>
#if __cplusplus <= 199711L
// expected-warning@-2 {{variadic templates are a C++11 extension}}
#endif

struct unbox_args {
  typedef typename Primitive::template call<F> x;
};

template <template <typename> class... Templates>
#if __cplusplus <= 199711L
// expected-warning@-2 {{variadic templates are a C++11 extension}}
#endif

struct template_tuple {
#if __cplusplus >= 201103L
  static constexpr int N = sizeof...(Templates);
#endif
};
template <typename T>
struct identity {};
template <template <typename> class... Templates>
#if __cplusplus <= 199711L
// expected-warning@-2 {{variadic templates are a C++11 extension}}
#endif

template_tuple<Templates...> f7() {}

#if __cplusplus >= 201103L
struct S : public template_tuple<identity, identity> {
  static_assert(N == 2, "Number of template arguments incorrect");
};
#endif

void foo() {
  f7<identity>();
}

namespace CheckDependentNonTypeParamTypes {
  template<template<typename T, typename U, T v> class X> struct A {
    // expected-note@-1 {{previous template template parameter is here}}
    void f() {
      X<int, void*, 3> x;
    }
    void g() {
      X<int, long, 3> x;
    }
    void h() {
      // FIXME: If we accept A<B> at all, it's not obvious what should happen
      // here. While parsing the template, we form
      //   X<unsigned char, int, (unsigned char)1234>
      // but in the final instantiation do we get
      //   B<unsigned char, int, (int)1234>
      // or
      //   B<unsigned char, int, (int)(unsigned char)1234>
      // ?
      X<unsigned char, int, 1234> x;
      int check[x.value == 1234 ? 1 : -1];
    }
  };

  template<typename T, typename U, U v> struct B {
    // expected-error@-1 {{conflicting deduction 'U' against 'T' for parameter}}
    static const U value = v;
  };

  // FIXME: This should probably be rejected, but the rules are at best unclear.
  A<B> ab; // expected-note {{different template parameters}}

  void use() {
    ab.f();
    ab.g();
    ab.h();
  }
}

namespace PR32185 {
  template<template<typename T, T> class U> struct A {};
  template<template<typename T, T> class U> struct B : A<U> {};
}

namespace PR10147 {
  template<typename T> struct A {};
  template<typename T = int> struct A;
  template<template<typename...> class A> void f(A<int>*) { A<> a; } // expected-warning 0-1{{extension}}
  void g() { f((A<>*)0); }
}

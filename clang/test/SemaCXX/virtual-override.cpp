// RUN: %clang_cc1 -fsyntax-only -triple %itanium_abi_triple -verify %s -std=c++11
// RUN: %clang_cc1 -fsyntax-only -triple %ms_abi_triple -verify %s -std=c++11
namespace T1 {

class A {
  virtual int f(); // expected-note{{overridden virtual function is here}}
};

class B : A {
  virtual void f(); // expected-error{{virtual function 'f' has a different return type ('void') than the function it overrides (which has return type 'int')}}
};

}

namespace T2 {

struct a { };
struct b { };

class A {
  virtual a* f(); // expected-note{{overridden virtual function is here}}
  virtual int *g(); // expected-note{{overridden virtual function is here}}
};

class B : A {
  virtual b* f(); // expected-error{{return type of virtual function 'f' is not covariant with the return type of the function it overrides ('b *' is not derived from 'a *')}}
  virtual char *g(); // expected-error{{virtual function 'g' has a different return type ('char *') than the function it overrides (which has return type 'int *')}}
};

}

namespace T3 {

struct a { };
struct b : private a { }; // expected-note{{declared private here}}

class A {
  virtual a* f(); // FIXME: desired-note{{overridden virtual function is here}}
};

class B : A {
  virtual b* f(); // expected-error{{invalid covariant return for virtual function: 'a' is a private base class of 'b'}}
};

}

namespace T4 {

struct a { };
struct a1 : a { };
struct b : a, a1 { }; // expected-warning{{direct base 'a' is inaccessible due to ambiguity:\n    struct T4::b -> a\n    struct T4::b -> a1 -> a}}

class A {
  virtual a* f(); // expected-note{{overridden virtual function is here}}
};

class B : A {
  virtual b* f(); // expected-error{{return type of virtual function 'f' is not covariant with the return type of the function it overrides (ambiguous conversion from derived class 'b' to base class 'a':\n\
    struct T4::b -> a\n\
    struct T4::b -> a1 -> a)}}
};

}

namespace T5 {

struct a { };

class A {
  virtual a* const f();
  virtual a* const g(); // expected-note{{overridden virtual function is here}}
};

class B : A {
  virtual a* const f();
  virtual a* g(); // expected-error{{return type of virtual function 'g' is not covariant with the return type of the function it overrides ('a *' has different qualifiers than 'a *const')}}
};

}

namespace T6 {

struct a { };

class A {
  // Classes.
  virtual const a* const_vs_unqualified_class();
  virtual a* unqualified_vs_const_class(); // expected-note{{overridden virtual function is here}}

  virtual volatile a* volatile_vs_unqualified_class();
  virtual a* unqualified_vs_volatile_class(); // expected-note{{overridden virtual function is here}}

  virtual const a* const_vs_volatile_class(); // expected-note{{overridden virtual function is here}}
  virtual volatile a* volatile_vs_const_class(); // expected-note{{overridden virtual function is here}}

  virtual const volatile a* const_volatile_vs_const_class();
  virtual const a* const_vs_const_volatile_class(); // expected-note{{overridden virtual function is here}}

  virtual const volatile a* const_volatile_vs_volatile_class();
  virtual volatile a* volatile_vs_const_volatile_class(); // expected-note{{overridden virtual function is here}}

  virtual const volatile a* const_volatile_vs_unualified_class();
  virtual a* unqualified_vs_const_volatile_class(); // expected-note{{overridden virtual function is here}}

  // Non Classes.
  virtual const int* const_vs_unqualified_non_class(); // expected-note{{overridden virtual function is here}}
  virtual int* unqualified_vs_const_non_class(); // expected-note{{overridden virtual function is here}}
};

class B : A {
  // Classes.
  a* const_vs_unqualified_class() override;
  const a* unqualified_vs_const_class() override; // expected-error{{return type of virtual function 'unqualified_vs_const_class' is not covariant with the return type of the function it overrides (class type 'const a *' does not have the same cv-qualification as or less cv-qualification than class type 'a *')}}

  a* volatile_vs_unqualified_class() override;
  volatile a* unqualified_vs_volatile_class() override; // expected-error{{return type of virtual function 'unqualified_vs_volatile_class' is not covariant with the return type of the function it overrides (class type 'volatile a *' does not have the same cv-qualification as or less cv-qualification than class type 'a *')}}

  volatile a* const_vs_volatile_class() override; // expected-error{{return type of virtual function 'const_vs_volatile_class' is not covariant with the return type of the function it overrides (class type 'volatile a *' does not have the same cv-qualification as or less cv-qualification than class type 'const a *')}}
  const a* volatile_vs_const_class() override; // expected-error{{return type of virtual function 'volatile_vs_const_class' is not covariant with the return type of the function it overrides (class type 'const a *' does not have the same cv-qualification as or less cv-qualification than class type 'volatile a *')}}

  const a* const_volatile_vs_const_class() override;
  const volatile a* const_vs_const_volatile_class() override; // expected-error{{return type of virtual function 'const_vs_const_volatile_class' is not covariant with the return type of the function it overrides (class type 'const volatile a *' does not have the same cv-qualification as or less cv-qualification than class type 'const a *')}}

  volatile a* const_volatile_vs_volatile_class() override;
  const volatile a* volatile_vs_const_volatile_class() override; // expected-error{{return type of virtual function 'volatile_vs_const_volatile_class' is not covariant with the return type of the function it overrides (class type 'const volatile a *' does not have the same cv-qualification as or less cv-qualification than class type 'volatile a *')}}

  a* const_volatile_vs_unualified_class() override;
  const volatile a* unqualified_vs_const_volatile_class() override; // expected-error{{return type of virtual function 'unqualified_vs_const_volatile_class' is not covariant with the return type of the function it overrides (class type 'const volatile a *' does not have the same cv-qualification as or less cv-qualification than class type 'a *')}}

  // Non Classes.
  int* const_vs_unqualified_non_class() override; // expected-error{{virtual function 'const_vs_unqualified_non_class' has a different return type ('int *') than the function it overrides (which has return type 'const int *')}}
  const int* unqualified_vs_const_non_class() override; // expected-error{{virtual function 'unqualified_vs_const_non_class' has a different return type ('const int *') than the function it overrides (which has return type 'int *')}}
};

}

namespace T7 {
  struct a { };
  struct b { };

  class A {
    a* f();
  };

  class B : A {
    virtual b* f();
  };
}

namespace T8 {
  struct a { };
  struct b; // expected-note {{forward declaration of 'T8::b'}}

  class A {
    virtual a *f();
  };

  class B : A {
    b* f(); // expected-error {{return type of virtual function 'f' is not covariant with the return type of the function it overrides ('b' is incomplete)}}
  };
}

namespace T9 {
  struct a { };

  template<typename T> struct b : a {
    int a[sizeof(T) ? -1 : -1]; // expected-error {{array with a negative size}}
  };

  class A {
    virtual a *f();
  };

  class B : A {
    virtual b<int> *f(); // expected-note {{in instantiation of template class 'T9::b<int>' requested here}}
  };
}

// PR5656
class X0 {
  virtual void f0();
};
class X1 : public X0 {
  void f0() = 0;
};

template <typename Base>
struct Foo : Base {
  void f(int) = 0; // expected-error{{not virtual and cannot be declared pure}}
};

struct Base1 { virtual void f(int); };
struct Base2 { };

void test() {
  (void)sizeof(Foo<Base1>);
  (void)sizeof(Foo<Base2>); // expected-note{{instantiation}}
}

template<typename Base>
struct Foo2 : Base {
  template<typename T> int f(T);
};

void test2() {
  Foo2<Base1> f1;
  Foo2<Base2> f2;
  f1.f(17);
  f2.f(17);
};

struct Foo3 {
  virtual void f(int) = 0; // expected-note{{unimplemented pure virtual method}}
};

template<typename T>
struct Bar3 : Foo3 {
  void f(T);
};

void test3() {
  Bar3<int> b3i; // okay
  Bar3<float> b3f; // expected-error{{is an abstract class}}
}

// 5920
namespace PR5920 {
  class Base {};

  template <typename T>
  class Derived : public Base {};

  class Foo {
   public:
    virtual Base* Method();
  };

  class Bar : public Foo {
   public:
    virtual Derived<int>* Method();
  };
}

// Look through template types and typedefs to see whether return types are
// pointers or references.
namespace PR6110 {
  class Base {};
  class Derived : public Base {};

  typedef Base* BaseP;
  typedef Derived* DerivedP;

  class X { virtual BaseP f(); };
  class X1 : public X { virtual DerivedP f(); };

  template <typename T> class Y { virtual T f(); };
  template <typename T1, typename T> class Y1 : public Y<T> { virtual T1 f(); };
  Y1<Derived*, Base*> y;
}

// Defer checking for covariance if either return type is dependent.
namespace type_dependent_covariance {
  struct B {};
  template <int N> struct TD : public B {};
  template <> struct TD<1> {};

  template <int N> struct TB {};
  struct D : public TB<0> {};

  template <int N> struct X {
    virtual B* f1(); // expected-note{{overridden virtual function is here}}
    virtual TB<N>* f2(); // expected-note{{overridden virtual function is here}}
  };
  template <int N, int M> struct X1 : X<N> {
    virtual TD<M>* f1(); // expected-error{{return type of virtual function 'f1' is not covariant with the return type of the function it overrides ('TD<1> *'}}
    virtual D* f2(); // expected-error{{return type of virtual function 'f2' is not covariant with the return type of the function it overrides ('D *' is not derived from 'TB<1> *')}}
  };

  X1<0, 0> good;
  X1<0, 1> bad_derived; // expected-note{{instantiation}}
  X1<1, 0> bad_base; // expected-note{{instantiation}}
}

namespace T10 {
  struct A { };
  struct B : A { };

  struct C {
    virtual A&& f();
  };

  struct D : C {
    virtual B&& f();
  };
};

namespace T11 {
  struct A { };
  struct B : A { };

  struct C {
    virtual A& f(); // expected-note {{overridden virtual function is here}}
  };

  struct D : C {
    virtual B&& f(); // expected-error {{virtual function 'f' has a different return type ('B &&') than the function it overrides (which has return type 'A &')}}
  };
};

namespace T12 {
  struct A { };
  struct B : A { };

  struct C {
    virtual A&& f(); // expected-note {{overridden virtual function is here}}
  };

  struct D : C {
    virtual B& f(); // expected-error {{virtual function 'f' has a different return type ('B &') than the function it overrides (which has return type 'A &&')}}
  };
};

namespace PR8168 {
  class A {
  public:
    virtual void foo() {} // expected-note{{overridden virtual function is here}}
  };

  class B : public A {
  public:
    static void foo() {} // expected-error{{'static' member function 'foo' overrides a virtual function}}
  };
}

namespace ForwardDeclared {
  class A;
  struct B {
    virtual B *f();
  };
  struct A : B {
    A *f();
  };
}

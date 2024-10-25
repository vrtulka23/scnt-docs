Expression solver (EXS)
=======================

The Expression Solver module (EXS) in the `SciNumTools` project is a versatile C++ header-only library designed to solve textual arithmetic and logical expressions. It is useful in simulations, scientific calculations, or any project needing real-time expression handling.
Using this module, it is straightforward to generate customized operators that perform actions on specific atoms with a predetermined operation order.
This is especially useful in cases where there are already existing and well-defined textual representations of mathematical, physical, or abstract objects that can interact with each other.
Examples of such representations include notations for physical units, chemical formulas, elements, subatomic particles, or even chords and notes in musical theory.

Installation
------------

The source code of the EXS module is available on `GitHub <https://github.com/vrtulka23/scnt-exs>`_.
Example applications and tests in the module can be built using the provided setup script `setup.sh <https://github.com/vrtulka23/scnt-exs/blob/main/setup.sh>`_.
For further information about its use, consult its help section.

.. code-block:: bash

   ./setup.sh -h       # show help
   ./setup.sh -b -t    # build and test

On macOS systems, the module can also be installed using `Homebrew <https://brew.sh>`_ package manager.
So far, the module is not available in the main Homebrew repository and needs to be tapped from a project repository.

.. code-block:: bash

   brew tap vrtulka23/scinumtools
   brew install vrtulka23/scinumtools/scnt-exs

After you install it, you can find the EXS module using CMake

.. code-block:: cmake

   find_package(SCNT-EXS REQUIRED)

and use it in your projects.

Examples
--------

The Equation Solver is implemented in C++ as a header file template library.
The main class Solver accepts as a template argument the Atom class.
An Atom standard implementation is provided in the code, however, it can be easily modified by the user.
Source code of the following simple example can be found in the `examples/DefaultSolver` directory.

.. code-block:: cpp
		
   #include <scnt-exs/exs.h>

   using namespace exs;

   int main() {
     Solver<Atom> solver;
     Atom atom = solver.solve("23 * 34.5 + 4");
     atom.print();
   }

This example can be compiled and run using the setup.sh script mentioned above

.. code-block:: bash

   ./setup.sh -c -b -r DefaultSolver
   
and will print 797.5 into the terminal.

The list of all default operations and their order is initialized in the Solver class. However, individual operators and their order can be easily modified, as in the example below.

.. code-block:: cpp
		
   // modifying default operator symbols
   OperatorList<Atom> operators;
   operators.append(NOT_OPERATOR, std::make_shared<OperatorNot<Atom>>("N"));
   operators.append(AND_OPERATOR, std::make_shared<OperatorAnd<Atom>>("A"));
   operators.append(OR_OPERATOR,  std::make_shared<OperatorOr<Atom>>("O"));
   
   // changing default operation steps
   StepList steps;
   steps.append(BINARY_OPERATION, {OR_OPERATOR});
   steps.append(BINARY_OPERATION, {AND_OPERATOR});
   steps.append(UNARY_OPERATION,  {NOT_OPERATOR});
   
   Solver<Atom> solver(operators, steps);
   Atom atom = solver.solve("N false A false O true");
   atom.print();
   
The corresponding example can be compiled using the following command.

.. code-block:: bash
		
   ./setup.sh -c -b -r ModifiedSolver
   
More comprehensive examples (e.g. custom Atom and operator classes) are provided in the `example directory <https://github.com/vrtulka23/scnt-exs/tree/main/examples>`_, and additional code tests are implemented in the `tests directory <https://github.com/vrtulka23/scnt-exs/tree/main/tests>`_.

Atoms
-----

Atoms in EXS are the smallest parts of expressions that hold certain values processed by operators.
These can be simple scalar numbers an arrays, or more complex entities as physical units, chemical elements, or even some abstract objects e.g. chords.
The default source code consists of numerical atoms and implements most basic arithmetic operations (addition, subtraction, ...) and mathematical functions.
This basic set should serve as a sufficient starter kit for a construction of arbitrary expression solver.

Any Atom class should inherit the `AtomBase` class.
The template parameter of `AtomBase` specifies the data type (number, struct or a class) of the atom value.

.. code-block:: cpp

   class Atom: public AtomBase<double> {
   public:
     Atom(Atom &a): AtomBase(a) {};
     Atom(double v): AtomBase(v) {};  
     ...
   }

In general, atom classes used in EXS do not overload any particular operators (e.g. +, +=, < and similar).
All operations on the atom should be encapsuled in separate public member methods.

.. code-block:: cpp

  void Atom::math_add(Atom *other) {
      value += other->value;
  }
  void Atom::math_subtract(Atom *other) {
      value -= other->value;
  }
   
Operators
---------

The code already has a default set of operators that is initialized in the `Solver class <https://github.com/vrtulka23/scnt-exs/tree/main/src/solver.h>`_.
This default set can be used as it is, changed, or expanded to meet some specific need of your project.
Three of the operator classes (`OperatorBase`, `OperatorTernary`, and `OperatorGroup`) serve as the base classes for all major operation types: unary, binary, ternary, and group operators.
Below, we give a quick list of all operators provided in this module, where A, B and C are some atoms.

The first subset of operators is derived from `OperatorBase`.
In this category belong all unary and binary operators.
Such operators act on atoms on their left and/or right side and produce a new resulting atom instead of the original ones.

.. csv-table:: Operators derived from OperatorBase
   :widths: 40, 20, 30
   :header-rows: 1

   "Operation",        "Symbol",       "Type"         
   "addition",         "\+A, A + B",   "unary, binary"
   "subtraction",      "\-A, A - B",   "unary, binary" 
   "multiplication",   "A \* B",       binary         
   "division",         "A / B",        binary         
   "power",            "A \** B",      binary         
   "modulo",           "A % B",        binary         
   "and",              "A && B",       binary         
   "or",               "A || B",       binary         
   "not",              "!A",           unary
   "equal",            "A == B",       binary         
   "not equal",        "A != B",       binary         
   "lower",            "A < B",        binary         
   "greater",          "A > B",        binary         
   "lower or equal",   "A <= B",       binary         
   "greater or equal", "A >= B",       binary

Ternary operators need to be treated separately.
If a starting symbol (e.g. `?`) occurs in an expression, the operator will continue searching for the closing symbol (e.g. `:`) and operate on all three atoms: left, middle and right.
The basic set of operators includes only the most common operator: conditional.
Nevertheless, it is also straightforward to implement other ternary operators like: between (A <= B < C), accumulations (A += B + C), or ranges ( A:B:C ).
   
.. csv-table:: Operators derived from OperatorTernary
   :widths: 40, 20, 30
   :header-rows: 1

   "Operation",        "Symbol",   "Type"
   "conditional",      "A ? B : C",    "ternary"

The last set of operations derives from `OperatorGroup` class and includes most of the mathematical functions that require one or more input arguments enclosed in a starting and ending symbol.
The basic group operator is parenthesis, all other group operators are derived from it.
Individual arguments are separated by a comma and are solved in separate processes.
The final function is evaluated with the argument results.
The table below includes only basic mathematical functions.
However, group operators can be modified to handle even structures like lists, arrays and matrices.
One of such example, `ArraySolver <https://github.com/vrtulka23/scnt-exs/tree/main/examples/ArraySolver>`_, is provided in the source code.
  
.. csv-table:: Operators derived from OperatorGroup
   :widths: 40, 20, 30
   :header-rows: 1

   "Operation",            "Symbol",       "Type"
   "parentheses",          "( A )",        "group"
   "sinus",                "sin( A )",     "group"
   "cosinus",              "cos( A )",     "group"
   "tangens",              "tan( A )",     "group"
   "square root",          "sqrt( A )",    "group"
   "exponent",             "exp( A )",     "group"
   "natural logarithm",    "log( A )",     "group"
   "decimal logarithm",    "log10( A )",   "group"
   "base exponent",        "expb( A, B )", "group"
   "base logarithm",       "logb( A, B )", "group"

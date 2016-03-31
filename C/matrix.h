/*
 * matrix.h
 *
 * This file defines several of the common operations upon matrices, as well
 * as how C++ is to construct or destroy matrices.
 */
#ifndef MATRIX
#define MATRIX

#include <stdio.h>
#include <iostream.h>

class matrix {

  /* define the structure of a matrix */
  private:
  int m, n;        /* quantity of rows and columns */
  double **mat;    /* a 2D array for the elements  */

  /* define functions that all other functions can use */
  public:
  /* Constructors */
  /* Used to declare matrices in other functions. */
  matrix(int row=1, int col=1, double val=0.0); /* default to 1x1 vacuous */
  matrix(int, int, double *);                   /*    use single array    */
  matrix(int, int, double **);                  /*    use double array    */
  matrix(int, double);                          /* create diagonal matrix */
  matrix(char* filename);                       /*  read matrix from file */
  void matrix::read(char* filename);            /*  read matrix from file */
  void matrix::write(char* filename) const;     /*  write matrix to file  */


  /* Destructor */
  /* Used to free memory allocated to matrix when leaving function call.  */
  ~matrix();
    

  /* Copy constructor */
  matrix(matrix &);                             /* copy an existing matrix */
    

  /* Accessors */
  /* Used to define common operations on matrices. */
  
  int rows() const {return m;} /*   return number of rows in "this" matrix  */
  int cols() const {return n;} /* return number of columns in "this" matrix */
  
  /*
   * Operators:
   * define common binary and unary operations on matrices
   */
  double **alloc(int, int);              // allocate memory for matrix
  void freem(void);                      // free memory for matrix
  matrix operator=(const matrix&);       // equal
  matrix operator+(const matrix&) const; // add 
  matrix operator-(void) const;          // negate
  matrix operator-(const matrix&) const; // subtract
  matrix operator*(const matrix&) const; // multiply two matrices
  matrix operator*(double) const;        // multiply matrix and scalar
  matrix operator/(double) const;        // divide matrix by scalar
  matrix operator+=(const matrix&);      // increment
  matrix operator-=(const matrix&);      // decrement
  matrix operator*=(const matrix&);      // multiply two matrices & assign
  matrix operator*=(double);           // multiply matrix and scalar & assign
  matrix operator/=(double);             // divide matrix by scalar & assign
  double &operator()(int, int) const;    // element selection
  double &operator()(int) const;         // element selection (for vectors)
  operator double() const {              // treat 1x1 matrices as scalars
    if ((m != 1) || (n != 1)) {
      cerr << "Only 1x1 matrices are scalars." << endl;
      exit(1);
    }
  return mat[0][0];
  }
  void matrix::print() const;
  void matrix::Mathematica() const;
  matrix matrix::T() const;
  matrix matrix::positive();
  matrix matrix::haugment(const matrix val) const;
  matrix matrix::vaugment(const matrix val) const;
  matrix matrix::rremove(const int row) const;
  matrix matrix::cremove(const int col) const;
  matrix matrix::row(const int i) const;
  matrix matrix::column(const int j) const;
  double matrix::dot(const matrix vector) const;
  matrix matrix::cross(const matrix vector) const;
  double matrix::Frobenius() const;
  double matrix::Infinity() const;
  void matrix::LU(matrix& index);
  void matrix::LUsolver(matrix& b, matrix& index);
  matrix matrix::forward(const matrix b) const;
  matrix matrix::backward(const matrix b) const;
  matrix matrix::diagonal(const matrix b) const;
};
#endif


















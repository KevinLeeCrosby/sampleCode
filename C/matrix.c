/*
 * matrix.c
 *
 * This file defines many of the common unary and binary operations upon
 * matrices, as well as how C++ is to construct or destroy matrices.
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "machine_precision.h"


/* define macros for maximum and minimum */
#define max(a, b) (((a) > (b)) ? (a) : (b));
#define min(a, b) (((a) < (b)) ? (a) : (b));


/*
 * In the following code, the matrix "this" is commonly referenced.
 * This is how C++ names the current matrix (or first) on which an operation
 * is being performed.  Therefore, "this" will not be redundantly defined in
 * the comments below.  Implicitly, "this" is an input to every function below.
 * The components of "this" are "m", "n", and "mat" as defined in matrix.h.
 */

/*
 * constructor - assign all elements of matrix with one value
 *               This is handy for creating a vacuous matrix,
 *               or to create any uniform matrix.
 * Input:   rows, cols (number of rows and columns to assign to new matrix)
 *          val (value to initialize matrix elements to)
 * Output:  new matrix of dimension "rows" by "cols"
 */
matrix::matrix(int rows, int cols, double val) {
  m = rows;
  n = cols;
  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = val;
}



/*
 * constructor - assign elements sequentially to elements of single array
 *               This is very handy for initializing matrices
 *               since C already has means to initialize 1D arrays,
 *               and is used extensively throughout the project.
 * Input:   rows, cols (number of rows and columns to assign to new matrix)
 *          *val (1D array scanned to initialize matrix elements to)
 * Output:  new matrix of dimension "rows" by "cols"
 */
matrix::matrix(int rows, int cols, double *val) {
  m = rows;
  n = cols;
  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = val[n*i + j];
}  



/*
 * constructor - assign elements sequentially to elements of double array
 * Input:   rows, cols (number of rows and columns to assign to new matrix)
 *          **val (2D array scanned to initialize matrix elements to)
 * Output:  new matrix of dimension "rows" by "cols"
 */
matrix::matrix(int rows, int cols, double **val) {
  m = rows;
  n = cols;
  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = val[i][j];
}



/*
 * constructor - create diagonal matrix where diag. elements are one value
 *               This is handy for creating an Identity matrix,
 *               or to represent any scalar as a matrix.
 * Input:   dim (number of rows and columns to assign to new matrix)
 *          val (value to initialize diagonal elements to)
 * Output:  new matrix of dimension "dim" by "dim"
 */
matrix::matrix(int dim, double val) {
  m = n = dim;
  mat = alloc(n, n);
  for (int i=0; i < n; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = (i==j) ? val : 0.0;
}  



/*
 * constructor - read matrix from a file
 * Input:   filename (file to read)
 * Output:  new matrix read from file
 */
matrix::matrix(char* filename) {
  FILE * fp;
  char dumb;

  if ((fp = fopen(filename,"r")) == NULL) {
    cerr << "File " << filename << " does not exist!" << endl;
    exit(1);
  }

  fscanf(fp, " %d %c %d", &m, &dumb, &n);

  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      fscanf(fp, " %lf %c", &mat[i][j], &dumb);
 
  fclose(fp);
}  



/*
 * destructor - define how to deallocate memory when matrix no longer used
 */
matrix::~matrix() {
  freem();
}



/*
 * read matrix from a file
 * Input:   filename (file to read)
 * Output:  new matrix read from file
 */
void matrix::read(char* filename) {
  FILE * fp;
  char dumb;

  if ((fp = fopen(filename,"r")) == NULL) {
    cerr << "File " << filename << " does not exist!" << endl;
    exit(1);
  }

  fscanf(fp, " %d %c %d", &m, &dumb, &n);

  freem();

  mat=alloc(m,n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      fscanf(fp, " %lf %c", &mat[i][j], &dumb);
 
  fclose(fp);
}  



/*
 * write matrix to a file
 * Input:   filename (file to write)
 * Output:  new matrix written to file
 */
void matrix::write(char* filename) const {
  FILE * fp;

  if ((fp = fopen(filename,"w")) == NULL) {
    cerr << "Cannot write file " << filename << endl;
    exit(1);
  }

  fprintf(fp, "%d,%d\n", m, n);

  for (int i=0; i < m; i++) {
    for (int j=0; j < n; j++)
      fprintf(fp, "%.6g, ", mat[i][j]);
    fprintf(fp, "\n");
  }

  fclose(fp);
}  



/*
 * copy constructor - create new matrix identical to existing matrix
 *                    This is handy for duplicating a matrix.
 * Input:   val (existing matrix to copy)
 * Output:  matrix identical to val  
 */
matrix::matrix(matrix& val) {
  m = val.m;
  n = val.n;
  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = val(i+1, j+1);
}    



/*
 * Operators:
 */

/*
 * alloc
 * allocate memory for a matrix
 * Input:   rows, cols (how many rows and columns to allocate)
 * Output:  matrix of dimension "rows" by "cols"
 */
double **matrix::alloc(int rows, int cols) {
  double **temp = (double **)calloc(rows, sizeof(double *));
  for (int i=0; i < rows; i++)
    temp[i] = (double *)calloc(cols, sizeof(double));
    return (temp);
}



/*
 * freem
 * deallocate memory for a matrix
 */
void matrix::freem(void) {
  for(int i=0; i < m; i++)
    free(mat[i]);
  free(mat);
}



/*
 * =
 * make an existing matrix equal to another
 * Input:   val (matrix to copy)
 * Output:  a copy of matrix val
 */
matrix matrix::operator=(const matrix& val) {
  freem();
  m = val.m;
  n = val.n;
  mat = alloc(m, n);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      mat[i][j] = val(i+1, j+1);
  return (*this);
}



/*
 * +
 * add two matrices
 * Input:   val (matrix to add)
 * Output:  "this" + val
 */
matrix matrix::operator+(const matrix& val) const {
  if ((m != val.m) || (n != val.n)) {
    cerr << "Matrices must be of the same size to add." << endl;
    exit(1);
  }
  matrix temp(m, n);

  // add
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      temp(i+1, j+1) = mat[i][j] + val(i+1, j+1);

  return (temp);
}



/*
 * -
 * negate matrix
 * Output:  -"this"
 */
matrix matrix::operator-(void) const {
  matrix temp(m, n);

  // negative
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      temp.mat[i][j] = -mat[i][j];

  return (temp);
}



/*
 * -
 * find difference between two matrices
 * Input:   val (matrix to subtract)
 * Output:  "this" - val
 */
matrix matrix::operator-(const matrix& val) const {
  if ((m != val.m) || (n != val.n)) {
    cerr << "Matrices must be of the same size to subtract." << endl;
    exit(1);
  }
  matrix temp(m, n);

  // subtract
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      temp(i+1, j+1) = mat[i][j] - val(i+1, j+1);

  return (temp);
}



/*
 * *
 * multiply two matrices
 * Input:   val (matrix to multiply)
 * Output:  "this" * val
 */
matrix matrix::operator*(const matrix& val) const {
  if (n != val.m) {
    cerr << "Matrices must be of the same inner size to multiply." << endl;
    exit(1);
  }
  int p = val.n;
  matrix temp(m, p, 0.0);

  // multiply two matrices
  for(int i=0; i < m; i++)
    for(int j=0; j < p; j++)
      for(int k=0; k < n; k++)
	temp(i+1, j+1) += mat[i][k] * val(k+1, j+1);

  return (temp);
}



/*
 * *
 * multiply matrix by scalar
 * Input:   scalar (scalar to multiply)
 * Output:  "this" * scalar
 */
matrix matrix::operator*(double scalar) const {
  matrix temp(m, n);

  // multiply matrix by scalar
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      temp(i+1, j+1) = mat[i][j] * scalar;

  return (temp);
}



/*
 * /
 * divide matrix by scalar
 * Input:   scalar (scalar to divide by)
 * Output:  "this" / scalar
 */
matrix matrix::operator/(double scalar) const {
  matrix temp(m, n);

  // divide scalar by matrix
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      temp(i+1, j+1) = mat[i][j] / scalar;

  return (temp);
}



/*
 * +=
 * increment one matrix by another
 * Input:   val (matrix to add)
 * Output:  "this" += val
 */
matrix matrix::operator+=(const matrix& val) {
  if ((m != val.m) || (n != val.n)) {
    cerr << "Matrices must be of the same size to add." << endl;
    exit(1);
  }
 
  // increment
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      mat[i][j] += val(i+1, j+1);

  return (*this);
}



/*
 * -=
 * decrement one matrix by another
 * Input:   val (matrix to subtract)
 * Output:  "this" -= val
 */
matrix matrix::operator-=(const matrix& val) {
  if ((m != val.m) || (n != val.n)) {
    cerr << "Matrices must be of the same size to subtract." << endl;
    exit(1);
  }

  // decrement
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      mat[i][j] -= val(i+1, j+1);

  return (*this);
}



/*
 * *=
 * multiply two matrices and assign
 * Input:   val (matrix to multiply)
 * Output:  "this" *= val
 */
matrix matrix::operator*=(const matrix& val) {
  if (n != val.m) {
    cerr << "Matrices must be of the same inner size to multiply." << endl;
    exit(1);
  }
  int p = val.n;
  matrix temp(m, p, 0.0);

  int i, j, k;

  // multiply two matrices & assign
  for(i=0; i < m; i++)
    for(j=0; j < p; j++)
      for(k=0; k < n; k++)
	temp(i+1, j+1) += mat[k][j] * val(i+1, k+1);

  freem();
  n = p;
  mat = alloc(m, n);

  // copy temp into this
  for (i=0; i < m; i++)
    for (j=0; i < n; i++)
      mat[i][j] = temp(i+1, j+1);

  return (*this);
}



/*
 * *=
 * multiply matrix by scalar and assign
 * Input:   scalar (scalar to multiply)
 * Output:  "this" *= scalar
 */
matrix matrix::operator*=(double scalar) {
  // multiply matrix by scalar & assign
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      mat[i][j] *= scalar;

  return (*this);
}



/*
 * /=
 * divide matrix by scalar and assign
 * Input:   scalar (scalar to divide by)
 * Output:  "this" /= scalar
 */
matrix matrix::operator/=(double scalar) {
  // divide matrix by scalar & assign
  for(int i=0; i < m; i++)
    for(int j=0; j < n; j++)
      mat[i][j] /= scalar;

  return (*this);
}



/*
 * ()
 * element selection
 * NOTE:  Indices in parentheses begin indexing with 1 rather than 0.
 *        Therefore, indices in parentheses are always one more than
 *        their counterparts in brackets.
 * Input:   row, col (row and column of matrix to extract)
 * Output:  element of matrix in location ("row", "col")
 */
double &matrix::operator() (int row, int col) const {
  if((row <= 0) || (row > m) || (col <= 0) || (col > n)) {
    cerr << "Index out of range." << endl;
    exit(1);
  }
  return mat[row - 1][col - 1];
}



/*
 * ()
 * element selection (for vectors)
 * NOTE:  Indices in parentheses begin indexing with 1 rather than 0.
 *        Therefore, indices in parentheses are always one more than
 *        their counterparts in brackets.
 * Input:   row (row of vector to extract)
 * Output:  element of vector in location "row"
 */
double &matrix::operator() (int item) const {
  if((item <= 0) || (item > m && n == 1) || (item > n && m == 1)) {
    cerr << "Index out of range." << endl;
    exit(1);
  }
  else if(m != 1 && n != 1) {
    cerr << "Parentheses with one argument only valid for vectors." << endl;
    exit(1);
  }
  if(m == 1)  /* column vector */
    return mat[0][item - 1];
  else /* n == 1,  row vector  */
    return mat[item - 1][0];
}



/* print a matrix */
void matrix::print() const {
  cout << " _";
  for(int j=0; j < n; j++)
    cout << "            ";
  cout << "_" << endl;
  for(int i=0; i < m; i++) {
    if(i == m-1) cout << "|_";
    else cout << "| ";
    for(int j=0; j < n; j++)
      printf("%12.4e", mat[i][j]);
    if(i == m-1) cout << "_| " << m << " x " << n;
    else cout << " |";
    cout << endl;
  }
  cout << endl;
}


/* print a matrix, Mathematica style */
void matrix::Mathematica() const {
  cout << " {";
  for(int i=0; i < m; i++) {
    cout << "{";
    for(int j=0; j < n; j++) {
      printf("%.6g", mat[i][j]);
      if(j != n-1) cout << ", ";
    }
    if(i == m-1) cout << "}};   " << m << " x " << n;
    else cout << "},";
    cout << endl << " ";
  }
  cout << endl;
}


/*
 * transpose
 * find transpose of a matrix
 * Output:  transpose of "this" matrix
 */
matrix matrix::T() const {
  matrix temp(n, m);
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      temp(j+1, i+1) = mat[i][j];
  return temp;
}


/*
 * positive
 * return vector of positive elements
 * Input:   p (quantity of components to consider)
 * Output:  I (index set of p largest components of "this")
 */
matrix matrix::positive() {
  if(m != 1 && n != 1) {
    cerr << "Can only find positive elements of a vector."<< endl;
    exit(1);
  }
  int p = max(m, n);
  matrix pos(*this);
  
  for(int i=1; i <= p; i++) {
    pos(i) = max(0.0, pos(i));
  }
  return pos;
}


/*
 * horizontal augment
 * horizontally augment two matrices
 * Input:   val (matrix to augment to "this")
 * Output:  horizontally augmented matrix of ["this" | val]
 */
matrix matrix::haugment(const matrix val) const {
  if(m != val.rows()) {
    cerr << "Must have same number of rows to horizontally augment." << endl;
    exit(1);
  }
  int p = n + val.cols();
  matrix temp(m, p);
  for (int i=0; i < m; i++) {
    for (int j=0; j < n; j++)
      temp(i+1, j+1) = mat[i][j];
    for (int j=n; j < p; j++)
      temp(i+1, j+1) = val(i+1, j+1-n);
  }
  return temp;
}


/*
 * vertical augment
 * vertically augment two matrices
 * Input:   val (matrix to augment to "this")     T      T T
 * Output:  vertically augmented matrix of ["this"  | val ]
 */
matrix matrix::vaugment(const matrix val) const {
  if(n != val.cols()) {
    cerr << "Must have same number of columns to vertically augment."<< endl;
    exit(1);
  }
  int p = m + val.rows();
  matrix temp(p, n);
  for (int j=0; j < n; j++) {
    for (int i=0; i < m; i++)
      temp(i+1, j+1) = mat[i][j];
    for (int i=m; i < p; i++)
      temp(i+1, j+1) = val(i+1-m, j+1);
  }
  return temp;
}


/*
 * remove row
 * remove row from a matrix
 * Input:   row (row number to remove)
 * Output:  matrix with ith row removed
 */
matrix matrix::rremove(const int row) const {
  if(row <= 0 || row > m) {
    cerr << "Row index out of range."<< endl;
    exit(1);
  }
  matrix temp(m-1, n);
  
  for(int i=0, k=0; k < m - 1; i++, k++) {
    if(i == row-1) i++;
    for (int j=0; j < n; j++)
      temp(k+1, j+1) = mat[i][j];
  }
  return temp;
}


/*
 * remove column
 * remove column from a matrix
 * Input:   col (column number to remove)
 * Output:  matrix with jth column removed
 */
matrix matrix::cremove(const int col) const {
  if(col <= 0 || col > n) {
    cerr << "Column index out of range."<< endl;
    exit(1);
  }
  matrix temp(m, n-1);
  for (int i=0; i < m; i++)
    for(int j=0, l=0; l < n - 1; j++, l++) {
      if(j == col-1) j++;
      temp(i+1, l+1) = mat[i][j];
    }
  return temp;
}


/*
 * extract row
 * extract row from a matrix
 * Input:   i (row number to extract)
 * Output:  ith row vector "this"
 */
matrix matrix::row(const int i) const {
  if(i <= 0 || i > m) {
    cerr << "Row index out of range."<< endl;
    exit(1);
  }
  matrix temp(1, n);
  for (int j=0; j < n; j++)
    temp(j+1) = mat[i-1][j];
  return temp;
}


/*
 * extract column
 * extract column from a matrix
 * Input:   j (column number to extract)
 * Output:  jth column vector "this"
 */
matrix matrix::column(const int j) const {
  if(j <= 0 || j > n) {
    cerr << "Column index out of range."<< endl;
    exit(1);
  }
  matrix temp(m, 1);
  for (int i=0; i < m; i++)
    temp(i+1) = mat[i][j-1];
  return temp;
}


/*
 * dot product
 * find dot product of two vectors
 * Input:   vector
 * Output:  dot product
 */
double matrix::dot(const matrix vector) const {
  if(n != 1 || vector.cols() != 1) {
    cerr << "Dot product only defined for vectors." << endl;
    exit(1);
  }      
  else if(m != vector.rows()) {
    cerr << "Vectors must be same size to take dot product." << endl;
    exit(1);
  }
  return this.T()*vector;
}


/*
 * cross product
 * find cross product of two vectors of length 3
 * Input:   vector
 * Output:  cross product
 */
matrix matrix::cross(const matrix vector) const {
  if(n != 1 || vector.cols() != 1) {
    cerr << "Cross product only defined for vectors." << endl;
    exit(1);
  }
  else if(m != vector.rows()) {
    cerr << "Vectors must be same size to take cross product." << endl;
    exit(1);
  }
  else if(m != 3) {
    cerr << "Cross product only defined for vectors of length 3." << endl;
    exit(1);
  }
  double a1 = mat[0][0], a2 = mat[1][0], a3 = mat[2][0];
  double elements[] = {0,-a3,a2, a3,0,-a1, -a2,a1,0};
  matrix skew_symmetric(3,3,elements);
  
  return skew_symmetric*vector;
}


/*
 * Frobenius norm
 * find Frobenius norm of a matrix
 * Output:  l_2 norm of "this" matrix
 */
double matrix::Frobenius() const {
  double sum = 0.0;
  for (int i=0; i < m; i++)
    for (int j=0; j < n; j++)
      sum += mat[i][j] * mat[i][j];
  return sqrt(sum);
}


/*
 * Infinity norm
 * find Infinity norm of a matrix
 * Output:  l_oo norm of "this" matrix
 */
double matrix::Infinity() const {
  int i, j;
  double sum, maximum;
  for (i=0, maximum=0.0; i < m; i++) {
    for (j=0, sum=0.0; j < n; j++)
      sum += fabs(mat[i][j]);
    maximum = max(maximum, sum);
  }
  return maximum;
}


/*
 * LU Factorization with implicit pivoting
 * find LU Factorization of a matrix
 * Output:  LU factorization stored in original matrix
 *          index (vector recording row permutation)
 * Source:  Numerical Recipes in C, Second Edition, p. 46-47
 */
void matrix::LU(matrix &index) {
  if(m != n) {
    cerr << "Matrix must be square to find LU factors." << endl;
    exit(1);
  }
  int i, imax, j, k;
  double big,dum,sum,temp;
  matrix vv(n,1);       /* scaling of each row      */
  
  for(i=1; i<=n; i++) { /* get scaling information  */
    big=0.0;
    for(j=1; j<=n; j++)
      if((temp=fabs((*this)(i,j))) > big) big=temp;
    if(big==0.0) {      /* a zero largest element   */
      cerr << "Singular matrix in LU factorization." << endl;
      exit(1);
    }
    vv(i) = 1.0 / big;  /* save scaling             */
  }
  for(j=1; j<=n; j++) { /* Crout's method           */
    for(i=1; i<j; i++) {
      sum = (*this)(i,j);
      for(k=1; k<i; k++) sum -= (*this)(i,k)*(*this)(k,j);
      (*this)(i,j) = sum;
    }
    big = 0.0;          /* get largest pivot        */
    for(i=j; i<=n; i++) {
      sum = (*this)(i,j);
      for(k=1; k<j; k++) sum -= (*this)(i,k)*(*this)(k,j);
      (*this)(i,j) = sum;
      if((dum=vv(i)*fabs(sum)) >= big) {
	big = dum;
	imax = i;
      }
    }
    if(j != imax) {     /* interchange rows?        */
      for(k=1; k<=n; k++) {
	dum = (*this)(imax,k);
	(*this)(imax,k) = (*this)(j,k);
	(*this)(j,k) = dum;
      }
      vv(imax) = vv(j); /* interchange scale factor */
    }
    index(j) = (double)imax;
    if((*this)(j,j) == 0.0) (*this)(j,j) = machine_precision();
    if(j != n) {        /* divide by pivot element  */
      dum = 1.0 / (*this)(j,j);
      for(i=j+1; i<=n; i++) (*this)(i,j) *= dum;
    }
  }                     /* do next column           */
}


/*
 * LU Solver
 * Perform forward and backward substitution to solve LUx = b
 * Input:   index (vector recording row permutation)
 *          b (vector in A x = b)
 * Output:  x (returned in b, solution to L y = b, U x = y)
 * Source:  Numerical Recipes in C, Second Edition, p. 46-47
 */
void matrix::LUsolver(matrix& b, matrix& index) {
  if(m != n) {
    cerr << "LU factorization must be in square matrix." << endl;
    exit(1);
  }
  else if(m != b.rows()) {
    cerr << "Matrix and vector are incompatible sizes for ";
    cerr << "forward and backward substitution." << endl;
    exit(1);
  }
  int i, ii=0, ip, j;
  double sum;

  for(i=1; i<=n; i++) { /* forward substitution  */
    ip = nint(index(i));
    sum = b(ip);
    b(ip) = b(i);
    if(ii)
      for(j=ii; j<=i-1; j++) sum -= (*this)(i,j)*b(j);
    else if(sum) ii = i;/* nonzero element encountered */
    b(i) = sum;
  }
  for(i=n; i>=1; i--) { /* backward substitution */
    sum = b(i);
    for(j=i+1; j<=n; j++) sum -= (*this)(i,j)*b(j);
    b(i) = sum/(*this)(i,i);
  }
}

      
/*
 * forward substitution
 * solves Lx = b for x (L = "this"),
 * where L is lower triangular with diagonal of ones
 * Input:   b (vector in Lx = b)
 * Output:  x (vector that solves equation)
 */
matrix matrix::forward(const matrix b) const {
  if(m != b.rows()) {
    cerr << "Matrix and vector are incompatible sizes for ";
    cerr << "forward substitution." << endl;
    exit(1);
  }
  matrix x(n,1);
  double sum = 0.0;
  for(int i=0; i < n; i++) {
    sum = 0.0;
    for(int j=0; j <= i-1; j++)
      sum += mat[i][j]*x(j+1);
    x(i+1) = b(i+1) - sum;
  }
  return x;
}


/*
 * backward substitution
 * solves Ux = b for x (U = "this"),
 * where U is upper triangular with diagonal of ones
 * Input:   b (vector in Ux = b)
 * Output:  x (vector that solves equation)
 */
matrix matrix::backward(const matrix b) const {
  if(m != b.rows()) {
    cerr << "Matrix and vector are incompatible sizes for ";
    cerr << "backward substitution." << endl;
    exit(1);
  }
  matrix x(n);
  double sum = 0.0;
  for(int m=n-1; m >= 0; m--) {
    sum = 0.0;
    for(int j=m+1; j < n; j++)
      sum += mat[m][j]*x(j+1);
    x(m+1) = b(m+1) - sum;
  }
  return x;
}


/*
 * diagonal substitution
 * solves Dx = b for x (D = "this"),
 * where D is diagonal matrix stored as a vector
 * Input:   b (vector in Dx = b)
 * Output:  x (vector that solves equation)
 */
matrix matrix::diagonal(const matrix b) const {
  if(m != b.rows()) {
    cerr << "Matrix and vector are incompatible sizes for ";
    cerr << "diagonal substitution." << endl;
    exit(1);
  }
  if(n != 1) {
    cerr << "Diagonal matrix must be stored as a vector." << endl;
    exit(1);
  }
  matrix x(m,1);
  for(int i=0; i < m; i++)
    x(i+1) = b(i+1) / mat[i][0];
  return x;
}

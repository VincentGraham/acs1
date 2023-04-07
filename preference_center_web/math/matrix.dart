import 'dart:math';

import 'package:flutter/foundation.dart';

/// note: matrix indexing starts at 1
class Matrix {
  late final List<double?> _matrix;

  /// m columns
  late final int _m;

  /// n rows
  late final int _n;

  // swaps the [i][j] values for every method
  bool _transpose = false;

  /// a matrix with entries equal to [value]
  Matrix.full(
      {required int rows, required int columns, required double? value}) {
    _matrix = _full(rows, columns, value);
    _n = rows;
    _m = columns;
  }

  /// internal Vector generator
  List<double?> _full(int rows, int columns, double? value) {
    if (rows <= 0 || columns <= 0)
      throw ArgumentError.value('rows and columns must be greater than zero');
    return List<double?>.filled(rows * columns, value, growable: false);
  }

  factory Matrix.empty({required int rows, required int columns}) {
    return Matrix.full(columns: columns, rows: rows, value: null);
  }

  /// a matrix of only zeros
  factory Matrix.zeros({required int rows, required int columns}) {
    return Matrix.full(columns: columns, rows: rows, value: 0);
  }

  /// a matrix of only ones
  factory Matrix.ones({required int rows, required int columns}) {
    return Matrix.full(columns: columns, rows: rows, value: 1);
  }

  /// a square matrix of zeros
  factory Matrix.square({required int size}) {
    return Matrix.full(columns: size, rows: size, value: 0);
  }

  /// copy the values of the matrix
  Matrix.copy(matrix, int rows, int columns, {transpose = false})
      : _transpose = transpose {
    _matrix = matrix;
    _n = rows;
    _m = columns;
  }

  /// transpose of the matrix
  Matrix get transpose => Matrix.copy(_matrix, _n, _m, transpose: true);
  Matrix get T => transpose;

  /// the [rows, columns] physical dimensions
  List<int> get shape => _transpose ? [_n, _m] : [_m, _n];

  /// the j-th column vector
  List<double?> column(int j) => List.generate(rows, (i) => get(i, j));

  /// the i-th row vector
  List<double?> row(int i) => List.generate(columns, (j) => get(i, j));

  int get rows => _n;
  int get columns => _m;

  /// get an element by index
  double get(int i, int j) {
    // swap the values for transpose
    if (_transpose) {
      int _temp = i;
      i = j;
      j = _temp;
    }

    return _matrix[_row(i) + _column(j)]!;
  }

  /// set the ij element (cannot use [][]=)
  void set(int i, int j, double? value) {
    // swap the values
    if (_transpose) {
      int _temp = i;
      i = j;
      j = _temp;
    }

    _matrix[_row(i) + _column(j)] = value;
  }

  /// the first element's index in the i-th row
  /// for the 0-th row it would be 0
  ///
  /// for a 3x3 matrix, the 2nd row starts at index 3
  int _row(int i) {
    if (i >= rows)
      throw ArgumentError.value(i, 'i must be less than the number of rows');
    return i * columns;
  }

  /// the first element's index in the j-th column
  /// for a 3x3 matrix, the 2nd column starts at index 1
  int _column(int j) {
    if (j >= columns)
      throw ArgumentError.value(j, 'j must be less than the number of columns');
    return j;
  }

  int count(double? value) =>
      _matrix.where((element) => element == value).length;

  /// used in conjunction with Vector[] to get the ij-th element in matrix[i][j]
  List<double?> operator [](int index) {
    if (_transpose) {
      return column(index);
    } else {
      return row(index);
    }
  }

  /// set the row
  void operator []=(int index, Vector v) {
    if (_transpose) {
      if (v.length != columns) {
        throw ArgumentError.value(v, 'v is not the correct length');
      }
      for (int i = 0; i < v.length; i++) {
        set(i, index, v[i]);
      }
    } else {
      if (v.length != rows)
        throw ArgumentError.value(v, 'v is not the correct length');
      for (int i = 0; i < v.length; i++) {
        set(index, i, v[i]);
      }
    }
  }

  /// entrywise equality
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Matrix && listEquals(other._matrix, _matrix);
  }

  bool contains(Object? object) => _matrix.contains(object);

  int get hashCode => _matrix.hashCode;

  /// dimension check
  bool canMultiply(Matrix right) {
    return _m == right.rows;
  }

  Matrix operator *(Matrix right) {
    Matrix c = Matrix.empty(rows: this.rows, columns: right.columns);
    if (!canMultiply(right))
      throw ArgumentError.value(right, 'has incorrect dimensions');

    for (int iC = 0; iC < c.rows; iC++) {
      for (int jC = 0; jC < c.columns; jC++) {
        double? sum = 0;
        for (int i = 0; i < this.rows; i++) {
          if (this.contains(null) || this.contains(null)) {
            sum = null;
          } else {
            sum = sum! + (this[iC][i]! * right[i][jC]!);
          }
        }
        c.set(iC, jC, sum);
      }
    }
    return c;
  }
}

/// a row vector - dart is row major.
/// Vector is indexed at one, the first element is Vector[1]
class Vector {
  late List<double?> _vector;

  Vector.copy(vector) {
    _vector = vector;
  }

  factory Vector.generate(int length, double? Function(int) generate) {
    return Vector.from(List.generate(length, generate, growable: false));
  }

  factory Vector.full(int length, double? value) =>
      Vector.from(List<double?>.filled(length, value, growable: false));

  Vector.from(Iterable values) {
    _vector = List<double?>.from(values, growable: false);
  }

  bool contains(Object? element) => _vector.contains(element);

  int get length => _vector.length;

  static void _checkDimensions(Vector u, Vector v) {
    if (v.length != u.length)
      throw ArgumentError.value(v, 'vectors are not compatible dimensions');
  }

  void operator []=(int index, double? value) => _vector[index - 1] = value;
  double? operator [](int index) => _vector[index - 1];

  /// entry wise operations ///
  /// ///////////////////// ///

  bool operator ==(Object v) {
    if (!(v is Vector)) return false;
    for (int i = 0; i < length; i++) {
      if (this[i] != v[i]) return false;
    }
    return true;
  }

  int get hashCode => _vector.hashCode;

  Vector operator +(Vector v) {
    Vector u = Vector.copy(this);
    _checkDimensions(this, v);
    for (int i = 0; i < length; i++) {
      if (v[i] != null && this[i] != null) {
        u[i] = this[i]! + v[i]!;
      } else {
        u[i] = null;
      }
    }
    return u;
  }

  Vector operator -(Vector v) {
    Vector u = Vector.copy(this);
    _checkDimensions(this, v);
    for (int i = 0; i < length; i++) {
      if (v[i] != null && this[i] != null) {
        u[i] = this[i]! - v[i]!;
      } else {
        u[i] = null;
      }
    }
    return u;
  }

  Vector operator /(Vector v) {
    Vector u = Vector.copy(this);
    _checkDimensions(this, v);
    for (int i = 0; i < length; i++) {
      if (v[i] != null && this[i] != null) {
        u[i] = this[i]! / v[i]!;
      } else {
        u[i] = null;
      }
    }
    return u;
  }

  Vector operator *(Vector v) {
    Vector u = Vector.copy(this);
    _checkDimensions(this, v);
    for (int i = 0; i < length; i++) {
      if (v[i] != null && this[i] != null) {
        u[i] = this[i]! * v[i]!;
      } else {
        u[i] = null;
      }
    }
    return u;
  }

  /// dot product - returns 0 if null values
  double dot(Vector v) {
    _checkDimensions(this, v);
    if (this.contains(null) || v.contains(null)) return 0;
    double sum = 0;
    for (int i = 0; i < length; i++) {
      sum = sum + this[i]! * v[i]!;
    }
    return sum;
  }

  /// p norm - returns 0 if any null values present
  num norm({int p = 2}) {
    double _norm = 0;

    if (this.contains(null)) return 0;
    if (p.isInfinite)
      return _vector.map((element) => element!.abs()).fold(0, max);
    for (double? e in _vector) {
      _norm = _norm + e!.abs();
    }
    return pow(_norm, (1 / p));
  }
}

#!/usr/bin/env python

# Tiebreaker-In-Polytope Tenney-OPtimal (TOP) calculator
# Copyright (c) 2012 Keenan Pepper

# Permission is hereby granted, free of charge, to any 
# person obtaining a copy of this software and associated 
# documentation files (the "Software"), to deal in the 
# Software without restriction, including without 
# limitation the rights to use, copy, modify, merge, 
# publish, distribute, sublicense, and/or sell copies of 
# the Software, and to permit persons to whom the Software 
# is furnished to do so, subject to the following 
# conditions:

# The above copyright notice and this permission notice 
# shall be included in all copies or substantial portions 
# of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF 
# ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT 
# SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
# IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.

from math import *
import numpy
from numpy import matrix
import itertools

def constraint_matrices(r, c):
  '''Special matrices with entries in {-1,0,1}. r is 
number of rows, c is number of columns.'''
  for indices in itertools.combinations(range(c), r+1):
    for signs in itertools.product([+1, -1], repeat=r):
      ret = matrix([[0]*c]*r)
      for i in range(r):
        ret[i,indices[0]] = 1
        ret[i,indices[i+1]] = signs[i]
      yield ret
  if r == 1:
    # If only 1 degree of freedom left, need to include 
    # cases where one of the errors is 0 (rather than 
    # equal to some other error)
    for i in range(c):
      ret = matrix([[0]*c])
      ret[0,i] = 1
      yield ret

def candidates(A, b, tol, num_already):
  '''Returns a list of the "corner case" solutions, that 
is, the vertices of the TOP polytope.'''
  n, m = A.shape  # maps from Rm to Rn
    # (e.g. rank-m temperament of a rank-n group)
  xs = []
  for C in constraint_matrices(m, n):
    try:
      xs.append(numpy.linalg.solve(C*A, C*b))
    except numpy.linalg.linalg.LinAlgError:
      # Should check to see whether it's actually singular 
      # and not some other error
      pass
  assert(xs)  # At least one should have worked
  residuals = [sorted(abs(A*x-b),reverse=True) for x in xs]
  # Now throw out all the ones that aren't optimal
  # for the appropriate number of coordinates
  for i in range(min(num_already + m + 1, n)):
    min_error = min([residuals[j][i] for j in range(len(residuals))])
    new_xs = []
    new_res = []
    for j in range(len(xs)):
      if residuals[j][i] <= min_error + tol:
        new_xs.append(xs[j])
        new_res.append(residuals[j])
    xs = new_xs
    residuals = new_res
  return xs

def tiptop(primes, mapping, tol):
  weight = matrix(numpy.diag([1/log(p) for p in primes]))
  A = weight * log(2)/1200 * matrix(mapping).T
  b = numpy.ones([A.shape[0], 1])
  xs = candidates(A, b, tol, 0)
  num_already = A.shape[1] + 1

  # Used to get "back" to the solution x of the original 
  # problem at the end
  A_back = numpy.eye(A.shape[1])
  b_back = numpy.zeros([A.shape[1], 1])

  while len(xs) > 1:

    b = b - A * xs[0]
    X = numpy.hstack([xs[i] - xs[0] for i in range(1,len(xs))])
    A = A * X

    b_back = A_back * xs[0] + b_back
    A_back = A_back * X

    xs = candidates(A, b, tol, num_already)
    num_already += A.shape[1] + 1
  return (A_back * xs[0] + b_back), (A * xs[0] - b)

if __name__ == '__main__':
  print 'TIP-TOP TOP calculator'

  while True:
    print
    print 'Enter the primes / basis elements of your temperament.'
    print 'Example: 2 3 5 7'
    print
    response = raw_input()
    primes = [float(s) for s in response.split()]
    print
    print 'Enter the mapping of your temperament, one row (val) at a time.'
    print 'Example: meantone is'
    print '1 2 4 7'
    print '0 -1 -4 -10'
    print 'Enter an empty line when done.'
    print
    rows = []
    while True:
      entries = raw_input().split()
      if not entries: break
      rows.append([float(s) for s in entries])
    mapping = matrix(rows)
    generators, residual = tiptop(primes, mapping, 1e-9)
    print 'The TOP generators are:'
    print [float(x) for x in generators]
    print 'The errors of each prime are:'
    print [log(primes[i],2)*1200 * float(residual[i]) for i in range(len(residual))]
    print '(Or weighted, in cents per octave:)'
    print [1200 * float(x) for x in residual]
    print 'So the TOP damage is:', 1200*float(max(abs(residual))), 'cents per octave.'
    print 'Another? (y/n)'
    print
    response = raw_input()
    if 'Y' not in response.upper(): break


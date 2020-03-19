#!/usr/bin/env python

from math import *
from fractions import gcd

def harmonic_sets(edo, max_harmonic, threshold):
  '''Returns all the harmonic sets for EDO using harmonics up to max_harmonic,
where all the errors in the tonality diamond are less than threshold cents'''
  l = []
  for flattest in range(1,max_harmonic,2):
    test = lambda i: (((log(i,2)-log(flattest,2))*edo) % 1) * 1200/edo < threshold
    l.append(set(filter(test, range(1,max_harmonic+1,2))))
  ret = []
  for s in l:
    good = True
    if reduce(gcd,s) != 1:
      good = False
    else:
      for s2 in l:
        if s != s2 and s.issubset(s2): good = False
    if good: ret.append(sorted(s))
  return sorted(ret)

def error(harmonic_set, edo):
  '''Returns the worst error in the tonality diamond
when harmonic_set is approximated using EDO'''
  first = harmonic_set[0]
  fparts = sorted(((log(i,2)-log(first,2))*edo) % 1 for i in harmonic_set)
  gap = 0
  for i in range(1,len(fparts)):
    if fparts[i]-fparts[i-1] > gap:
      gap = fparts[i]-fparts[i-1]
  if 1-fparts[-1] > gap:
    gap = 1-fparts[-1]
  return (1-gap)*1200/edo

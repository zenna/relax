#pragma once
#include "ibex/ibex.h"

namespace sigma {

double measure(const ibex::Interval &i) {return i.ub() - i.lb();}
double logmeasure(const ibex::Interval &i) {return log(i.ub() - i.lb());}
double logmeasure(const Box &box, int ndims) {
  double logmeasure_ = 0.0;
  for (int i = 0; i<ndims; ++i) {
    logmeasure_ += logmeasure(box[i]);
  }
  return logmeasure_;
}

double logmeasure(const Box &box) {
  return logmeasure(box, box.size());
}

}
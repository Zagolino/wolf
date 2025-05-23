//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html

#include "Convection.h"

registerMooseObject("MiscTestApp", Convection);

InputParameters
Convection::validParams()
{
  InputParameters params = Kernel::validParams();
  params.addRequiredParam<RealVectorValue>("velocity", "Velocity Vector");
  return params;
}

Convection::Convection(const InputParameters & parameters)
  : Kernel(parameters), _velocity(getParam<RealVectorValue>("velocity"))
{
}

Real
Convection::computeQpResidual()
{
  return _test[_i][_qp] * (_velocity * _grad_u[_qp]);
}

Real
Convection::computeQpJacobian()
{
  return _test[_i][_qp] * (_velocity * _grad_phi[_j][_qp]);
}

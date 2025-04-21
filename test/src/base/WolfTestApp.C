//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "WolfTestApp.h"
#include "WolfApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
WolfTestApp::validParams()
{
  InputParameters params = WolfApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

WolfTestApp::WolfTestApp(InputParameters parameters) : MooseApp(parameters)
{
  WolfTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

WolfTestApp::~WolfTestApp() {}

void
WolfTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  WolfApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"WolfTestApp"});
    Registry::registerActionsTo(af, {"WolfTestApp"});
  }
}

void
WolfTestApp::registerApps()
{
  registerApp(WolfApp);
  registerApp(WolfTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
WolfTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  WolfTestApp::registerAll(f, af, s);
}
extern "C" void
WolfTestApp__registerApps()
{
  WolfTestApp::registerApps();
}

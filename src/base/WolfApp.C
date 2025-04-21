#include "WolfApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
WolfApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

WolfApp::WolfApp(InputParameters parameters) : MooseApp(parameters)
{
  WolfApp::registerAll(_factory, _action_factory, _syntax);
}

WolfApp::~WolfApp() {}

void
WolfApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<WolfApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"WolfApp"});
  Registry::registerActionsTo(af, {"WolfApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
WolfApp::registerApps()
{
  registerApp(WolfApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
WolfApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  WolfApp::registerAll(f, af, s);
}
extern "C" void
WolfApp__registerApps()
{
  WolfApp::registerApps();
}


# Escoamento de Poiseuille com Convecção Forçada

mu = 0.001
rho = 1
cp = 4186
k = 0.6
#L = 0.01
#U_avg = 0.01

#h_wall = 100
#T_wall = 350




[Mesh]
    [malha]
        type = GeneratedMeshGenerator
        dim = 2
        xmin = 0
        xmax = 0.5
        ymin = -0.01
        ymax = 0.01
        nx = 50
        ny = 20
    []
[]

[Variables]
    [u]
        initial_condition = 0
        scaling = 0.1
    []
    [T]
        initial_condition = 300
        scaling = 1
    []
    [p]
        initial_condition = 101325
    []
    [v]
        initial_condition = 0
    []
[]

[Materials]
    [props]
        type = GenericConstantMaterial
        prop_names = 'rho mu cp k'
        prop_values = '${rho} ${mu} ${cp} ${k}'
    []
[]


[Functions]
    [inlet_profile]
        type = ParsedFunction
        symbol_names = 'U_avg L'
        symbol_values = '0.01 0.01'
        expression = '1.5 * U_avg * (1 - (y/L)^2)' # Umax = 1.5*U_avg
    []
[]

[Kernels]
    # Convervação de Massa
    [mass]
        type = INSMass
        variable = p
        pressure = p
        u = u
        v = v
    []

    #Conversação de Momento
    [x_momentum]
        type = INSMomentumLaplaceForm
        variable = u
        component = 0
        pressure = p
        u = u
        v = v
        mu_name = mu
        rho_name = rho
    []
    [y_momentum]
        type = INSMomentumLaplaceForm
        variable = v
        component = 1
        pressure = p
        u = u
        v = v
        mu_name = mu
        rho_name = rho
    []

    # Convervação de Energia
    [energy]
        type = INSTemperature
        variable = T
        u = u
        rho_name = rho
        cp_name = cp
        v = v
        k_name = k
    []
[]

[BCs]
    #Velocidade
    [inlet_u]
        type = FunctionDirichletBC
        variable = u
        boundary = 'left'
        function = 'inlet_profile'
    []
    [outlet_p]
        type = DirichletBC
        variable = p
        boundary = 'right'
        value = 101325
    []
    [no_slip_top]
        type = DirichletBC
        variable = u
        boundary = 'top'
        value = 0
    []
    [no_slip_bottom]
        type = DirichletBC
        variable = u
        boundary = 'bottom'
        value = 0
    []

    # Temperatura
    [inlet_T]
        type = DirichletBC
        variable = T
        boundary = 'left'
        value = 300
    []
    [heat_flux_top]
        type = NeumannBC
        variable = T
        boundary = 'top'
        function = 'h_wall * (T_wall - T)'
    []
    [heat_flux_bottom]
        type = NeumannBC
        variable = T
        boundary = 'bottom'
        function = 'h_wall * (T_wall - T)'
    []
[]

[Preconditioning]
    [SMP_BJACOBI]
        type = SMP
        full = true
        solve_type = 'NEWTON'
    []
[]

[Executioner]
    type = Steady
    solve_type = 'NEWTON'
    nl_rel_tol = 1e-8
    nl_abs_tol = 1e-10
    nl_max_its = 20
[]

[Outputs]
    exodus = true
[]
        
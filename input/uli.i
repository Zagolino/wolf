
# Escoamento de Poiseuille com Convecção Forçada


# Declaração de constantes --------------------------------------------------------

# Propridades físicas da água
mu = 0.001  # Viscosidade dinâmica
rho = 997     # Densidade
cp = 4186   # Calor específico
k = 0.6     # condutividade térmica

# Condições de contorno referentes à transferência de calor
h_wall = 100 # Coeficiente de transferência de calor
T_wall = 350 # Temperatura na parede


# Definição da malha ---------------------------------------------------------------

# Malha bidimensional retangular
[Mesh]
    [malha]
        type = GeneratedMeshGenerator   
        dim = 2         #bidimensional
        xmin = 0        #Começo do canal
        xmax = 0.5      #Comprimento do canal
        ymin = -0.01    #Parede inferior
        ymax = 0.01     #Parede superior
        nx = 50         #Número de elementos em X
        ny = 20         #Número de elementos em Y
    []
[]


# Definição das variáveis do problema -------------------------------------------------

[Variables]

    [u] # Velocidade em X
        scaling = 1e0   # dimensionado para estabilidade numérica
    []

    [T] # Temperatura
        initial_condition = 300 # Temperatura inicial em K
        scaling = 1             # Sem dimencionamento
    []

    [p] # Pressão
        scaling = 1e-5  # dimencionado para estabilidade numérica
    []

    [v] # Velocidade em Y
        scaling = 1e-2  # dimencionado para estabilidade numérica
    []
[]


# Atribuição das propriedades do fluído --------------------------------------------

[Materials]
    [props]
        type = GenericConstantMaterial
        prop_names = 'rho mu cp k'
        prop_values = '${rho} ${mu} ${cp} ${k}' # Usa valores atribuídos inicialmente
    []
[]

# Funções complementares do problema ------------------------------------------------


[Functions]

    [inlet_profile]                     # Perfil de velocidade na entrada
        type = ParsedFunction
        symbol_names = 'U_avg L'
        symbol_values = '0.01 0.01'
        expression = '1.5 * U_avg * (1 - (y/L)^2)'  # Perfil parabólico
    []

    [wall_flux]                         # Fluxo de calor nas paredes
        type = ParsedFunction
        symbol_names = 'h_wall T_wall T'
        symbol_values = '${h_wall} ${T_wall} 300'
        expression = 'h_wall * (T_wall - T)'    # Lei de resfriamento de Newton
    []

[]


# Condições iniciais ----------------------------------------------------------------

[ICs]

    [u_ic]  # Condição inicial para a velocidade em X
        type = FunctionIC
        variable = u
        function = inlet_profile    # Utiliza o perfil de velocidade de Functions
    []

    [v_ic]  # Condição inicial para a velocidade em Y
        type = ConstantIC
        variable = v
        value = 1e-4    # Número pequeno diferente de zero para convergir melhor
    []

[]


# Operações das componentes da equação -------------------------------------------------

[Kernels]

    # Conservação de Massa - equação da continuidade
    [mass]
        type = INSMass
        variable = p
        pressure = p
        u = u
        v = v
        use_displaced_mesh = false
    []

    # Equação de momento de Navier-Stokes
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

    # Equação de Energia
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


# Condições de contorno  -----------------------------------------------------------

[BCs]

    # Pressão
    [p_reference]   # Pressão na entrada do canal
        type = DirichletBC
        variable = p
        boundary = 'left'
        value = 101325
    []

    
    # Velocidade 
    [inlet_u]   # Velocidade em x na entrada do canal
        type = FunctionDirichletBC
        variable = u
        boundary = 'left'
        function = 'inlet_profile'  #Perfil de velocidade definido em Functions
    []
    [no_slip_top]   # Fluído na parede superior
        type = DirichletBC
        variable = u
        boundary = 'top'
        value = 0
    []
    [no_slip_bottom] # Fluído na parede inferior
        type = DirichletBC
        variable = u
        boundary = 'bottom'
        value = 0
    []
    [v_inlet]   # Velocidade em y na entrada do canal
        type = DirichletBC
        variable = v
        boundary = 'left'
        value = 0
    []
    [v_outlet]  # Velocidade em y na saída do canal
        type = INSMomentumNoBCBCLaplaceForm     # Condição de contorno natural
        variable = v
        boundary = 'right'
        u = u
        v = v
        mu_name = mu
        pressure = p
        rho_name = rho
        component = 1
        gravity = '0 -9.8 0'
    []
    [v_top]     # Velocidade em y na parede superior
        type = DirichletBC
        variable = v
        boundary = 'top'
        value = 0
    []
    [v_bottom]  # Velocidade em y na parede inferior
        type = DirichletBC
        variable = v
        boundary = 'bottom'
        value = 0
    []

    
    # Temperatura
    [inlet_T]   # Temperatura na entrada do canal
        type = DirichletBC
        variable = T
        boundary = 'left'
        value = 300
    []
    [heat_flux_top] # Fluxo de calor na parede superior
        type = FunctionNeumannBC
        variable = T
        boundary = 'top'
        function = 'wall_flux'  # Função de fluxo definida em Functions
    []
    [heat_flux_bottom]  # Fluxo de calor na parede inferior
        type = FunctionNeumannBC
        variable = T
        boundary = 'bottom'
        function = 'wall_flux'  # Função de fluxo definida em Functions
    []
[]


# Definição da matrix de pré-condicionamento ----------------------------------------

[Preconditioning]
    [SMP_BJACOBI]
        type = SMP              # Single Matrix Preconditioner
        full = true             # Constrói um Jacobiano completo
        solve_type = 'NEWTON'   # Problema não linear
    []
[]


# Forma de execução da simulação -----------------------------------------------------

[Executioner]
    type = Steady   # Estado estacionário
    solve_type = NEWTON # Não linear

    # Opções do kit de ferrametas para problemas científicos
    petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_mat_solver_type -ksp_type -ksp_rtol -ksp_atol -snes_linesearch_type'
    petsc_options_value = 'lu NONZERO mumps gmres 1e-4 1e-8 basic'
    
    # Número de iterações
    nl_max_its = 200    #não linear
    l_max_its = 1000    #linear

    # Controle de tolerâncias
    nl_rel_tol = 1e-5
    nl_abs_tol = 1e-7
    l_tol = 1e-4
[]


# Pós-processamento ------------------------------------------------------------------

[Postprocessors]
    [residual_u]    # Rastreia a convergência da variável u
        type = ElementExtremeValue
        variable = u
        value_type = max
    []
    [residual_v]    # Rastreia a convergência da variável v
        type = ElementExtremeValue
        variable = v
        value_type = max
    []
   
[]


# Exportação dos resultados ---------------------------------------------------------

[Outputs]
    exodus = true   #exporta no formato .e para visualização no Paraview
[]
        
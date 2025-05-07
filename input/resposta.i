
[GlobalParams]
    gravity = '0 -9.8 0'

    order = FIRST
    family = LAGRANGE

    u = Vx
    v = Vy
    pressure = p
    temperature = T 
    eos = eos

    p_int_by_parts = true
[]  


#Geometria do domínio
[Mesh]
    [placa] #Vai ser um retângulo padrão
      type = GeneratedMeshGenerator
      dim = 2 #Bidimensional
      nx = 20
      ny = 10
      xmax = 20
      ymax = 10
    []
  
[]
  
[NodalNormals]
   
    boundary = 'top bottom'
    corner_boundary = 'corners'
[]

[FluidProperties]
    [eos]
        type = SimpleFluidProperties 
        density0 = 100
        thermal_expansion = 0.001
        cp = 100
        viscosity = 0.1
        thermal_conductivity = 72
    
    []
[]
        


#O que desejamos saber sobre as PDEs (Partial Differential Equations)
[Variables]
    [T] #Temperatura - é o nosso objeto de estudo

      initial_condition = 630 #Começa em 293.15K (~20ºC)
      scaling = 1e-4
    []
    [Vy] #Velocidade em y
        scaling = 1e-2
        initial_condition = 1

    []
    [Vx] #Velocidade em x
        scaling = 1e-1
        initial_condition = 0

    []

    [p]
        initial_condition = 1.01e5
    []
    
[]

[AuxVariables]
    [rho]
        initial_condition = 77.0
    []
[]

[Materials]
    [mat]
        type = INSFEMaterial
        block = 0
    []
[]


#Representações dos operadores ou termos da forma fraca das PDEs
[Kernels]
    [massa]
        type = INSFEFluidMassKernel
        variable = p
    []

    [Mx]
        type = INSFEFluidMomentumKernel
        variable = Vx
        component = 0
    []

    [My]
        type = INSFEFluidMomentumKernel
        variable = Vy
        component = 1
    []

    [Energia]
        type = INSFEFluidEnergyKernel
        variable = T
    []
[]

[AuxKernels]
    [rho_aux]
        type = FluidDensityAux
        variable = rho
        p = p
        T = T
        fp = eos
    []
[]

#Condições de contorno - tanto para equações quanto para variáveis
[BCs]
    [massa_en]
        type = INSFEFluidMassBC
        variable = p
        boundary = 'left'
    []

    [mass_sai]
        type = INSFEFluidMassBC
        variable = p
        boundary = 'right'
    []

    [Vx_in]
        type = INSFEFluidMomentumBC
        variable = Vx
        boundary = 'left'
        component = 0
        
        v_fn = 1
    []

    [Vx_sai]
        type = INSFEFluidMomentumBC
        variable = Vx
        boundary = 'right'
        component = 0
        p_fn = 1e5
    []

    [Vx_paredes]
        type = INSFEFluidWallMomentumBC
        variable = Vx
        boundary = 'top bottom'
        component = 0
    []

    [Vy_in]
        type = INSFEFluidMomentumBC
        variable = Vy
        boundary = 'left'
        component = 1
        v_fn = 1
    []

    [Vy_sai]
        type = INSFEFluidMomentumBC
        variable = Vy
        boundary = 'right'
        component = 1
        p_fn = 1e5
    []

    [Vy_paredes]
        type = INSFEFluidWallMomentumBC
        variable = Vy
        boundary = 'top bottom'
        component = 1
    []

    [slipwall]
        type = INSFEMomentumFreeSlipBC
        boundary = 'top bottom'
        variable = Vx
        u = Vx
        v = Vy
    []

    [T_en] #Definição da temperatura à esquerda da placa
        type = INSFEFluidEnergyBC
        variable = T
        boundary = 'left'
        T_fn = 630
        
    []

    [T_sai] #Definição da temperatura à direita da placa
        type = INSFEFluidEnergyBC
        variable = T
        boundary = 'right'
        T_fn = 630
        
    []
[]

[Preconditioning]
    [SMP_PJFNK]
      type = FDP
      full = true
      solve_type = 'PJFNK'
    []
[]

#Modo se execução da simulação - pode incluir incremento de tempo e comportamentos
[Executioner]
    type = Transient

    dt = 0.2
    dtmin = 1.e-6
    [TimeStepper]
        type = IterationAdaptiveDT
        growth_factor = 1.25
        optimal_iterations = 15
        linear_iteration_ratio = 100
        dt = 0.1

        cutback_factor = 0.5
        cutback_factor_at_failure = 0.5
    []
    dtmax = 25

    petsc_options_iname = '-pc_type -ksp_gmres_restart'
    petsc_options_value = 'lu 100'

    nl_rel_tol = 1e-10
    nl_abs_tol = 1e-8
    nl_max_its = 12

    l_tol = 1e-5
    l_max_its = 100

    start_time = 0.0
    end_time = 500
    num_steps = 2
[]
  
#Declara a forma como a solução será exportada
[Outputs]
    exodus = true #Exporta os resultados num arquivo com o formato ".e"
[]
  
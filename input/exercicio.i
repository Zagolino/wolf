

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

#O que desejamos saber sobre as PDEs (Partial Differential Equations)
[Variables]
  [T] #Temperatura - é o nosso objeto de estudo
    family = LAGRANGE
    order = FIRST
    initial_condition = 293.15 #Começa em 293.15K (~20ºC)
  []
  [p] #pressão - teremos que calcular para definir estabelecer algumas propriedades que serão necessárias nas equações de Navier-Stokes
      
    
    family = LAGRANGE
    order = FIRST

  [] 
  [Vx] #Velocidade em x
    family = LAGRANGE
    order = FIRST
  []
  [Vy] #Velocidade em y
    family = LAGRANGE
    order = FIRST
  []
[]

#Informações usadas para calcular ou armazenar informações intermediárias
[AuxVariables]

  [dy] #Derivada de V em função de y
    family = MONOMIAL
    order = CONSTANT
  []

  [termo_dissipacao] #Termo que carregará o valor da dissipacao do material baseado em suas propriedades
    family = MONOMIAL
    order = CONSTANT
  []

  [coef]
    family = MONOMIAL
    order = CONSTANT
  
  []
 
  [dT] #Derivada de V em função de y
    family = MONOMIAL
    order = CONSTANT
  []


  [termo_conveccao]  
    family = MONOMIAL
    order = CONSTANT
  []

[]

#Cálculo de funções conhecidas e explícitas
[AuxKernels]

  [dV_dy] #Operação da derivada de V em função de y
    type = VariableGradientComponent
    variable = dy
    gradient_variable = Vy
    component = y
    
    
  []
  
  [dissip_calc] #operação para obtenção do termo dissipativo
    type = ParsedAux
    variable = termo_dissipacao
    expression = 0
    coupled_variables = 'dy'
    
  []

  [coef_conv]
    type = ParsedAux
    variable = coef
    expression = 1
    coupled_variables = 'Vx Vy'
  []

  [dT_dx] 
    type = VariableGradientComponent
    variable = dT
    gradient_variable = T
    component = x
  []

  [convec_calc] 
    type = ParsedAux
    variable = termo_conveccao
    expression = 0
    coupled_variables = 'dT'
    
  []

[]

#Definição de propriedades para serem usadas nos kernels e condições de contorno
[FluidProperties]
  [agua]
    type = Water97FluidProperties
  []
[]

[Materials]
  [props_agua] #Atribuição das propriedades do fluído
    type = GenericConstantMaterial

    prop_names = 'rho mu conductivity'
    prop_values = '997  0.001 0.6'
    block = 0
    
  []
[]






#Representações dos operadores ou termos da forma fraca das PDEs
[Kernels]
  [massa] #informação necessária em Navier-Stokes
    type = INSMass
    pressure = p
    u = 'Vx Vy'
    variable = p
  []

  [Mx] #Momento em x - informação necessária em Navier-Stokes
    type = INSMomentumLaplaceForm
    pressure = p
    u = Vx
    component = 0
    variable = Vx
    
  []

  [My] #Momento em y - informação necessária em Navier-Stokes
    type = INSMomentumLaplaceForm
    pressure = p
    u = Vy
    component = 1
    variable = Vy
  []

  [Difusao] #Laplaciano de T
    type = Diffusion
    variable = T
  []

  [Conveccao] #props x derivada de T em função de x
  type = CoupledForce
  variable = T
  v = termo_conveccao

    
  []
  
  [Dissipacao] #props x derivada de V em função de y
    type = CoupledForce
    variable = T
    v = termo_dissipacao
  []

[]

#Condições de contorno - tanto para equações quanto para variáveis
[BCs]

  [Velx_walls] #Velocidade em x nas extremidades da placa
    type = DirichletBC
    variable = Vx
    boundary = 'left right top bottom'
    value = 0
  []

  [Vely_walls] #Velocidade em y nas extremidades da placa
    type = DirichletBC
    variable = Vy
    boundary = 'left right top bottom'
    value = 0
  []

  [T_left] #Definição da temperatura à esquerda da placa
    type = DirichletBC
    variable = T
    boundary = 'left'
    value = 293.15
  []

  [T_right] #Definição da temperatura à direita da placa
    type = DirichletBC
    variable = T
    boundary = 'right'
    value = 353.15
  []

[]

#Modo se execução da simulação - pode incluir incremento de tempo e comportamentos
[Executioner]
  type = Steady #Problema em estado estacionário/regime permanente
  solve_type = 'NEWTON' 
  
[]

#Declara a forma como a solução será exportada
[Outputs]
  exodus = true #Exporta os resultados num arquivo com o formato ".e"
[]


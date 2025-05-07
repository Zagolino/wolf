

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

 
 
  [dT] 
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
    expression = '(0.001/0.6)*dy*dy'
    coupled_variables = 'dy'
    
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
    expression = '((997*4186*0.1)/0.6)*dT'
    coupled_variables = 'dT'
    
  []

[]

[Materials]
  [agua]
    type = GenericConstantMaterial
    prop_names = 'mu k c rho'
    prop_values = '0.001 0.6 4186 997'
    block = 0
  []
[]



#Representações dos operadores ou termos da forma fraca das PDEs
[Kernels]
  [dummy] #Laplaciano de T
    type = Diffusion
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


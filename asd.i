[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    nx = 20
    ny = 10
    xmin = -100
    xmax = 100
    ymin = -50
    ymax = 50
  []
  [injection_node]
    input = gen
    type = ExtraNodesetGenerator
    new_boundary = injection_node
    coord = '-50 0 0'
  []
[]

[GlobalParams]
  PorousFlowDictator = dictator
  gravity = '0 0 0'
[]

[Variables]
  [porepressure]
    initial_condition = 20E6
  []
  [temperature]
    initial_condition = 400
    scaling = 1E-6 # fluid enthalpy is roughly 1E6
  []
[]

 [BCs]
   [temperature]
     type = DirichletBC
     variable = temperature
     value = 400
     boundary = 'left right'
   []
 []

[Functions]
  [mass_flux_in_func]
    type = ParsedFunction
    expression = '1'
  []
  [mass_flux_out_func]
    type = ParsedFunction
    expression = '-1'
  []
  [T_in_func]
    type = ParsedFunction
    expression = '320'
  []
[]


[DiracKernels]
  [inject_mass]
    type = PorousFlowPointSourceFromPostprocessor
    variable = porepressure
    mass_flux = mass_flux_in
    point = '-50 0 0'
  []
  [inject_heat]
    type = PorousFlowPointEnthalpySourceFromPostprocessor
    variable = temperature
    mass_flux = mass_flux_in
    point = '-50 0 0'
    T_in = T_in
    pressure = porepressure
    fp = the_simple_fluid
  []

  [produce_H2O_1]
    type = PorousFlowPolyLineSink
    SumQuantityUO = produced_mass_H2O1
    fluxes = 1
    p_or_t_vals = 0.0
    line_length = 1.0
    point_file = 1.bh
    variable = porepressure
  []

  [remove_heat_at_production_well_1]
    type = PorousFlowPolyLineSink
    SumQuantityUO = produced_heat1
    fluxes = 1
    p_or_t_vals = 0.0
    line_length = 1.0
    use_enthalpy = true
    point_file = 1.bh
    variable = temperature
  []
[]

[Kernels]
  [mass_dot]
    type = PorousFlowMassTimeDerivative
    fluid_component = 0
    variable = porepressure
  []
  [mass_flux]
    type = PorousFlowAdvectiveFlux
    fluid_component = 0
    variable = porepressure
  []
  [energy_dot]
    type = PorousFlowEnergyTimeDerivative
    variable = temperature
  []
  [heat_advection]
    type = PorousFlowHeatAdvection
    variable = temperature
  []
  [heat_conduction]
    type = PorousFlowHeatConduction
    variable = temperature
  []
[]

[UserObjects]
  [dictator]
    type = PorousFlowDictator
    porous_flow_vars = 'temperature porepressure'  
    number_fluid_phases = 1
    number_fluid_components = 1
  []
  [pc]
    type = PorousFlowCapillaryPressureConst
  []
	[injected_mass]
    type = PorousFlowSumQuantity
  []
  [produced_mass]
    type = PorousFlowSumQuantity
  []
  [produced_heat]
    type = PorousFlowSumQuantity
  []
    [produced_mass_H2O1]
    type = PorousFlowSumQuantity
  []

  [produced_heat1]
    type = PorousFlowSumQuantity
  []
[]

[Postprocessors]
  [mass_flux_in]
    type = FunctionValuePostprocessor
    function = mass_flux_in_func
    execute_on = 'initial timestep_begin'
  []
  [mass_flux_out]
    type = FunctionValuePostprocessor
    function = mass_flux_out_func
    execute_on = 'initial timestep_begin'
  []
  [T_in]
    type = FunctionValuePostprocessor
    function = T_in_func
    execute_on = 'initial timestep_begin'
  []
  [./temp_pro]
    type = PointValue
    point = '50 0 0'
    variable = 'temperature'
  [../]
[]

[FluidProperties]
  [the_simple_fluid]
    type = SimpleFluidProperties
    thermal_expansion = 2E-4
    bulk_modulus = 2E9
    viscosity = 1E-3
    density0 = 1000
    cv = 4000.0
    cp = 4000.0
  []
[]

[Materials]
  [temperature]
    type = PorousFlowTemperature
    temperature = temperature
  []
  [phase]
    type = PorousFlow1PhaseP 
    porepressure = porepressure
    capillary_pressure = pc
  []
  [massfrac]
    type = PorousFlowMassFraction
  []
  [water]
    type = PorousFlowSingleComponentFluid
    fp = the_simple_fluid
    phase = 0
  []
  [porosity]
    type=PorousFlowPorosityConst
    porosity = 0.1  
  []
  [permeability]
    type = PorousFlowPermeabilityConst
    permeability = '5e-10 0 0  0 5e-10 0  0 0 5e-15' 
  []
  [relperm]
    type = PorousFlowRelativePermeabilityCorey
    n = 0
    phase = 0
  []
  [thermal_conductivity]
    type = PorousFlowThermalConductivityIdeal
    dry_thermal_conductivity = '2.5 0 0  0 2.5 0  0 0 2.5' 
  []
  [internal_energy]
    type = PorousFlowMatrixInternalEnergy
    specific_heat_capacity = 920 
    density = 2600 
  []
  [undrained_density]
    type = GenericConstantMaterial
    prop_names = density
    prop_values = 2400 
  [] 
[]

[Preconditioning]
  active = basic
  [basic]
    type = SMP
    full = true
    petsc_options = '-ksp_diagonal_scale -ksp_diagonal_scale_fix'
    petsc_options_iname = '-pc_type -sub_pc_type -sub_pc_factor_shift_type -pc_asm_overlap'
    petsc_options_value = ' asm      lu           NONZERO                   2'
  []
  [preferred_but_might_not_be_installed]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
    petsc_options_value = ' lu       mumps'
  []
[]

[Executioner]
  type = Transient
  solve_type = Newton
  end_time = 10E6
  # dt = 2E5
  dt = 2E5
[]

[Outputs]
  exodus = true
[]

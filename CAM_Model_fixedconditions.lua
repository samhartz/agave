--CAM Model for fixed conditions 

--General params

timestepM = 30 --Model change in time at each step (min)
timestepD = 30 -- timestep of input data 
dt = timestepM*60. -- no. of seconds in timestep, used to advance differential equations

--General Constants
LAMBDA_W = 2.5*10^6 -- Latent heat of water vaporization (J/kg )
LAMBDA_L = 550.*10^-9 -- Wavelength of light (m)
H = 6.63*10^-34 -- Planck's constant (J s)
CC = 3.00*10^8 -- Speed of light (m/s)
EP = (H*CC)/LAMBDA_L -- Energy of photon (J)
g = 9.8       --Gravity (m/s^2)
RHO_W = 998.  -- Water density (kg/m^3)
CP_A = 1012.  --Specific Heat of Air (J/(kg K))
R_A = 290.    -- Specific Gas Constant for Air (J/(kg K))
NA = 6.022*10^23 -- Avogadro's Constant (1/mol)
R = 8.314;    --Universal Gas Constant (J/(mol K))
VW = 18.02/(RHO_W*1000.) -- Molar volume of water (mol/m3)

-- Atmospheric parameters
P_ATM = 101.325*10^3 -- Atmospheric pressure (Pa)
RHO_A = 1.27  -- Air Density (kg/m^3)
--ca = 350.   -- Atmopsheric CO2 concentration (ppm)
--gamma_w = (P_ATM*CP_A)/(.622*LAMBDA_W);--Psychrometric constant for Penman Equation (J/(K-m^3))
GAMMA_THETA  = 4.78 -- (K/km)
B = 0.        -- Empirical factor for boundary layer growth
A_SAT = 613.75
B_SAT = 17.502
C_SAT = 240.97
RHO_V = 0.87  -- Density of water vapor (kg/m3)
CP_W = 4184.  -- specific heat of water (J/kg/K)

-- General photosynthetic params
TO = 293.2    -- Reference Temperature for photosynthetic parameters (K)
GAMMA_1 = .0451 -- Parameter for temp dependence of CO2 compensation point (1/K)
GAMMA_2 = .000347 -- Parameter for temp dependence of CO2 compensation point (1/K^2)
KC0 = 302.    -- Michaelis constant for C02 at TO (umol/mol)
KO0 = 256.    -- Michaelis constant for 02 at TO (mmol/mol)
OI = .209     -- Oxygen Concentration (mol/mol)
SVC = 649.    -- Entropy term for carboxylation (J/mol)
SVQ = 646.    -- Entropy term for e-transport (J/mol)
HKC =  59430. -- Activation Energy for Kc (J/mol)
HKO =  36000. -- Activation Energy for Ko (J/mol)
HKR =  53000. -- Activation Energy for Rd (J/mol)
HDJ = 200000. -- Deactivation Energy for Jmax (J/mol)
HAJ = 50000.  -- Activation Energy for Jmax (J/mol)
RD0 = .32     -- Standard Dark respiration at 25 C (umol/(m^2s))
HAV =  72000. -- Activation Energy for Vc,max (J/mol)
HDV =  200000.-- Deactivation Energy for Vc,max (J/mol)


--CAM params

A1 = .8*15.   -- 0.6*15. # this is the value consistent with the Leuning model
GAMMA_0 = 34.6
RC = 0.5
GMGSRATIO = 1.
TR = 90.;     -- Relaxation time for circadian oscillator (min)
C0 = 3000.    -- parameter for decarboxylation of malic acid (umol/mol)
ALPHA_1 = 1/100.
ALPHA_2 = 1/7. 
K = .003 
TOPT = 288.65 -- (K)
VCM = 0.0027  -- Value controlling relative storage of malate (m)
MU = .5       -- Circadian oscillator constant
BETA = 2.764  -- Circadian oscillator constant
CIRC_1 = .365 -- Circadian oscillator constant
CIRC_2 = .55  -- Circadian oscillator constant
CIRC_3 = 10.  -- Circadian oscillator constant
Z0 = .55      -- Initial value of z (-)
M0 = 0.       -- 1000. # 0. Initial Malic Acid Carbon Concentration (umol/m^3)
TH = 302.65   -- 302.65 High temperature for CAM model (K)
TW = 283.15   -- 283.15 Low temperature for CAM model (K)
KAPPA_2 = .1  -- Quantum yield of photosynthesis (mol CO2/mol photon) (note that this overrides the value of 0.3 for typical photosynthesis)


--Agave params

ZR = 0.3
LAI = 6.
GCUT = 0.
GA = 61.      -- has been 61 previously...29 in marks paper
RAIW = 3.
GPMAX = .04

GWMAX = .002
VWT = .00415
CAP = 0.27

VCMAX0 = 19.5 --19.5
JMAX0 = 39.   -- 39.
MMAX = 130000000. -- 130000000.  # max concentration of malic acid (umol/m^3)
AMMAX =  11.1 -- 11.1# rate of malic acid storage flux (umol/(m^2 s)

PSILA0 = -3.
PSILA1 = -0.5

ARED = 1.
LIGHT_ATTEN = 1.

--- CODE FOR RUNNING MODEL (DEFINITIONS BELOW)

-- INITIAL CONDITIONS:

duration = 10 -- days

ca = 400      -- atmospheric CO2 concentration, ppm
ta = 293      -- atmospheric temperature, deg. K
rh = 80       -- relative humidity, percent
phi = 500     -- solar radiation, W/m2
tl = ta       -- assume leaf temp equal to atmospheric
psi_l = -0.5  -- MPa; leaf water potential

tempC = ta - 273. -- convert to K
psat = A_SAT*np.exp((B_SAT*(tempC))/(C_SAT + tempC)) -- saturated vapor pressure in Pa
qa = 0.622*rh/100.*psat/P_ATM --needs to be in kg/kg, specific humidity in atmosphere

cs = ca
ci = ciNew{
  cs={},
  ta={},
  qa={}
  }
cm = cmNew{
  cs={}, 
  ta={}, 
  qa={}
  }
z = Z0
m = M0
cc = ccNew(cs, ta, qa, z, m)
cx = cc
a_a = {}
z_a = {}
m_a = {}
asc_a = {}
asv_a = {}
avc_a = {}
aphicitl_a = {}
aphicctl_a = {}
ci_a = {}
cc_a = {}
cs_a = {}


--General Functions

function steps(duration, timestepM)
  return math.floor((duration*24*60)/timestepM)
end
--Change Duration of simulation to number of timesteps according to timestep value

function VPD(ta, qa)
  return esat(ta) - (qa*P_ATM)/0.622
end
--Vapor oressure deficit (Pa)

function esat(ta)
  return A_SAT*(math.exp(B_SAT*(ta - 273.))/(C_SAT + ta - 273))
end
--Saturated vapor pressure (Pa)

function qaRH(rh, ta)
  return 0.622*rh/100*esat(ta)/P_ATM
end
--Specific humidity (kg/kg), input of rh in %, ta in K


--General Photosynthethic Functions


function a_c(ci, tl, ared)
  return v_cmax(tl, ared)*(ci - gamma(tl))/ci + k_c(tl)*(1 + (OI*1000)/k_o(tl))
end
--Rubisco-limited photosynthethic rate (umol/(m^2s^1))

function v_cmax(tl, ared)
  return ared*VCMAX0*math.exp(HAV/(R*TO)*(1 - TO/tl))/(1 + math.exp((SVC*tl - HDV)/(R*tl)))
end
--Maximum carboxylation rate (umol/(m^2s))

function k_o(tl)
  return KC0*math.exp(HKO/(R*TO)*(1 - TO/tl))
end
--Michaelis-menten coefficient for O2

function k_c(tl)
  return KC0*math.exp(HKC/(R*TO)*(1 - TO/tl))
end
--Michaelis-menten coefficient for CO2

function a_q(phi, ci, tl)
  return (j(phi*LIGHT_ATTEN, tl)*(ci - gamma(tl)))/(4*(ci +2*gamma(tl)))
end
--Light-limited photosynthetic rate (umol/(m^2s^1))

function gamma(tl)
  return GAMMA_0*(1 + GAMMA_1*(tl - TO) + GAMMA_2*(tl - TO)^2)
end
--CO2 compensation point (umol/mol)

function jmax(tl)
  return JMAX0*math.exp(HAJ/(R*TO)*(1 - TO/tl))/(1 + math.exp((SVQ*tl - HDJ)/(R*tl)))
end
--Max. e- transport rate (umol/(m^2s))

function j(phi, tl)
  return min((phi*10^6)/(EP*NA)*KAPPA_2*.5, jmax(tl))
end
--Electron transport rate (umol/(m^2s))

function jpar(phi, tl)
  return min(phi*KAPPA_2, jmax(tl))
end
--Net photosynthetic demand for CO2 (umol/(m^2s^1))

function a_phiciTl(phi, ci, tl, ared)
  return max(min(a_c(ci,tl, 1), a_q(phi, ci, tl)),0)*ared
end
--Vulnerability curve for water potential (-)

function a_psilc02(psi_l)
  if psi_l < PSILA0 then
    return 0 
  elseif PSILA0 <= psi_l <= PSILA1 then
    return ((psi_l - PSILA0)/(PSILA1 - PSILA0))
  else
    return 1
  end
end
  --
  
function r_d(tl)
    return RD0*math.exp(HKR/(R*TO)*(1 - TO/tl))
end
  --Dark respiration flux (umol/(m^2s))
  
function csNew(an)
    return ca - an/GA
end
  --CO2 concentration at leaf surface (ppm)
  
function ciNew(cs, ta, qa)
    return cs(1.-1./(A1*fD(VPD(ta, qa))))
end
  --CO2 concentration in mesophyll cytosol (ppm)
  
function cmNew(cs, ta, qa)
  return ciNew(cs, ta, qa)
end
  --CO2 concentration in mesophyll (ppm)
  
function fD(vpd)
    if vpd < 0.1 then
      return 1
    else
      return 3/13/sqrt(vpd/1000)
    end
end
  --Stomatal response to vapor pressure deficit (-)
  
function gsc(phi, ta, psi_l, qa, tl, cx, ared, ...)
    if an(phi, psi_l, cx, ared, ...) < 0. then  
      return 0 
    else
      return A1*an(phi, psi_l, tl, cx, ared, ...)/ca*fD(VPD(ta, qa))
    end
end
  --Stomatal conductance to CO2, per unit leaf area (mol/m2/s)
  
function a_sc(phi, psi_l, tl, ci, z, m, ared) 
  return a_psilc02(psi_l)*a_phiciTl(phi, ci, tl, ared)-r_dc(phi, tl)*(1 - f_c(z, m)) 
end

--Flux from stomata to Calvin cycle (umol/(m^2s))

function r_dv(phi, tl)
  return r_d(tl)*math.exp(-phi)
end
--Flux of dark respiration to vacuole (umol/(m^2s))

function r_dc(phi, tl)
  return r_d(tl)*(1 - math.exp(-phi))
end
--Flux of dark respiration to calvin cycle (umol/(m^2s))

function f_o(z)
	return exp(-(z/MU)^CIRC_3)
end
--Circadian order function (-)

function f_m(z, m, tl)
	return f_o(z)*(m_s(tl) - m)/(ALPHA_2*m_s(tl) + (m_s(tl) - m))
end
--Malic acid storage function

function m_s( tl)
	return MMAX*((TH - tl)/(TH - TW)*(1. - ALPHA_2) + ALPHA_2)
end
 --
 
function f_c( z, m)
	return (1. - f_o(z))*m/(ALPHA_1*MMAX + m)
end
--Carbon circadian control function

function a_sv(phi, tl, psi_l, z, m)
	
	-- if MMAX*((TH - tl)/(TH - TW)*(1. - ALPHA_2) + ALPHA_2) > m and (1. - K*(tl - TOPT)**2.) >0:
	--	return (AMMAX*(1. - K*(tl - TOPT)**2.) - r_dv(phi, tl))*f_m(z, m, tl)*a_psilc02(psi_l)
	--else:
	--	return 0.

	return (AMMAX*(1. - K*(tl - TOPT)^2.) - r_dv(phi, tl))*f_m(z, m, tl)*a_psilc02(psi_l)
end
--Flux from stomata to vacuole (umol/(m^2s))

function a_vc(phi, cc, tl, z, m, ared)
	return (a_phiciTl(phi, cc, tl, ared) - r_dc(phi, tl))*f_c(z, m)
end
--Flux from vacuole to calvin cycle (umol/(m^2s))

function m_e( z, m, tl, phi) 

	-- if phi>0.:

	-- 	return MMAX*(CIRC_1*((TH - tl)/(TH - TW) + 1.)*(BETA*(z - MU))**3. - BETA*(TH - tl)/(TH - TW)*(z - MU) + \
	-- 	   CIRC_2*(TH - tl)/(TH - TW) -(1- f_o(z))*(1-m/(m+ALPHA_1*MMAX))) 
		
	-- else:
	-- 	return MMAX*(CIRC_1*((TH - tl)/(TH - TW) + 1.)*(BETA*(z - MU))**3. - BETA*(TH - tl)/(TH - TW)*(z - MU) + \
	--		CIRC_2*(TH - tl)/(TH - TW)+ (1-f_o(z))) 

	return MMAX*(CIRC_1*((TH - tl)/(TH - TW) + 1.)*(BETA*(z - MU))^3. - BETA*(TH - tl)/(TH - TW)*(z - MU) + CIRC_2*(TH - tl)/(TH - TW)) 
end
--Malic acid equilibrium value

function zNew( phi, m, z, tl, dt)
	--return max(0, dt*(m - m_e(z, m, tl, phi))/(MMAX*60.*TR) + z)
	return dt*(m - m_e(z, m, tl, phi))/(MMAX*60.*TR) + z
end
--

function an( phi, psi_l, tl, ci, ared)
	--Photosynthetic rate, per unit leaf area (umol/(m^2s))
	return a_sc(phi, psi_l, tl, ci, z, m, ared) + a_sv(phi, tl, psi_l, z, m) 
end
--Photosynthetic rate, per unit leaf area (umol/(m^2s))

function ccNew( cs, ta, qa, z, m)
	--CO2 concentration in mesophyll cytosol resulting from malic acid decarboxylation (ppm)
	return cmNew(cs, ta, qa) + f_c(z, m)*C0
end
--CO2 concentration in mesophyll cytosol resulting from malic acid decarboxylation (ppm)

function mNew( phi, psi_l, cc, tl, z, m, ared, dt)
	return max(((dt/ VCM)*(a_sv(phi, tl, psi_l, z, m) - a_vc(phi, cc, tl, z, m, ared) + r_dv(phi, tl))) + m, 0.)
end
--Malic acid concentration

--[[Don't think I am doing this loop correctly
function CAM:process(adv,t)
  adv = self.adv
  t = self.t
  for i = 1,adv do
    local dx = self.......trail off 
    ]]

function [E_time_Wh, M_v, s_km, E_conskwh, t_toth]=EVrange(C, Car, t, v, a)


M_v = C(13,Car);     % Estimated mass of the vehicle, in kg
C_bat = C(1,Car);  % Battery capacity in kWh
A_sol = C(2,Car); % Solar panel area in m^2
eta_sol = C(3,Car); % Solar panel efficiency 
I = C(4,Car); % Average solar irradiance in W/m^2
Cd = C(5,Car); % Drag coefficient (estimated) https://www.engineeringtoolbox.com/drag-coefficient-d_627.html
rho_air = 1.225;    % Air density in kg/m^3
W = C(6,Car);          % Width (m)
L = C(7,Car);          % Length (m)
H = C(8,Car);          % Height (m)
Af = C(9,Car);           % Correction factor since it is not an actual box
A_front = W * H * Af; % Frontal area of the Car in m^2
Cr = C(10,Car); % Rolling resistance coefficient

%weight calculations
rho_combi = C(11,Car);         % Aproximate density of roling chasis(kg/m^3) 
Wf= C(12,Car); %weight factor, how much of the actual box valume is raw material
W_skel = (L * W * H * Wf) * rho_combi; % Approximate weight of vehicle without batteries

pd = 250;               % Power density Li-ion Battery (Wh/kg)
W_bat= (C_bat*1000)/pd; % weight of the battery (kg)

pas= 1;     %amount of passengers
W_pas = pas*75; % average weight of passengers

% M_v= W_bat + W_skel + W_pas; %total weight of vehicle if known comment this one out and start on

%auxilery power
P_aux=C(14,Car); %[watt]

% efficiencies
eta_m = 0.96; %motor efficiency
eta_mppt = 0.97; %mppt efficiency

% Solar power generation (watt)
P_sol = A_sol * eta_sol * I;  

% Initializations
E_cons = 0; % Cumulative energy consumption in Joules
E_time = []; % Array to store energy consumption at each time step (Joules)
s = 0; % Cumulative distance traveled in meters
t_tot = 0; % Total time in seconds

% Loop the WLTP cycle until the battery runs out
cycle_indexe = 1; % Keep track of WLTP cycles completed
while E_cons / 3.6e6 < C_bat  % Convert J to kWh and compare
    for i = 2:length(t)
        % Time step (from one point to the next in the WLTP cycle)
        dt = t(i) - t(i-1);
        
        % Aerodynamic drag force (N)
        F_drag = 0.5 * Cd * rho_air * A_front * v(i)^2;
        
        % Rolling resistance force (N)
        F_rol = Cr * M_v * 9.81;
        
        % Total force required
        F_tot = M_v * a(i) + F_drag + F_rol;
        
        % Power required at each time step (Watts)
        P_req = (F_tot * v(i))/eta_m;

        %total power consumed (consumption minus solar power generated)
        % P_tot=P_req-P_sol*eta_mppt +P_aux; %with solar panels
        P_tot=P_req + P_aux; %without solar panels

        % Incremental energy consumption for this time step
        E_step = P_tot * dt;  % in Joules
        E_cons = E_cons + E_step;  % Update cumulative energy consumption
        
        % Store the energy consumption at this time step
        E_time = [E_time; E_step];  % Append to array

        % Increment distance traveled
        s = s + v(i) * dt; % in meters

        % Accumulate total time
        t_tot = t_tot + dt;
        
        % Check if the battery is depleted
        if E_cons / 3.6e6 >= C_bat  % Convert J to kWh and check
            break;
        end
    end
    cycle_indexe = cycle_indexe + 1; % Increment WLTP cycle count
end

% Convert distance to kilometers
s_km = s / 1000;

% Convert energy consumption from Joules to Watt-hours
E_time_Wh = E_time / 3600;  % Convert each energy consumption from Joules to Wh

E_conskwh=E_cons / 3.6e6;
t_toth = t_tot / 3600;

end
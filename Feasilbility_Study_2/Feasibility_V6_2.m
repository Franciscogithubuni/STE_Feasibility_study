clc; clear; close all;
% Load data from Excel file if WLTP
% M = readmatrix('WLTP_class3.xlsx'); % if max speed: 0-70 km/h class 1, 70-... (high) km/h class 2, class 3 if super fast idk
% t = M(:,1);    % Time in seconds (for one WLTP cycle)
% v = M(:,4);    % Velocity in m/s (for one WLTP cycle)
% a = M(:,3);    % Acceleration in m/s^2 (for one WLTP cycle)

% load/calculate data if NEDC
v = readmatrix('NEDC.csv'); % in m/s
t = (0:1219)';              % in s
a = diff(v)/1;
a = [a; a(end)];            %in m/s^2

% Constants
%load constants from excel file
C = readmatrix('Concept variables.xlsx'); %

Car=6; %terra=2 era=3 tuktuk=4 deliveryvan= 5 utilityvan=6 pickuptruck=7 rescuevehicle=8 foodtruck=9

[E_time_Wh, M_v, s_EV, E_EV, t_EV]=EVrange(C, Car, t, v, a);
[s_sol, E_sol, t_sol]=solrange2(C, Car, t, v, a);

E_avg= E_EV;
s_increase= ((s_sol - s_EV)/s_EV)*100;
t_increase= ((t_sol - t_EV)/t_EV)*100;

% Energy flows summary
fprintf('--- Feasibility Study Summary for Solar vehicle ---\n');
fprintf('Total Energy Consumed: %.2f kWh\n', E_avg);
fprintf('The weight of the Car is: %.2f kg\n', M_v) 
fprintf('Total Distance Traveled until Battery Depletion <strong> without solar: %.2f km </strong>\n', s_EV);
fprintf('Total Distance Traveled until Battery Depletion <strong> with solar: %.2f km </strong>\n', s_sol);
fprintf('Total Driving Time until Battery Depletion <strong> without solar:  %.2f hours </strong>\n', t_EV);
fprintf('Total Driving Time until Battery Depletion <strong> with solar: %.2f hours </strong>\n', t_sol);
fprintf('The vehicle can <strong> travel %.2f %% further </strong> due to solar energy\n', s_increase)
fprintf('The vehicle can <strong> drive %.2f %% longer </strong> due to solar energy\n', t_increase)
% fprintf('Number of WLTP Cycles Completed: %d\n', cycle_indexe - 1);

% % Plot energy consumption over time 
% figure;
% subplot(2,1,1);
% plot(E_time_Wh, 'r');
% xlabel('Time (s)');
% ylabel('Energy Consumption(Wh)');
% title('Energy Consumption over Time');
% grid on;
% subplot(2,1,2);
% plot(cumsum(E_time_Wh), 'b');
% xlabel('Time (s)');
% ylabel('total Energy Consumption(Wh)');
% title('total Energy Consumption over Time');
% grid on;


% % Plotting velocity and acceleration data over multiple cycles
% figure;
% t_rep = 0:dt:t_tot; % Full time vector for all cycles combined
% v_rep = repmat(v, cycle_indexe-1, 1); % Repeating the velocity profile
% 
% subplot(2,1,1);
% plot(t_rep, v_rep(1:length(t_rep)), 'b');
% xlabel('Time (s)');
% ylabel('Velocity (m/s)');
% title('Velocity Profile over Multiple WLTP Cycles');
% grid on;
% 
% a_rep = repmat(a, cycle_indexe-1, 1); % Repeating the acceleration profile
% subplot(2,1,2);
% plot(t_rep, a_rep(1:length(t_rep)), 'r');
% xlabel('Time (s)');
% ylabel('Acceleration (m/s^2)');
% title('Acceleration Profile over Multiple WLTP Cycles');
% grid on;

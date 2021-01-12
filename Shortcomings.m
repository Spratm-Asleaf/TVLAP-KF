%{
Readers are allowed to edit and distribute this file, only for academic purpose.
But if you decide to use the materials in this file, you are strongly suggested to
also share your codes (e.g., those related to your publications) with publics.

@Information:
Online supplementary materials of the paper titled 
"A Model for Non-Stationary Time Series and Its Applications in Filtering and Anomaly Detection"
Authored By: Shixiong Wang, Chongshou Li, and Andrew Lim
From: the Department of Industrial Systems Engineering and Management, National University of Singapore

@Author: Shixiong Wang
@Date: 6 July 2020
@Email: s.wang@u.nus.edu; wsx.gugo@gmail.com

See also: https://github.com/Spratm-Asleaf/Range-Correction
%}

%% Denosing and Outlier/Dropout Correction For Real Data
clear all;
close all;
fclose all;
clc;

%% Generate Data
type = 'sudden_change_derivative';
dat = [0];
real_dat = [];
datalength = 1000;
switch type
    case 'random_walk'                % Figure 9
        for i = 1:datalength-1
            dat = [dat; dat(end) + 0.05/3*randn];
        end
        real_dat = dat*0;
    case 'sudden_change'              % Figure 10
       dat(1:round(datalength/2)) = 0;
       dat(round(datalength/2):round(datalength/2)+100) = 2.5;
       dat(round(datalength/2)+101:datalength) = 0;
       real_dat = dat';
       dat = real_dat + 0.05/3*randn(datalength,1);
    case 'sudden_change_derivative'   % Figure 11
       derivative(1:datalength) = 1;
       derivative(round(datalength/2)) = 15;                % e.g., velocity 
       for i = 1:datalength-1
           dat = [dat; dat(end) + 0.1 * derivative(i)];     % e.g., position (sampling time is 0.1)
       end
       real_dat = dat;
       dat = real_dat + 0.05/3*randn(datalength,1);
end
% Add 10 outliers
index = randi(datalength, 10, 1);
dat(index) = 0;

%% Outlier/Dropout Correction
[timeLen, ~] = size(dat);
switch type
    case 'random_walk'
        N = 4;              % "N = K+1" in Eq. (7)
        Q = 0.01^2;
    case 'sudden_change'
        N = 1;            
        Q = 0.01^2;
    case 'sudden_change_derivative'
        N = 3;             
        Q = 0.1^2;
end
T = 0.1;            % Sampling time
MeaThres = 2.0;     % Threshold to determine whether a collected value is an outlier/dropout or not
COUNT = 500;          % See Fig. 10 (b). How many successtive sudden-change measurements ...
                    % would not be counted as outliers.
                    % small value (e.g., 3) for remedy; large value (e.g., 500) for no remedy
% Original Range
figure;
plotTimeIntv = (1:timeLen)*T;
plot(plotTimeIntv, dat, 'b', 'linewidth', 2.0);
hold on;
plot(plotTimeIntv, real_dat, 'g', 'linewidth', 2.5);

[Info, ~] = KFPolynomial(dat, N, T, Q, MeaThres, COUNT);     
plot(plotTimeIntv, (Info.X(1,:)), 'r--', 'linewidth', 3.5);

% Figure Format
legend('Original','True Information','Corrected');
xlabel('Time (second)','fontsize',14);
set(gca,'fontsize',14);

if strcmp(type, 'sudden_change_derivative') == true
    figure;
    plot(plotTimeIntv, derivative, 'g', 'linewidth', 2.5);
    hold on;
    plot(plotTimeIntv, (Info.X(2,:)), 'r--', 'linewidth', 3.5);
    legend('True','Estimated');
    xlabel('Time (second)','fontsize',14);
    set(gca,'fontsize',14);
end
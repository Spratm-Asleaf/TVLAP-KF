%{
Readers are allowed to edit and distribute this file, for any purpose.
But, DO NOT delete this copyright declaration.

@Information:
Online supplementary materials of the paper titled 
"A Model for Non-Stationary Time Series and Its Applications in Filtering and Anomaly Detection"
Authored By: Shixiong Wang, Chongshou Li, and Andrew Lim
From: the Department of Industrial Systems Engineering and Management, National University of Singapore

@Author: Shixiong Wang
@Date: 6 July 2020
@Email: s.wang@u.nus.edu; wsx.gugo@gmail.com
%}

%% Denosing and Outlier/Dropout Correction For Real Data
clear all;
close all;
fclose all;
clc;

%% Load Data
% Original Data File
infilename = '".\Logs\Tag 23-21-12.log"';
% Pre-processed Data File
outfilename = '.\Logs\wsx.txt';
% Invoke a cpp-generated application to pre-process the original data file
cmd = ['.\Logs\main.exe ', infilename, ' ', outfilename];
system(cmd);
infile = fopen(outfilename,'r');

% Data Format of ".\Logs\wsx.txt": ten columns in total. The first eight
% columns are corresponded to eight UWB anchors, i.e., Range 0 ~ Range 7
dat = fscanf(infile,'%f',[10,inf])';
fclose(infile);
[timeLen, signalNum] = size(dat);

%% Original Ranges
% Range 0 ~ Range 3
% plotTimeIntv = (1:timeLen)*0.1; % sampling time is 0.1
% plot(plotTimeIntv, dat(:,1), 'r', plotTimeIntv, dat(:,2), 'b--', plotTimeIntv, dat(:,3), 'm-.', plotTimeIntv, dat(:,4), 'g:', 'linewidth', 3.5);
% legend('Range 0','Range 1','Range 2','Range 3');
% xlabel('Time (second)','fontsize',14);
% ylabel('UWB Range (meter)','fontsize',14);
% set(gca,'fontsize',14);
% 
% figure;
%
% Range 0 ~ Range 3
% plot(plotTimeIntv, dat(:,5), 'r', plotTimeIntv, dat(:,6), 'b', plotTimeIntv, dat(:,7), 'm', plotTimeIntv, dat(:,8), 'g', 'linewidth', 2.5);
% legend('Range 4','Range 5','Range 6','Range 7');
% xlabel('Time (second)','fontsize',14);
% ylabel('UWB Range (meter)','fontsize',14);
% set(gca,'fontsize',14);

% only plot Range 2
% To generate the Figure 3
plotTimeIntv = (1:timeLen)*0.1; % sampling time is 0.1
plot(plotTimeIntv, dat(:,3), 'r','linewidth',2.5);
legend('Range 2');
xlabel('Time (second)','fontsize',14);
set(gca,'fontsize',14);

%% Outlier/Dropout Correction
%  To generate the Figure 4
Info = cell(signalNum,1);
Err = cell(signalNum,1);

T = 0.1;            % Sampling time
Q = 0.01^2;
MeaThres = 2.0;     % Threshold to determine whether a collected value is an outlier/dropout or not
for i = 1:signalNum-2
    % Original Range
    figure;
    plot(plotTimeIntv, dat(:,i), 'b', 'linewidth', 2.0);
    hold on;
    
    % EXPERIMENTS V-A: Outlier/Dropout Correction (Figure 4)
    [Info{i}, Err{i}] = KFPolynomial(dat(:,i), T, Q, MeaThres);     
    plot(plotTimeIntv, (Info{i}.X(1,:)), 'r--', 'linewidth', 3.5);
    
    % Figure Format
    legend('Original','Corrected');
    xlabel('Time (second)','fontsize',14);
    set(gca,'fontsize',14);
    axis([0 180 0 100]);
end

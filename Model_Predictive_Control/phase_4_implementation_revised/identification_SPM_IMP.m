clc
clear
% close all
global dsp; if isempty(dsp), clear global dsp; dsp=1; end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Specify Experiment Conditions
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PZT sensor (y)
load('iddata.mat')

% ii = 6401;
ii = 281;
iii = 49;

iddata_shaker = shaker_2(iii:ii,3)'+shaker_2(iii:ii,4)'*1i;
freq_vec = shaker_2(iii:ii,2)*2*pi;

ny = 1;
nu = 1;
nf = ii-iii+1;
N = nf;

iddata = zeros(ny,nu,nf);

for i = 1:nf
    Y(:,1,i) = iddata_shaker(:,i);
end

% n = 2;
% n = 4;
% n = 6;
n = 2;
m = nu;
p = ny;

w = real(freq_vec)';
Q = 1*eye(n); 
R = 1e-1*eye(p);   %Initial guess at covariances
T = 1/(800*2.56);

%%
z.y = Y; z.w = w;          % Specify measurements and frequencies they were obtained at
% z.T = T*0;       % Specify sample time
m.A = n;                  % Specify model order
m.type='ss';               % This is the default as well
m.w = w(:);
m.op = 's';                % Specify a continuous time model

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Specify Optional parts about how the estimation procedure runs
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ms.w = w; 
Ms.nx = n; 
Ms.op = 's'; 
Ms.T = T; 

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Estimate on basis of noise corrupted data
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
identified_plant_ss = fsid(z,Ms);

gt = identified_plant_ss;
W = gt.ss.A;
Hs  = gt.ss.B;
V  = gt.ss.C;
D = gt.ss.D;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Display the results
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if dsp 
     data.G = Y; 
     data.w = w(:); 
     data.disp.legend = 'Data';
     data.disp.unit = 'hz';
     data.disp.colour    = 'b';
     data.disp.linestyle = '-';
     data.disp.linewidth = 0.5;
     
     gt.disp.legend = 'identified';
     gt.disp.colour    = 'r';
     gt.disp.linestyle = '-';
     gt.disp.linewidth = 0.5;

     showbode(data,gt);

end
gt_modal = canon(ss(W,Hs,V,D),'modal');
W = gt_modal.A;
Hs  = gt_modal.B;
V  = gt_modal.C;
save identified_shaker W Hs V
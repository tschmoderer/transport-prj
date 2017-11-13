% define les variables globales 

%% tailles du maillage %%

global N; % Nb de points de discrétisation en x
global Q; % Nb de points de discrétisation en t

%% les matrices qui vont nous intéressées  %% 

global B; % matrice de l'opérateur b
global D; % matrice de l'opérateur div
global Interpf; % matrice d'interpolation pour f
global Interpm; % matrice d'interpolation pour m

global P; % matrice de projection sur C
global Cst; % constante dans la projection sur C

clc
clear all
close all
% TODO ; ecrire I commeune grosse matrice sur U. 

globals; 

%% Initialisation %%

N = 32;
Q = 32;

% Matrice de l'opérateur b %
Bm = zeros(2*(Q+1),(N+2)*(Q+1));
Bm(1:Q+1,1:Q+1) = eye(Q+1);
Bm(Q+2:end,end-Q:end) = eye(Q+1);

Bf = [];
for i = 1:N+1
    Bf = blkdiag(Bf,[1 zeros(1,Q+1);zeros(1,Q+1) 1]);
end

B = blkdiag(Bm,Bf);

% Matrice de la divergence %
Dm = zeros((N+1)*(Q+1),(N+2)*(Q+1));
for i = 1:(N+1)*(Q+1)
    for j = 1:(N+2)*(Q+1)
        if i == j 
            Dm(i,j) = -1;
        elseif j == i+Q+1
            Dm(i,j) = 1;
        end
    end
end
dia = zeros(Q+1,Q+2);
for i = 1:Q+1
    for j = 1:Q+2
        if i == j 
            dia(i,j) = -1;
        elseif j == i+1
            dia(i,j) = 1;
        end
    end
end
Df = [];
for i = 1:N+1
    Df = blkdiag(Df,dia);
end

D = [N*Dm Q*Df];

% matrices projection sur C %
A = [D ; B]; 
delta = A*A'; 
sigma = 0.05; mini = 0.0001;
f0 = gauss(0.2,sigma,N,mini); 
f1 = gauss(0.8,sigma,N,mini); 

y = [zeros((N+1)*(Q+1),1) ; zeros(2*(Q+1),1) ; f0' ; f1'];
Cst = A'*(delta\y);

P = eye((N+1)*(Q+2)+(N+2)*(Q+1)) - A'*inv(delta)*A;


%% Fin Initialisation %%

m = zeros(Q+1,N+1);
f = zeros(Q+1,N+1);
mbar = zeros(Q+1,N+2);
fbar = zeros(Q+2,N+1);

V = [reshape(m,(N+1)*(Q+1),1);reshape(f,(N+1)*(Q+1),1)];
U = [reshape(mbar,(N+2)*(Q+1),1);reshape(fbar,(N+1)*(Q+2),1)];

sigma = 0.05; mini = 0.0001;
f0 = gauss(0.2,sigma,N,mini); 
f1 = gauss(0.8,sigma,N,mini); 

b0 = [zeros(2*(Q+1),1) ; f0' ; f1'];

alpha = 0.5; gamma = 1;

wU0 = zeros(size(U)); wV0 = zeros(size(V));
zU0 = zeros(size(U)); zV0 = zeros(size(V));

[XX,YY] = meshgrid([0:N],[0:Q]);

for l = 1:100
    [wU1 , wV1] = proxG1(2*zU0-wU0,2*zV0-wV0,gamma);
    wU1 = wU0 + alpha*(wU1- zU0); wV1 = wV0 + alpha*(wV1- zV0);
    
    [zU0,zV0] = proxG2(wU1,wV1,N,Q);
    wU0 = wU1;
    wV0 = wV1;
    
    f = reshape(zV0((N+1)*(Q+1)+1:end),Q+1,N+1);
    surf(XX,YY,f)
    xlabel('x');
    ylabel('y');
    zlabel('f');
    pause(0.04)
end
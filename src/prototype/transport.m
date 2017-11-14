clc
clear all
close all

globals; 

%% Initialisation %%

N = 101;
Q = 97;

% Matrice de l'opérateur b %
Bm = zeros(2*(Q+1),(N+2)*(Q+1));
Bm(1:Q+1,1:Q+1) = eye(Q+1);
Bm(Q+2:end,end-Q:end) = eye(Q+1);

Bf = [];
for i = 1:N+1
    Bf = blkdiag(Bf,[1 zeros(1,Q+1);zeros(1,Q+1) 1]);
end

B = blkdiag(Bm,Bf);
% matrice d'interpolation %

Im = zeros((N+1)*(Q+1),(N+2)*(Q+1));
for i = 1:(N+1)*(Q+1)
    for j = 1:(N+2)*(Q+1)
        if i == j 
            Im(i,j) = 1;
        elseif j == i+Q+1
            Im(i,j) = 1;
        end
    end
end
dia = zeros(Q+1,Q+2);
for i = 1:Q+1
    for j = 1:Q+2
        if i == j 
            dia(i,j) = 1;
        elseif j == i+1
            dia(i,j) = 1;
        end
    end
end
If = [];
for i = 1:N+1
    If = blkdiag(If,dia);
end

Interp = 0.5*blkdiag(Im,If);

% matrice de projection sur G2
pG2 = inv(eye((N+1)*(Q+2)+(N+2)*(Q+1)) + Interp'*Interp);

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

y = [zeros((N+1)*(Q+1),1) ; zeros(2*(Q+1),1) ; reshape([f1;f0],2*(N+1),1)];
Cst = A'*(delta\y);

P = eye((N+1)*(Q+2)+(N+2)*(Q+1)) - A'*(delta\A);


%% Fin Initialisation %%

m = zeros(Q+1,N+1);
f = zeros(Q+1,N+1);
mbar = zeros(Q+1,N+2);
fbar = zeros(Q+2,N+1);

V = [reshape(m,(N+1)*(Q+1),1);reshape(f,(N+1)*(Q+1),1)];
U = [reshape(mbar,(N+2)*(Q+1),1);reshape(fbar,(N+1)*(Q+2),1)];

alpha = 1; gamma = 0.5;

wU0 = zeros(size(U)); wV0 = zeros(size(V));
zU0 = zeros(size(U)); zV0 = zeros(size(V));

% test
%wU0 = ones(size(U)); wV0 = ones(size(V));
%zU0 = ones(size(U)); zV0 = ones(size(V));
%wU0 = wU0/sum(wU0(:)); wV0 = wV0/sum(wV0(:)); %zU0 = zU0/sum(zU0(:)); zV0 = zV0/sum(zV0(:)); 
% fin test

[XX,YY] = meshgrid(linspace(0,1,N+1),linspace(0,1,Q+1)); YY = flipud(YY);

% Itérations
niter = 300;
cout = zeros(1,niter);
div = zeros(1,niter);
for l = 1:niter
    [wU1 , wV1] = proxG1(2*zU0-wU0,2*zV0-wV0,gamma);
    wU1 = wU0 + alpha*(wU1- zU0); wV1 = wV0 + alpha*(wV1- zV0);
    
    [zU0,zV0] = proxG2(wU1,wV1);
    wU0 = wU1;
    wV0 = wV1;
    
    f = reshape(zV0((N+1)*(Q+1)+1:end),Q+1,N+1);
    surf(XX,YY,f)
    xlabel('x');
    ylabel('t');
    zlabel('f');
    title(['itération : ',num2str(l)]);
    pause(0.04)
    
    cout(l) = cost(zV0);
    div(l) = sum(D*zU0);
end

figure;
subplot(2,1,1)
plot([1:niter],cout);
title('cout')
subplot(2,1,2)
plot([1:niter],div)
title('div')
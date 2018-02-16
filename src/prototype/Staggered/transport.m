clc
clear all
close all 

globals;

N = 17; P = 15; Q = 19; niter = 1000;
eps = 1e-10; alpha = 1.0; g = 1.0; b = 1.0;

f0 = zeros(N+1,P+1); f1 = zeros(N+1,P+1);
zV = zeros(N+1,P+1,Q+1,3); wV0 = zeros(N+1,P+1,Q+1,3); wV1 = zeros(N+1,P+1,Q+1,3);
zU = zeros(N+2,P+2,Q+2,3); wU0 = zeros(N+2,P+2,Q+2,3); wU1 = zeros(N+2,P+2,Q+2,3);
obstacle = zeros(N+1,P+1,Q+1);
cout = zeros(1,niter); minF = zeros(1,niter);

J = @(w) 0.5*sum(sum(sum(sum((w(:,:,:,1).^2 + w(:,:,:,2).^2./max(w(:,:,:,3),max(eps,1e-10)).^b)))));

normalise = @(f) f/sum(f(:));
	 
f0 = normalise(eps + gauss(0.2,0.2,0.05));
f1 = normalise(eps + gauss(0.5,0.5,0.05));

eps = min(f0(:));


T = ([-1:Q]+0.5)/(Q); TT = zeros(N+2,P+2,Q+2); F0 = []; F1 = []; 
for i = 1:Q+2, TT(:,:,i) = T(i)*ones(N+2,P+2); F0 = cat(3,F0,[f0 ones(N+1,1); ones(1,P+2)]); F1 = cat(3,F1,[f1 ones(N+1,1); ones(1,P+2)]);end
wU0(:,:,:,3) = (1-TT).*F0 + TT.*F1;
wV0 = interp(wU0); 
zU = wU0; zV = wV0;



for i = 1:niter
    wU1 = wU0 + alpha*(projC(2*zU - wU0) - zU);
    wV1 = wV0 + alpha*(proxJ(2*zV - wV0,b,g,obstacle) - zV);
    zU  = projCs(wU1,wV1);
    zV  = interp(zU);

    wU0 = wU1;
    wV0 = wV1;

    cout(i) = J(zV);
    minF(i) = min(min(min(zV(:,:,:,3))));
    
    contour(zV(:,:,floor(Q/2),3))
    title(['Iteration : ',num2str(i)]);
    drawnow
    if (mod(i,10) == 0) 
        fprintf('Iteration : %3d, cout : %f\n',i, cout(i));
    end  
end

surf(zV(:,:,10,3))

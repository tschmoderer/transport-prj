function V = interp(U)
    globals;
    V = zeros(N+1,P+1,Q+1,3);
    V(:,:,:,1) = U(1:N+1,1:P+1,1:Q+1,1) + U(2:N+2,1:P+1,1:Q+1,1);
    V(:,:,:,2) = U(1:N+1,1:P+1,1:Q+1,2) + U(1:N+1,2:P+2,1:Q+1,2);
    V(:,:,:,3) = U(1:N+1,1:P+1,1:Q+1,3) + U(1:N+1,1:P+1,2:Q+2,3);
    V = 0.5*V;
end


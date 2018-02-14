function U = divAdj(D)
    globals;
    U = zeros(Q+2,N+2,2);

    U(1:Q+1,1,1)     = -D(:,1);
    U(1:Q+1,2:N+1,1) = D(:,1:N) - D(:,2:N+1);
    U(1:Q+1,N+2,1)   = D(:,N+1);
    U(:,:,1) = N*U(:,:,1);

    U(1,1:N+1,2)     = -D(1,:) ;
    U(2:Q+1,1:N+1,2) = D(1:Q,:) - D(2:Q+1,:);
    U(Q+2,1:N+1,2)   = D(Q+1,:) ;
    U(:,:,2) = Q*U(:,:,2);
end

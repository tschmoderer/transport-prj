! Optimized version for Joconde case

program transport
    implicit none
	integer, parameter :: N = 143, P = 175, Q = 200, niter = 100
	double precision, parameter :: eps = 1e-10, alpha = 1.98, g = 1./230, b = 1.
	double precision, parameter :: pi = 4.D0*DATAN(1.D0)
	double precision, dimension(N+1,P+1) :: f0, f1
	double precision, dimension(N+1,P+1,Q+1,3) :: zV = 0, wV0 = 0, wV1 = 0
	double precision, dimension(N+2,P+2,Q+2,3) :: zU = 0, wU0 = 0, wU1 = 0
	integer, dimension(N+1,P+1,Q+1) :: obstacle = 0
	double precision, dimension(niter) :: cout, minF, divV
	double precision :: t
	integer :: i, k, l 
	character(10) :: charI;
	double precision, dimension(N+1,N+1) :: ADCT 
	double precision, dimension(P+1,P+1) :: ADCT2
	double precision, dimension(Q+1,Q+1) :: ADCT3
	double precision, dimension(N+1) :: a1
	double precision, dimension(P+1) :: a2
	double precision, dimension(Q+1) :: a3
	integer :: u,x,v,y,w,z
 
	a1 = dsqrt(2d0/(1.*(N+1))); a1(1) = 1./dsqrt(1d0*(N+1))
	a2 = dsqrt(2d0/(1.*(P+1))); a2(1) = 1./dsqrt(1d0*(P+1))
	a3 = dsqrt(2d0/(1.*(Q+1))); a3(1) = 1./dsqrt(1d0*(Q+1))
	do u = 1,N+1
		do x = 1,N+1
			ADCT(u,x) = a1(u)*dcos(pi*(2*x-1)*(u-1)/(2.*(N+1)))
		end do 
	end do 
	do v = 1,P+1
		do y = 1,P+1
			ADCT2(v,y) = a2(v)*dcos(pi*(2*y-1)*(v-1)/(2.*(P+1)))
		end do 
	end do 
	do w = 1,Q+1
		do z = 1,Q+1
			ADCT3(w,z) = a3(w)*dcos(pi*(2*z-1)*(w-1)/(2.*(Q+1)))
		end do 
	end do 	 

    !open(1,file='input/joconde.dat')
    !open(2,file='input/marylin.dat')
    open(1,file='input/car/f0.dat')
    open(2,file='input/car/f1.dat')
		do i = N+1,1,-1
		read(1,*) f0(i,:)
		read(2,*) f1(i,:)
		end do
    close(1)
    close(2)    

    f0 = normalise(eps + f0)
    f1 = normalise(eps + f1)
    
    do i = 1,Q+2
		t = (i-1)/(1.*(Q+1))
		wU0(1:N+1,1:P+1,i,3) = (1-t)*f0 + t*f1
    end do 
    wV0 = interp(wU0)
    zU = wU0; zV = wV0
    
    do i = 1,niter
			! A - DR
			wU1 = wU0 + alpha*(projC(2*zU - wU0) - zU)
			wV1 = wV0 + alpha*(proxJ(2*zV - wV0) - zV)
			zU  = projCs(wU1,wV1)
			zV  = interp(zU)
		
			wU0 = wU1
			wV0 = wV1
		
			! record data
			cout(i) = J(zV)
			minF(i) = minval(zV(:,:,:,3))
			divV(i) = sum(div(Zu)**2)
        
        if (modulo(i,1) .EQ. 0) print *, i, cout(i), divV(i), sum(zV - interp(zU))
    end do 
  
    open(1,file='results/data.dat');
    write(1,*) "# ", "iter ", "energie ", "minF ", "divV "
    do i = 1,niter
		write(1,*) i, cout(i), minF(i), divV(i)
    end do
    close(1)  
    
!    open(1,file='results/transport.dat');
!    write(1,*) "# ", "X ", "Y ", "T ", "Z "
!    do i = 1,N+1 ! y direction
!        do k = 1,P+1 ! x direction 
!					do l = 1,Q+2 ! t direction
!           	write(1,*) i, k, l,  zU(i,k,l,3)
!           end do
!        end do
!   	end do
!    close(1)
    
	do l = 1,Q+2
		write(charI,'(I5.5)') l
		open(1,file='results/Transport/3D_'//trim(charI)//'.dat'); 
		write(1,*) "# ", "X ", "Y ", "F "
		do i = 1,P+1 ! y direction
			do k = 1,N+1 ! x direction 
				write(1,*) (k-1)/(1.0*N), (i-1)/(1.0*P),  zU(k,i,l,3)
			end do
			!write(1,*)  zU(i,:,l,3)
		end do
		close(1)
	end do    
    
	  do l = 1,Q+2
			write(charI,'(I5.5)') l
			open(1,file='results/Transport/C_'//trim(charI)//'.dat'); 
			do i = 1,N+1 	
					write(1,*) zU(i,1:P+1,l,3)
				end do
			close(1)
		end do  
	
		do l = 1,Q+1
			write(charI,'(I5.5)') l
			open(1,file='results/Obstacle/O_'//trim(charI)//'.dat'); 
			open(2,file='results/Obstacle/T_'//trim(charI)//'.dat'); 
			do i = 1,N+1 	
					write(1,*) obstacle(i,:,l)
					write(2,*) zV(i,:,l,3)
				end do
			close(1); close(2)
		end do  
	
    open(1,file='results/f0.dat');
    do i = 1,N+1
			write(1,*) f0(i,:)
    end do
    close(1)

    open(1,file='results/f1.dat');
    do i = 1,N+1
			write(1,*) f1(i,:)
    end do
    close(1)

		open(8,file='results/plot.gnu'); 
		write(8,*) 'set dgrid3d ', P+1, ',', N+1
		close(8);
	
		open(8,file='results/plot3D.gnu'); 
		write(8,*) 'set zr [', minval(minF) , ':', maxval(zU(:,:,:,3)), ']'
		close(8);
  
  	open(8,file='results/plotC.gnu'); 
		write(8,*) 'set cntrparam levels incremental' , 1E-3, ',' , &
		(maxval(dabs(zU(:,:,:,3))) - 1E-3)/15., ',' , maxval(dabs(zU(:,:,:,3)))
		close(8);
  
  
    contains

!! Gauss
    function gauss(muX,muY,sigma) result(f) 
		implicit none
        double precision :: muX, muY, sigma, x, y
        double precision, dimension(N+1,P+1) :: f
        integer :: i,j
        do i = 1,N+1
					do j = 1,P+1
						x = (i-1)/(1.0*N)
						y = (j-1)/(1.0*P)
						f(i,j) = exp(-0.5*((x-muX)**2 + (y-muY)**2)/sigma**2)
					end do
        end do 
    end function gauss
	
!! Normalise
    function normalise(f) result(nf) 
	implicit none
	    double precision, dimension(N+1,P+1) :: f, nf
        nf = f/sum(f)
    end function

!! Cout 
    function J(w) result(c) 
    implicit none
        double precision, dimension(N+1,P+1,Q+1,3) :: w
        double precision :: c
        c = 0.5*sum((w(:,:,:,1)**2 + w(:,:,:,2)**2)/max(w(:,:,:,3),eps,1e-10)**b)
    end function J 

!! Proximal de J 
    function proxJ(w) result(pw)
    implicit none
        double precision, dimension(N+1,P+1,Q+1,3) :: w, pw
        double precision, dimension(N+1,P+1,Q+1,2) :: mt
        double precision, dimension(N+1,P+1,Q+1)   :: ft, x1
        double precision, dimension(N+1,P+1,Q+1)   :: d0, d1, theta, x2, x3, a
        
        mt = w(:,:,:,1:2); ft = w(:,:,:,3);
        
        	! résolution polynôme de degré 3
        	! http://www.aip.de/groups/soe/local/numres/bookfpdf/f5-6.pdf
				d0 = ((2*g - ft)**2 - 3.*(g**2 - 2*g*ft))/9.
				d1 = (2*(2*g - ft)**3 - 9*(2*g - ft)*(g**2 - 2*g*ft) + 27*(-ft*g**2 -0.5*g*(mt(:,:,:,1)**2 + mt(:,:,:,2)**2)))/54.
        	
      	where (d1**2 - d0**3 .LT. 0) 
						theta = dacos(d1/dsqrt(d0**3))
						x1 = -2*dsqrt(d0)*dcos(theta/3.) - (2*g - ft)/3.
						x2 = -2*dsqrt(d0)*dcos((theta+2*pi)/3.) - (2*g - ft)/3.
						x3 = -2*dsqrt(d0)*dcos((theta-2*pi)/3.) - (2*g - ft)/3.
						x1 = max(x1,x2,x3)
				else where
						a = -(d1/dabs(d1))*(dabs(d1) + dsqrt(d1**2 - d0**3))**(1/3.)
						where ( a .NE. 0)
							x1 = (a + d0/a) -(2*g - ft)/3.
						else where
							x1 = -(2*g - ft)/3.
						end where
      	end where

        where ((x1 .LT. eps) .OR. (obstacle .GT. 0)) x1 = eps
        
        pw(:,:,:,1) = (x1**b)*mt(:,:,:,1)/(x1**b+g) 
        pw(:,:,:,2) = (x1**b)*mt(:,:,:,2)/(x1**b+g) 
        pw(:,:,:,3) = x1
    end function proxJ
    
!! Interpolation 
	function interp(U) result(V)
	implicit none 
		double precision, dimension(N+2,P+2,Q+2,3) :: U
		double precision, dimension(N+1,P+1,Q+1,3) :: V
		V(:,:,:,1) = U(1:N+1,1:P+1,1:Q+1,1) + U(2:N+2,1:P+1,1:Q+1,1)
		V(:,:,:,2) = U(1:N+1,1:P+1,1:Q+1,2) + U(1:N+1,2:P+2,1:Q+1,2)
		V(:,:,:,3) = U(1:N+1,1:P+1,1:Q+1,3) + U(1:N+1,1:P+1,2:Q+2,3)
		V = 0.5*V
	end function interp

!! Interpolation adjoint 
	function interpAdj(V) result(U)
		double precision, dimension(N+2,P+2,Q+2,3) :: U
		double precision, dimension(N+1,P+1,Q+1,3) :: V
		U = 0
		
		U(1    ,1:P+1,1:Q+1,1) = V(1,:,:,1)
		U(2:N+1,1:P+1,1:Q+1,1) = V(1:N,:,:,1) + V(2:N+1,:,:,1)
		U(N+2  ,1:P+1,1:Q+1,1) = V(N+1,:,:,1)
		
		U(1:N+1,1    ,1:Q+1,2) = V(:,1,:,2)
		U(1:N+1,2:P+1,1:Q+1,2) = V(:,1:P,:,2) + V(:,2:P+1,:,2)
		U(1:N+1,P+2  ,1:Q+1,2) = V(:,P+1,:,2)
		
		U(1:N+1,1:P+1,1    ,3) = V(:,:,1,3)
		U(1:N+1,1:P+1,2:Q+1,3) = V(:,:,1:Q,3) + V(:,:,2:Q+1,3)
		U(1:N+1,1:P+1,Q+2  ,3) = V(:,:,Q+1,3)
		
		U = 0.5*U 	
	end function interpAdj

!! Projection sur Cs
	function projCs(U,V) result(pU)
	implicit none
		double precision, dimension(N+2,P+2,Q+2,3) :: U, b, r, dir, Ip, pU
		double precision, dimension(N+1,P+1,Q+1,3) :: V
		double precision :: alpha, rnew, rold
		integer :: i 
		b = U + interpAdj(V)
		pU = 0
		r = b - pU - interpAdj(interp(pU))
		dir = r
		rold = sum(r*r)
		do i = 1,3*(N+2)*(P+2)*(Q+2)
			Ip = dir + interpAdj(interp(dir))
			alpha = rold/sum(dir*Ip)
			pU = pU + alpha*dir
			r = r - alpha*Ip
			rnew = sum(r*r) 
			if (dsqrt(rnew) .LT. 1e-10) exit
			dir = r + (rnew/rold)*dir
			rold = rnew
		end do 
	end function projCs

!! Divergence 
	function div(U) result(D) 
	implicit none
		double precision, dimension(N+2,P+2,Q+2,3) :: U
		double precision, dimension(N+1,P+1,Q+1) :: D
		D =     (N+1)*(U(2:N+2,1:P+1,1:Q+1,1) - U(1:N+1,1:P+1,1:Q+1,1))
		D = D + (P+1)*(U(1:N+1,2:P+2,1:Q+1,2) - U(1:N+1,1:P+1,1:Q+1,2))
		D = D + (Q+1)*(U(1:N+1,1:P+1,2:Q+2,3) - U(1:N+1,1:P+1,1:Q+1,3))
	end function div

!! Adjoint de la divergence 
	function divAdj(D) result(U)
	implicit none
		double precision, dimension(N+2,P+2,Q+2,3):: U
		double precision, dimension(N+1,P+1,Q+1)  :: D
		U = 0
		
		U(1    ,1:P+1,1:Q+1,1) = - D(1,:,:)
		U(2:N+1,1:P+1,1:Q+1,1) =   D(1:N,:,:) - D(2:N+1,:,:)
		U(N+2  ,1:P+1,1:Q+1,1) =   D(N+1,:,:)
		U(:,:,:,1) = (N+1)*U(:,:,:,1)
		
		U(1:N+1,1    ,1:Q+1,2) = - D(:,1,:)
		U(1:N+1,2:P+1,1:Q+1,2) =   D(:,1:P,:) - D(:,2:P+1,:)
		U(1:N+1,P+2  ,1:Q+1,2) =   D(:,P+1,:)
		U(:,:,:,2) = (P+1)*U(:,:,:,2)
		
		U(1:N+1,1:P+1,1    ,3) = - D(:,:,1)
		U(1:N+1,1:P+1,2:Q+1,3) =   D(:,:,1:Q) - D(:,:,2:Q+1)
		U(1:N+1,1:P+1,Q+2  ,3) =   D(:,:,Q+1)
		U(:,:,:,3) = (Q+1)*U(:,:,:,3)
	end function divAdj

!! Projection sur C
	function projC(U) result(pU) 
	implicit none 
		double precision, dimension(N+2,P+2,Q+2,3) :: U, pU, gf
		double precision, dimension(N+1,P+1,Q+1)   :: D, f	

		U(1:N+1,1:P+1,1  ,3) = f0
		U(1:N+1,1:P+1,Q+2,3) = f1
		
		U(1  ,1:P+1,1:Q+1,1) = 0
		U(N+2,1:P+1,1:Q+1,1) = 0
		
		U(1:N+1,1  ,1:Q+1,2) = 0
		U(1:N+1,P+2,1:Q+1,2) = 0
		
		D = div(U)
		f = poisson(-D)
		
		gf = divAdj(f)
		
		pU = U
		pU(2:N+1,1:P+1,1:Q+1,1) = pU(2:N+1,1:P+1,1:Q+1,1) + gf(2:N+1,1:P+1,1:Q+1,1)
		pU(1:N+1,2:P+1,1:Q+1,2) = pU(1:N+1,2:P+1,1:Q+1,2) + gf(1:N+1,2:P+1,1:Q+1,2)
		pU(1:N+1,1:P+1,2:Q+1,3) = pU(1:N+1,1:P+1,2:Q+1,3) + gf(1:N+1,1:P+1,2:Q+1,3)
	end function projC

!! poisson 
	function poisson(f) result(poi)
	implicit none 
		double precision, dimension(N+1,P+1,Q+1) :: f, poi, denom, fhat, uhat
		double precision, dimension(N+1) :: dn, depn
		double precision, dimension(P+1) :: dp, depp
		double precision, dimension(Q+1) :: dq, depq
		integer :: i, j
		
		do i = 1,N+1
			dn(i) = (i-1)/(1.*(N+1))
		end do
		depn = (2*dcos(pi*dn) - 2)*(N+1)**2
		do i = 1,P+1
			dp(i) = (i-1)/(1.*(P+1))
		end do
		depp = (2*dcos(pi*dp) - 2)*(P+1)**2	
		do i = 1,Q+1
			dq(i) = (i-1)/(1.*(Q+1))
		end do
		depq = (2*dcos(pi*dq) - 2)*(Q+1)**2		
		
		
		do i = 1,N+1
			do j = 1,P+1
				denom(i,j,:) = depn(i) + depp(j) + depq
			end do 
		end do
	
		where (denom .EQ. 0) denom = 1.
		
		fhat = dct3(f)
		uhat = -fhat/denom
		poi  = idct3(uhat)	
	end function poisson
	
	function dct3(f) result(df)
	implicit none
		double precision, dimension(N+1,P+1,Q+1) :: f, df
		double precision, dimension(N+1,P+1,Q+1) :: tmp1, tmp2
		integer :: i1,i2,i3		
		! F (x)_1 A1
		do i2 = 1,P+1
			do i3 = 1,Q+1
				tmp1(:,i2,i3) = matmul(ADCT,f(:,i2,i3))
			end do
		end do
		! tmp1 (x)_2 A2
		do i3 = 1,Q+1
			do i1 = 1,N+1
				tmp2(i1,:,i3) = matmul(ADCT2,tmp1(i1,:,i3))
			end do
		end do
		! tmp2 (x)_3 A3
		do i1 = 1,N+1
			do i2 = 1,P+1
				df(i1,i2,:) = matmul(ADCT3,tmp2(i1,i2,:))
			end do
		end do
	end function dct3

	function idct3(df) result(f)
	implicit none
		double precision, dimension(N+1,P+1,Q+1) :: f, df
		double precision, dimension(N+1,P+1,Q+1) :: tmp1, tmp2
		integer :: i1,i2,i3
		
		! F (x)_1 A1
		do i2 = 1,P+1
			do i3 = 1,Q+1
				tmp1(:,i2,i3) = matmul(transpose(ADCT),df(:,i2,i3))
			end do
		end do
		! tmp1 (x)_2 A2
		do i3 = 1,Q+1
			do i1 = 1,N+1
				tmp2(i1,:,i3) = matmul(transpose(ADCT2),tmp1(i1,:,i3))
			end do
		end do
		! tmp2 (x)_3 A3
		do i1 = 1,N+1
			do i2 = 1,P+1
				f(i1,i2,:) = matmul(transpose(ADCT3),tmp2(i1,i2,:))
			end do
		end do
	end function idct3
end program transport

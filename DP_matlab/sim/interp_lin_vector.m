function y = interp_lin_vector( X , Y , x )
%
% y = interp_lin_vector( X , Y , x )
%
%            Y(k+1) + Y(k)
% y = Y(k) + ------------- ( x - X(k) ) 
%            X(k+1) - X(k)
%
% with 'k' such that X(k) <= x < X(k+1)
%
% input :
% X = vector of independent variables - ( N , 1 )
% Y = vector of dependent variables   - ( N , 1 )
% x = points to be evaluated          - ( n , 1 )
%
% output :
% y = evaluations                     - ( n , 1 )
%
% Last update : Daniela 12/06/2013
% update: computation in extreme cases

x = x(:) ; % turn to column vector
X = X(:) ; % turn to column vector
Y = Y(:) ; % turn to column vector
y = nan * ones( size( x ) ) ; % output vector

% ---------------------------------------------
% Extreme cases 
% (elements of 'x' outside of the range of 'X')
% ---------------------------------------------

% y( x <= X( 1 ) ) = Y( 1 ) ;
% y( x >= X(end) ) = Y(end) ;

% if x > X(end) ; 
%     y = Y(end) + (Y(end)-Y(end-1))/(X(end)-X(end-1))*(x-X(end)) ; 
%     return ;
% elseif x < X(1)
%     y = Y(1) + (Y(2)-Y(1))/(X(2)-X(1))*(x-X(1)) ; 
%     return ;
% end
if any(x >= X(end)) ; 
    idx = x >= X(end) ; 
    y(idx) = Y(end) + (Y(end)-Y(end-1))/(X(end)-X(end-1))*(x(idx)-X(end)) ; 
    clear idx
end
if any(x <= X(1))
    idx = x <= X(1) ;
    if X(2)-X(1) == 0
        y(idx) = x ;
    else
    y(idx) = Y(1) + (Y(2)-Y(1))/(X(2)-X(1))*(x(idx)-X(1)) ; 
    clear idx
    end
end

% -------------
% Otherwise
% -------------

idx = ( x > X(1) )&( x < X(end) ) ;
xx = x( idx )                     ;
yy = nan * ones( size( xx ) )     ;

% Find index 'k' of subinterval [ X(k) , X(k+1) ] s.t. X(k) <= x < X(k+1) :
n  = length( xx )             ;
N  = length( X )              ;
[ ignore , i ] = min( abs( repmat( X, 1, n ) - repmat( xx', N, 1 ) ) ) ;
% if X( i ) < x     then   k = i
% if X( i ) > x     then   k = i - 1
k = i' - ( X( i ) > xx )   ;
% (remember that 'i' is a row vector while 'xx' and 'X' are column vectors)

% Line joining points ( X(k) , Y(k) ) and ( X(k+1) , Y(k+1) ) :
Dy = Y( k + 1 ) - Y( k ) ;
Dx = X( k + 1 ) - X( k ) ;
m  = Dy ./ Dx            ; % slope

% Interpolate :
yy = Y( k ) +  m .* ( xx - X( k ) ) ;

% % BUT! if X( i ) = x , then y = Y( i ) :
% yy( X( i ) == xx ) = Y( X( i ) == xx ) ;

% Save results in the output vector :
y( idx ) = yy ;
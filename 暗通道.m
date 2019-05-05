clear;
clc;
I=imread('E:\DELL\matlab_code\code\land.jpg');
figure;
imshow(I);%显示原始图像
sz=size(I);%图像的行列数
hang=sz(1);%图像的行数
lie=sz(2);%图像的列数
kong=zeros(hang,lie);%创建存放RGB最小值的图像
for x=1:hang
    for y=1:lie
        kong(x,y)=min(I(x,y,:));%求出每个像素RGB分量中的最小值，存入一副和原始图像大小相同的灰度图中
    end
end
figure;imshow(uint8(kong));title('最小值图像');
%然后再对这幅灰度图进行最小值滤波，滤波的半径由窗口大小决定，一般有WindowSize = 2 * Radius + 1;   
Radius=0.01;
chuangkou=floor(max(Radius*hang+1,Radius*lie+1));
antongdaotu=minfilt2(kong,[chuangkou,chuangkou]);%得到了暗通道图像Jdark
antongdaotu(hang,lie)=0;
figure;imshow(uint8(antongdaotu));title('暗通道图');
%求透射率预估值
w=1;
t=255-w*antongdaotu;
figure;imshow(uint8(t));title('透射率预估值');
t_d=double(t)/255;
%求大气光A
t0=0.1;
A=max(max(antongdaotu));
J=zeros(hang,lie,3);%转换为RGB图像
I_D=double(I);
J(:,:,1)=(I_D(:,:,1)+A*(max(t_d,t0)-1))./max(t_d,t0);
J(:,:,2)=(I_D(:,:,2)+A*(max(t_d,t0)-1))./max(t_d,t0);
J(:,:,3)=(I_D(:,:,3)+A*(max(t_d,t0)-1))./max(t_d,t0) ;
figure;imshow(uint8(J));title('经典的无雾图像');
imwrite(uint8(J),'C:\Users\DELL\Desktop\chengxu\暗通道\land.jpg');





function Y = minfilt2(X,varargin)
%  MINFILT2    Two-dimensional min filter
%
%     Y = MINFILT2(X,[M N]) performs two-dimensional minimum
%     filtering on the image X using an M-by-N window. The result
%     Y contains the minimun value in the M-by-N neighborhood around
%     each pixel in the original image. 
%     This function uses the van Herk algorithm for min filters.
%
%     Y = MINFILT2(X,M) is the same as Y = MINFILT2(X,[M M])
%
%     Y = MINFILT2(X) uses a 3-by-3 neighborhood.
%
%     Y = MINFILT2(..., 'shape') returns a subsection of the 2D
%     filtering specified by 'shape' :
%        'full'  - Returns the full filtering result,
%        'same'  - (default) Returns the central filter area that is the
%                   same size as X,
%        'valid' - Returns only the area where no filter elements are outside
%                  the image.
%
%     See also : MAXFILT2, VANHERK
%

% Initialization
[S, shape] = parse_inputs(varargin{:});

% filtering
Y = vanherk(X,S(1),'min',shape);
Y = vanherk(Y,S(2),'min','col',shape);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S, shape] = parse_inputs(varargin)
shape = 'same';
flag = [0 0]; % size shape

for i = 1 : nargin
   t = varargin{i};
   if strcmp(t,'full') & flag(2) == 0
      shape = 'full';
      flag(2) = 1;
   elseif strcmp(t,'same') & flag(2) == 0
      shape = 'same';
      flag(2) = 1;
   elseif strcmp(t,'valid') & flag(2) == 0
      shape = 'valid';
      flag(2) = 1;
   elseif flag(1) == 0
      S = t;
      flag(1) = 1;
   else
      error(['Too many / Unkown parameter : ' t ])
   end
end

if flag(1) == 0
   S = [3 3];
end
if length(S) == 1;
   S(2) = S(1);
end
if length(S) ~= 2
   error('Wrong window size parameter.')
end







function Y = maxfilt2(X,varargin)
%  MAXFILT2    Two-dimensional max filter
%
%     Y = MAXFILT2(X,[M N]) performs two-dimensional maximum
%     filtering on the image X using an M-by-N window. The result
%     Y contains the maximun value in the M-by-N neighborhood around
%     each pixel in the original image. 
%     This function uses the van Herk algorithm for max filters.
%
%     Y = MAXFILT2(X,M) is the same as Y = MAXFILT2(X,[M M])
%
%     Y = MAXFILT2(X) uses a 3-by-3 neighborhood.
%
%     Y = MAXFILT2(..., 'shape') returns a subsection of the 2D
%     filtering specified by 'shape' :
%        'full'  - Returns the full filtering result,
%        'same'  - (default) Returns the central filter area that is the
%                   same size as X,
%        'valid' - Returns only the area where no filter elements are outside
%                  the image.
%
%     See also : MINFILT2, VANHERK
%

% Initialization
[S, shape] = parse_inputs(varargin{:});

% filtering
Y = vanherk(X,S(1),'max',shape);
Y = vanherk(Y,S(2),'max','col',shape);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [S, shape] = parse_inputs(varargin)
shape = 'same';
flag = [0 0]; % size shape

for i = 1 : nargin
   t = varargin{i};
   if strcmp(t,'full') & flag(2) == 0
      shape = 'full';
      flag(2) = 1;
   elseif strcmp(t,'same') & flag(2) == 0
      shape = 'same';
      flag(2) = 1;
   elseif strcmp(t,'valid') & flag(2) == 0
      shape = 'valid';
      flag(2) = 1;
   elseif flag(1) == 0
      S = t;
      flag(1) = 1;
   else
      error(['Too many / Unkown parameter : ' t ])
   end
end

if flag(1) == 0
   S = [3 3];
end
if length(S) == 1;
   S(2) = S(1);
end
if length(S) ~= 2
   error('Wrong window size parameter.')
end










function Y = vanherk(X,N,TYPE,varargin)
%  VANHERK    Fast max/min 1D filter
%
%    Y = VANHERK(X,N,TYPE) performs the 1D max/min filtering of the row
%    vector X using a N-length filter.
%    The filtering type is defined by TYPE = 'max' or 'min'. This function
%    uses the van Herk algorithm for min/max filters that demands only 3
%    min/max calculations per element, independently of the filter size.
%
%    If X is a 2D matrix, each row will be filtered separately.
%    
%    Y = VANHERK(...,'col') performs the filtering on the columns of X.
%    
%    Y = VANHERK(...,'shape') returns the subset of the filtering specified
%    by 'shape' :
%        'full'  - Returns the full filtering result,
%        'same'  - (default) Returns the central filter area that is the
%                   same size as X,
%        'valid' - Returns only the area where no filter elements are outside
%                  the image.
%
%    X can be uint8 or double. If X is uint8 the processing is quite faster, so
%    dont't use X as double, unless it is really necessary.
%

% Initialization
[direc, shape] = parse_inputs(varargin{:});
if strcmp(direc,'col')
   X = X';
end
if strcmp(TYPE,'max')
   maxfilt = 1;
elseif strcmp(TYPE,'min')
   maxfilt = 0;
else
   error([ 'TYPE must be ' char(39) 'max' char(39) ' or ' char(39) 'min' char(39) '.'])
end

% Correcting X size
fixsize = 0;
addel = 0;
if mod(size(X,2),N) ~= 0
   fixsize = 1;
   addel = N-mod(size(X,2),N);
   if maxfilt
      f = [ X zeros(size(X,1), addel) ];
   else
      f = [X repmat(X(:,end),1,addel)];
   end
else
   f = X;
end
lf = size(f,2);
lx = size(X,2);
clear X

% Declaring aux. mat.
g = f;
h = g;

% Filling g & h (aux. mat.)
ig = 1:N:size(f,2);
ih = ig + N - 1;

g(:,ig) = f(:,ig);
h(:,ih) = f(:,ih);

if maxfilt
   for i = 2 : N
      igold = ig;
      ihold = ih;

      ig = ig + 1;
      ih = ih - 1;

      g(:,ig) = max(f(:,ig),g(:,igold));
      h(:,ih) = max(f(:,ih),h(:,ihold));
   end
else
   for i = 2 : N
      igold = ig;
      ihold = ih;

      ig = ig + 1;
      ih = ih - 1;

      g(:,ig) = min(f(:,ig),g(:,igold));
      h(:,ih) = min(f(:,ih),h(:,ihold));
   end
end
clear f

% Comparing g & h
if strcmp(shape,'full')
   ig = [ N : 1 : lf ];
   ih = [ 1 : 1 : lf-N+1 ];
   if fixsize
      if maxfilt
         Y = [ g(:,1:N-1)  max(g(:,ig), h(:,ih))  h(:,end-N+2:end-addel) ];
      else
         Y = [ g(:,1:N-1)  min(g(:,ig), h(:,ih))  h(:,end-N+2:end-addel) ];
      end
   else
      if maxfilt
         Y = [ g(:,1:N-1)  max(g(:,ig), h(:,ih))  h(:,end-N+2:end) ];
      else
         Y = [ g(:,1:N-1)  min(g(:,ig), h(:,ih))  h(:,end-N+2:end) ];
      end
   end

elseif strcmp(shape,'same')
   if fixsize
      if addel > (N-1)/2
         disp('hoi')
         ig = [ N : 1 : lf - addel + floor((N-1)/2) ];
         ih = [ 1 : 1 : lf-N+1 - addel + floor((N-1)/2)];
         if maxfilt
            Y = [ g(:,1+ceil((N-1)/2):N-1)  max(g(:,ig), h(:,ih)) ];
         else
            Y = [ g(:,1+ceil((N-1)/2):N-1)  min(g(:,ig), h(:,ih)) ];
         end
      else   
         ig = [ N : 1 : lf ];
         ih = [ 1 : 1 : lf-N+1 ];
         if maxfilt
            Y = [ g(:,1+ceil((N-1)/2):N-1)  max(g(:,ig), h(:,ih))  h(:,lf-N+2:lf-N+1+floor((N-1)/2)-addel) ];
         else
            Y = [ g(:,1+ceil((N-1)/2):N-1)  min(g(:,ig), h(:,ih))  h(:,lf-N+2:lf-N+1+floor((N-1)/2)-addel) ];
         end
      end            
   else % not fixsize (addel=0, lf=lx) 
      ig = [ N : 1 : lx ];
      ih = [ 1 : 1 : lx-N+1 ];
      if maxfilt
         Y = [  g(:,N-ceil((N-1)/2):N-1) max( g(:,ig), h(:,ih) )  h(:,lx-N+2:lx-N+1+floor((N-1)/2)) ];
      else
         Y = [  g(:,N-ceil((N-1)/2):N-1) min( g(:,ig), h(:,ih) )  h(:,lx-N+2:lx-N+1+floor((N-1)/2)) ];
      end
   end      

elseif strcmp(shape,'valid')
   ig = [ N : 1 : lx];
   ih = [ 1 : 1: lx-N+1];
   if maxfilt
      Y = [ max( g(:,ig), h(:,ih) ) ];
   else
      Y = [ min( g(:,ig), h(:,ih) ) ];
   end
end

if strcmp(direc,'col')
   Y = Y';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [direc, shape] = parse_inputs(varargin)
direc = 'lin';
shape = 'same';
flag = [0 0]; % [dir shape]

for i = 1 : nargin
   t = varargin{i};
   if strcmp(t,'col') & flag(1) == 0
      direc = 'col';
      flag(1) = 1;
   elseif strcmp(t,'full') & flag(2) == 0
      shape = 'full';
      flag(2) = 1;
   elseif strcmp(t,'same') & flag(2) == 0
      shape = 'same';
      flag(2) = 1;
   elseif strcmp(t,'valid') & flag(2) == 0
      shape = 'valid';
      flag(2) = 1;
   else
      error(['Too many / Unkown parameter : ' t ])
   end
end

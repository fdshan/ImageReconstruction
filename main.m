clc;
clear;
close all;

imgin = im2double(imread('./target.jpg'));

[imh, imw, nb] = size(imgin);
assert(nb==1);
% the image is grayscale

V = zeros(imh, imw);
V(1:imh*imw) = 1:imh*imw;
% V(y,x) = (y-1)*imw + x
% use V(y,x) to represent the variable index of pixel (x,y)
% Always keep in mind that in matlab indexing starts with 1, not 0

%TODO: initialize counter, A (sparse matrix) and b.
e = 1;

%i = zeros(1, (imh-1)*(imw-1)*5 + 4);
%j = zeros(1, (imh-1)*(imw-1)*5 + 4);
%v = zeros(1, (imh-1)*(imw-1)*5 + 4);
i = [];
j = [];
v = [];

%A = sparse(i,j,v);
%A=sparse(i,j,v,(imh-1)*(imw-1)+4,imh*imw);
%A = sparse([],[],[],(imh-1)*(imw-1)+4,imh*imw,(imh-1)*(imw-1)*5+4);

b = zeros((imh-1)*(imw-1)+4, 1);

%TODO: fill the elements in A and b, for each pixel in the image

for y = 1:imh
    for x = 1:imw
        %corner pixel, 0=0
        if (x == 1 && y == 1) || (x == 1 && y == 50) || (x == 50 && y == 1) || (x == 50 && y == 50)
            ii = [e];
            jj = [V(x,y)];
            vv = [0];
            b(e) = 0;
            
            %edge pixel, no left/right neighbour, up + down
        elseif x == 1 || x == 50
            ii = [e, e, e];
            jj = [V(y,x), V(y-1,x), V(y+1,x)];
            vv = [2, -1, -1];
            b(e) = 2 * imgin(y,x) - imgin(y+1,x) - imgin(y-1,x);
            
            
            %edge pixel, no up/down neighbour, left + right
        elseif y ==1 || y == 50
            ii = [e, e, e];
            jj = [V(y,x), V(y,x-1), V(y,x+1)];
            vv = [2, -1, -1];
            b(e) = 2 * imgin(y,x) - imgin(y,x-1) - imgin(y,x+1);
            
        else
            %4*v(x,y)-v(x+1,y)-v(x-1,y)-v(x,y+1)-v(x,y-1)
            ii = [e, e, e, e, e];
            jj = [V(y,x), V(y,x+1), V(y,x-1), V(y-1,x), V(y+1,x)];
            vv = [4, -1, -1, -1, -1];
            b(e) = 4 * imgin(y,x) - imgin(y+1,x) - imgin(y-1,x) - imgin(y,x-1) - imgin(y,x+1);
            
        end
        i = [i, ii];
        j = [j, jj];
        v = [v, vv];
        
        e = e + 1;
    end
end


%A=sparse(i,j,v,(imh-1)*(imw-1)+4,imh*imw);
%TODO: add extra constraints
%m?? n?
i1 = [e];
j1 = [V(1,1)];
v1 = [1];
%original
%b(e) = imgin(1,1); 
%globally brighter
b(e) = imgin(1,1) + 0.5;
%brighter on the left side
%b(e) = imgin(1,1) + 0.5;
%brigher on the bottom side
%b(e) = imgin(1,1);
%brighter on the right bottom side
%b(e) = imgin(1,1);


e = e + 1;
i2 = [e];
j2 = [V(1,50)];
v2 = [1];
%original
b(e) = imgin(1,50);
%globally brighter
%b(e) = imgin(1,50) + 0.5;
%brighter on the left side
%b(e) = imgin(1,50);
%brigher on the bottom side
%b(e) = imgin(1,50);
%brighter on the right bottom side
%b(e) = imgin(1,50);


e = e + 1;
i3 = [e];
j3 = [V(50,1)];
v3 = [1];
%original
b(e) = imgin(50,1);
%globally brighter
%b(e) = imgin(50,1) + 0.5;
%brighter on the left side
%b(e) = imgin(50,1) + 0.5;
%brigher on the bottom side
%b(e) = imgin(50,1) + 0.5;
%brighter on the right bottom side
%b(e) = imgin(50,1);

e = e + 1;
i4 = [e];
j4 = [V(50,50)];
v4 = [1];
%original
b(e) = imgin(50,50);
%globally brighter
%b(e) = imgin(50,50) + 0.5;
%brighter on the left side
%b(e) = imgin(50,50);
%brigher on the bottom side
%b(e) = imgin(50,50) + 0.5;
%brighter on the right bottom side
%b(e) = imgin(50,50) + 0.5;

i = [i, i1, i2, i3, i4];
j = [j, j1, j2, j3, j4];
v = [v, v1, v2, v3, v4];
A = sparse(i,j,v);
%fprintf('sizeA=%d',size(A));
%fprintf('sizeb=%d',size(b));
%TODO: solve the equation
solution = A\b;
error = sum(abs(A*solution-b));
disp(error)
imgout = reshape(solution,[imh,imw]);

imwrite(imgout,'output.png');
figure(), hold off, imshow(imgout);


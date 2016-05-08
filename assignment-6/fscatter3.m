%{
Copyright (c) 2010, Felix Morsdorf
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
%}

function [h] = fscatter3(X,Y,Z,C,cmap);
% [h] = fscatter3(X,Y,Z,C,cmap);
% Plots point cloud data in cmap color classes and 3 Dimensions,
% much faster and very little memory usage compared to scatter3 !
% X,Y,Z,C are vectors of the same length
% X,Y,Z,C might be put in as structure points.x,points.y,points.z,points.int  
% with C being used as index into colormap (can be any values though)
% cmap is optional colourmap to be used
% h are handles to the line objects

% Felix Morsdorf, Jan 2003 (last update Oct. 2010), Remote Sensing Laboratory Zuerich

  if nargin == 1
    if isfield(X,'int')
      C = X.int;
      Z = X.z;
    else
      C = X.z;
      Z = C;
    end
    Y = X.y;
    NX = X.x;
    clear X;
    X = NX;clear NX;
    numclass = 256; % Number of color classes
    cmap = myspecmap(256);
    siz = 5;
  elseif nargin == 4
    numclass = 256; % Number of color classes
    cmap = hsv(256);
    siz = 5;
  elseif nargin == 5
    numclass = max(size(cmap));
    siz = 5;
    if numclass == 1
      siz = cmap;
      cmap = hsv(256);
      numclass = 256;
    end  
  elseif nargin == 6
    numclass = max(size(cmap));
    if numclass == 1
      siz = cmap;
      cmap = hsv(256);
      numclass = 256;
    end  
  end  
  


% avoid too many calculations

mins = min(C);
maxs = max(C);
minz = min(Z);
maxz = max(Z);
minx = min(X);
maxx = max(X);
miny = min(Y);
maxy = max(Y);

% construct colormap :

col = cmap;

% determine index into colormap

ii = floor( (C - mins ) * (numclass-1) / (maxs - mins) );
ii = ii + 1;

colormap(cmap);
  
hold on
k = 0;o = k;
for j = 1:numclass
  jj = (ii(:)== j);
  if ~isempty(jj)
    k = k + 1;
    h = plot3(X(jj),Y(jj),Z(jj),'.','color',col(j,:),'markersize',siz);
    if ~isempty(h)
      o = o+1;
        hp(o) = h;
    end
  end  
end
caxis([min(C) max(C)])
axis equal;rotate3d on;view(3);
box on
hcb = colorbar('location','east');


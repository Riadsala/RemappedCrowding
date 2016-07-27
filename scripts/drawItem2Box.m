function im = drawItem2Box(im, letter, side, box, params)

if side == 1
    box = box + 1;
else
    box = 5-box;
end
x1 = params.midX - params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N+1;
x2 = params.midX + params.boxN/2 + side*params.delta - 2*params.N + (box-1)*params.N;
y1 = params.midY - params.boxN/2 +1;
y2 = params.midY + params.boxN/2;
im(y1:y2,x1:x2,:) = letter;

end

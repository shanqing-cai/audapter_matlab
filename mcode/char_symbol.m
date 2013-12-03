function str1 = char_symbol(str)
str1 = str;

for i1 = 1 : numel(str)
    str1(i1) = mod(lower(str(i1)) - 'a' + 1, 10) + '!';
end

return
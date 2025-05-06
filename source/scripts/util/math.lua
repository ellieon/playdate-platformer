function math.sign(x)
    if x<0 then
      return -1
    elseif x>0 then
      return 1
    else
      return 0
    end
 end

-- scale x between a and b, given x's min and max range
-- returns a number between a and b
function math.linearScaleBetween(_x,_a,_b,_xMin,_xMax)
  return (((_b-_a)*(_x-_xMin))/(_xMax-_xMin))+_a
end

function math.pointInRect(p, r) 
  return p.x >= r.x and 
    p.y >= r.y and 
    p.x <= r.x + r.width and
    p.y < r.y + r.height
end

function math.clamp(val, min, max)
  return math.min(math.max(val, min), max)
end

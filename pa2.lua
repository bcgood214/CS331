local pa2 = {}

function pa2.filterArray(p, t)
  local truths = {}
  for i = 1, #t do
    if p(t[i]) then
      table.insert(truths, t[i])
    end
  end
  return truths
end

function pa2.concatMax(str, num)
  if (#str > num) then
    return ""
  end
  local outstr = ""
  while (#outstr <= num - #str) do
    outstr = outstr .. str
  end
  return outstr
end

function pa2.collatz(k)
  local num = k
  local nextNum = num
  return function ()
    num = nextNum
    if (num == 1) then
      nextNum = 0
      return num
    end
    if (num > 1) then
      if (num % 2 == 0) then
        nextNum = num / 2
      else
        nextNum = 3 * num + 1
      end
      return num
    end
  end
end

function pa2.substrings (s)
  for i = 0, #s do
    -- local subs = {}
    if (i == 0) then
      coroutine.yield("")
    elseif (i == 1) then
      for j = 1, #s do
        local substr = string.sub(s, j, j)
        print(substr)
        -- table.insert(subs, substr)
        coroutine.yield(substr)
      end
    else
      for j = 1, #s - i + 1 do
        local substr = string.sub(s, j, j+i-1)
        print(substr)
        coroutine.yield(substr)
      end
    end
  end
end

return pa2
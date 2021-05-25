-- lexit.lua
-- Benjamin Good
-- CSCE A331
-- Assignment #3
-- 2/16/2021
-- My first lexer!

local lexit = {}

lexit.KEY = 1
lexit.ID = 2
lexit.NUMLIT = 3
lexit.STRLIT = 4
lexit.OP = 5
lexit.PUNCT = 6
lexit.MAL = 7

lexit.catnames = {
  "Keyword",
  "Identifier",
  "NumericLiteral",
  "StringLiteral",
  "Operator",
  "Punctuation",
  "Malformed"
  }

local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end

local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end

local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end

local function isPrintableASCII(c)
    if c:len() ~= 1 then
      return false
    elseif c >= " " and c <= "~" then
      return true
    else
      return false
    end
end

local function isIllegal(c)
  if c:len() ~= 1 then
    return false
  elseif isWhitespace(c) then
    return false
  elseif isPrintableASCII(c) then
    return false
  else
    return true
  end
end

local function keyCheck(str)
  if str == "and" or str == "char" or str == "cr"
  or str == "def" or str == "dq" or str == "elseif"
  or str == "else" or str == "false" or str == "for"
  or str == "if" or str == "not" or str == "or" or
  str == "readnum" or str == "return" or str == "true"
  or str == "write" then
    return true
  else
    return false
  end
end

function lexit.lex(program)
  local pos
  local state
  local ch
  local lexstr
  local category
  local handlers
  
  -- states
  local DONE = 0
  local START = 1
  local LETTER = 2
  local DIGIT = 3
  local EXP = 4
  local STRLIT = 5
  local OP = 6
  
  -- return current char
  local function currChar()
    return program:sub(pos, pos)
  end
  
  local function nextChar()
    return program:sub(pos+1, pos+1)
  end
  
  local function drop1()
    pos = pos + 1
  end
  
  -- add to lexeme
  local function add1()
    lexstr = lexstr .. currChar()
    drop1()
  end
  
    local function skipWhitespace()
        while true do
            -- Skip whitespace characters
            while isWhitespace(currChar()) do
                drop1()
            end

            -- Done if no comment
            if currChar() ~= "#" then
                break
            end

            -- Skip comment
            drop1() 
            while true do
                if currChar() == "\n" then
                    drop1() 
                    break
                elseif currChar() == "" then  -- End of input?
                   return
                end
                drop1()  -- Drop character inside comment
            end
        end
    end
  
  -- state handler functions
  
  local function handle_DONE()
    error("The DONE state should not be handled.\n")
  end
  
  local function handle_START()
    if isIllegal(ch) then
      add1()
      state = DONE
      category = lexit.MAL
    elseif isLetter(ch) or ch == "_" then
      add1()
      state = LETTER
    elseif ch == '"' then
      add1()
      state = STRLIT
    elseif isDigit(ch) then
      add1()
      state = DIGIT
    elseif ch == "+" or ch == "-" or ch == "*"
    or ch == "/" or ch == "%" or ch == "[" or ch == "]" then
      add1()
      state = DONE
      category = lexit.OP
    -- given the possible uses for an exclamation point in this language,
    -- I thought I would just handle it here.
    elseif ch == "!" and nextChar() ~= "=" then
      add1()
      state = DONE
      category = lexit.PUNCT
    elseif ch == "=" or ch == "!" or ch == "<" or ch == ">" then
      add1()
      state = OP
    else
      add1()
      state = DONE
      category = lexit.PUNCT
    end
  end
  
  local function handle_LETTER()
    if isLetter(ch) or ch == "_" or isDigit(ch) then
      add1()
    else
      state = DONE
      if keyCheck(lexstr) then
        category = lexit.KEY
      else
        category = lexit.ID
      end
    end
  end
  
  local function handle_DIGIT()
    if isDigit(ch) then
      add1()
    elseif (ch == "e" and nextChar() ~= "e")
    or (ch == "E" and nextChar() ~= "E") then
      if nextChar() == "+" and isDigit(program:sub(pos+2, pos+2)) then
        add1()
        add1()
        state = EXP
      elseif isDigit(nextChar()) then
        add1()
        state = EXP
      else
        state = DONE
        category = lexit.NUMLIT
      end
    else
      state = DONE
      category = lexit.NUMLIT
    end
  end
  
  -- and additional state for exponents seemed appropriate
  local function handle_EXP()
    if isDigit(ch) then
      add1()
    else
      state = DONE
      category = lexit.NUMLIT
    end
  end
  
  local function handle_OP()
    if ch == "=" then
      add1()
      state = DONE
      category = lexit.OP
    else
      state = DONE
      category = lexit.OP
    end
  end
  
  local function handle_STRLIT()
    if ch == "\n" then
      state = DONE
      category = lexit.MAL
    elseif ch == '"' then
      add1()
      state = DONE
      category = lexit.STRLIT
    elseif ch == "" then
      state = DONE
      category = lexit.MAL
    else
      add1()
    end
  end
  
  handlers = {
    [DONE] = handle_DONE,
    [START] = handle_START,
    [LETTER] = handle_LETTER,
    [DIGIT] = handle_DIGIT,
    [EXP] = handle_EXP,
    [STRLIT] = handle_STRLIT,
    [OP] = handle_OP,
  }
  
  local function getLexeme(dummy1, dummy2)
    if pos > program:len() then
      return nil, nil
    end
    lexstr = ""
    state = START
    while state ~= DONE do
      ch = currChar()
      handlers[state]()
    end
    
    skipWhitespace()
    return lexstr, category
  end
  
  pos = 1
  skipWhitespace()
  return getLexeme, nil, nil
  
end

return lexit
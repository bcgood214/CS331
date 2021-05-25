-- interpit.lua  INCOMPLETE
-- Glenn G. Chappell
-- 2021-03-31
--
-- For CS F331 / CSCE A331 Spring 2021
-- Interpret AST from parseit.parse
-- Solution to Assignment 6, Exercise 2


-- *** To run a Caracal program, use caracal.lua, which uses this file.

-- interpit.lua
-- Benjamin Good
-- 4/11/2021
-- An interpreter for caracal.


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local interpit = {}  -- Our module


-- *********************************************************************
-- Symbolic Constants for AST
-- *********************************************************************


local STMT_LIST    = 1
local WRITE_STMT   = 2
local RETURN_STMT  = 3
local ASSN_STMT    = 4
local FUNC_CALL    = 5
local FUNC_DEF     = 6
local IF_STMT      = 7
local FOR_LOOP     = 8
local STRLIT_OUT   = 9
local CR_OUT       = 10
local DQ_OUT       = 11
local CHAR_CALL    = 12
local BIN_OP       = 13
local UN_OP        = 14
local NUMLIT_VAL   = 15
local BOOLLIT_VAL  = 16
local READNUM_CALL = 17
local SIMPLE_VAR   = 18
local ARRAY_VAR    = 19


-- *********************************************************************
-- Utility Functions
-- *********************************************************************


-- numToInt
-- Given a number, return the number rounded toward zero.
local function numToInt(n)
    assert(type(n) == "number")

    if n >= 0 then
        return math.floor(n)
    else
        return math.ceil(n)
    end
end


-- strToNum
-- Given a string, attempt to interpret it as an integer. If this
-- succeeds, return the integer. Otherwise, return 0.
local function strToNum(s)
    assert(type(s) == "string")

    -- Try to do string -> number conversion; make protected call
    -- (pcall), so we can handle errors.
    local success, value = pcall(function() return tonumber(s) end)

    -- Return integer value, or 0 on error.
    if success then
        if value == nil then
            return 0
        else
            return numToInt(value)
        end
    else
        return 0
    end
end


-- numToStr
-- Given a number, return its string form.
local function numToStr(n)
    assert(type(n) == "number")

    return tostring(n)
end


-- boolToInt
-- Given a boolean, return 1 if it is true, 0 if it is false.
local function boolToInt(b)
    assert(type(b) == "boolean")

    if b then
        return 1
    else
        return 0
    end
end


-- astToStr
-- Given an AST, produce a string holding the AST in (roughly) Lua form,
-- with numbers replaced by names of symbolic constants used in parseit.
-- A table is assumed to represent an array.
-- See the Assignment 4 description for the AST Specification.
--
-- THIS FUNCTION IS INTENDED FOR USE IN DEBUGGING ONLY!
-- IT SHOULD NOT BE CALLED IN THE FINAL VERSION OF THE CODE.
function astToStr(x)
    local symbolNames = {
        "STMT_LIST", "WRITE_STMT", "RETURN_STMT", "ASSN_STMT",
        "FUNC_CALL", "FUNC_DEF", "IF_STMT", "FOR_LOOP", "STRLIT_OUT",
        "CR_OUT", "DQ_OUT", "CHAR_CALL", "BIN_OP", "UN_OP",
        "NUMLIT_VAL", "BOOLLIT_VAL", "READNUM_CALL", "SIMPLE_VAR",
        "ARRAY_VAR"
    }
    if type(x) == "number" then
        local name = symbolNames[x]
        if name == nil then
            return "<Unknown numerical constant: "..x..">"
        else
            return name
        end
    elseif type(x) == "string" then
        return '"'..x..'"'
    elseif type(x) == "boolean" then
        if x then
            return "true"
        else
            return "false"
        end
    elseif type(x) == "table" then
        local first = true
        local result = "{"
        for k = 1, #x do
            if not first then
                result = result .. ","
            end
            result = result .. astToStr(x[k])
            first = false
        end
        result = result .. "}"
        return result
    elseif type(x) == "nil" then
        return "nil"
    else
        return "<"..type(x)..">"
    end
end


-- *********************************************************************
-- Primary Function for Client Code
-- *********************************************************************


-- interp
-- Interpreter, given AST returned by parseit.parse.
-- Parameters:
--   ast     - AST constructed by parseit.parse
--   state   - Table holding Caracal variables & functions
--             - AST for function xyz is in state.f["xyz"]
--             - Value of simple variable xyz is in state.v["xyz"]
--             - Value of array item xyz[42] is in state.a["xyz"][42]
--   incall  - Function to call for line input
--             - incall() inputs line, returns string with no newline
--   outcall - Function to call for string output
--             - outcall(str) outputs str with no added newline
--             - To print a newline, do outcall("\n")
-- Return Value:
--   state, updated with changed variable values
function interpit.interp(ast, state, incall, outcall)
    -- Each local interpretation function is given the AST for the
    -- portion of the code it is interpreting. The function-wide
    -- versions of state, incall, and outcall may be used. The
    -- function-wide version of state may be modified as appropriate.


    -- Forward declare local functions
    local interp_stmt_list
    local interp_stmt
    local eval_expr


    -- interp_stmt_list
    -- Given the ast for a statement list, execute it.
    function interp_stmt_list(ast)
        for i = 2, #ast do
            interp_stmt(ast[i])
        end
    end


    -- interp_stmt
    -- Given the ast for a statement, execute it.
    function interp_stmt(ast)
        local var, varname
        --print("interp outer call: " .. astToStr(ast))
        if ast[1] == WRITE_STMT then
            for i = 2, #ast do
                if ast[i][1] == STRLIT_OUT then
                    local str = ast[i][2]
                    outcall(str:sub(2, str:len()-1))
                elseif ast[i][1] == CR_OUT then
                    outcall("\n")
                elseif ast[i][1] == DQ_OUT then
                    --print("*** UNIMPLEMENTED WRITE ARG")
                    outcall("\"")
                elseif ast[i][1] == CHAR_CALL then
                    -- print("*** UNIMPLEMENTED WRITE ARG")
                    --print(astToStr(ast[i]))
                    local n = eval_expr(ast[i][2])
                    if (n == nil or n <= 0 or n >= 255) then
                      n = 0
                    end
                    outcall(string.char(n))
                elseif ast[i][1] == SIMPLE_VAR then
                    var = eval_expr(ast[i])
                    outcall(numToStr(var))
                elseif ast[i][1] == ARRAY_VAR then
                    --print(astToStr(ast[i]))
                    var = eval_expr(ast[i])
                    --outcall(numToStr(var))
                    --print(var)
                    outcall(numToStr(var))
                elseif ast[i][1] == FUNC_CALL then
                    --print(astToStr(ast))
                    --print("Before outcall")
                    interp_stmt_list(state.f[ast[i][2]])
                    --print(type(state.v["return"]))
                    if state.v["return"] == nil then
                      outcall(numToStr(0))
                    else
                      outcall(numToStr(state.v["return"]))
                    end
                    --print("after call")
                    --outcall(state.v["return"])
                else  -- Expression
                    local val = eval_expr(ast[i])
                    outcall(numToStr(val))
                end
            end
        elseif ast[1] == FUNC_DEF then
            local funcname = ast[2]
            local funcbody = ast[3]
            state.f[funcname] = funcbody
        elseif ast[1] == FUNC_CALL then
            --print(astToStr(ast))
            local funcname = ast[2]
            local funcbody = state.f[ast[2]]
            if funcbody == nil then
                funcbody = { STMT_LIST }
            end
            interp_stmt_list(funcbody)
            --print(astToStr(ast))
            --state.v["return"] = interp_stmt_list(funcbody)
        elseif ast[1] == ASSN_STMT then
          --print(astToStr(ast))
          varname = ast[2][2]
          if ast[2][1] == SIMPLE_VAR then
            state.v[varname] = eval_expr(ast[3])
          elseif ast[2][1] == ARRAY_VAR then
            --print("Before strToNum in ARRAY_VAR")
            --print(astToStr(ast[2][3][2]))
            local index = eval_expr(ast[2][3])
            --print("Initial index: " .. astToStr(index))
            --if type(index) == "table" then
              --print(index)
              --index = eval_expr(index)
            --else
              --print(index)
              --index = strToNum(index)
            --end
            if (state.a[varname] == nil) then
              state.a[varname] = {}
            end
            state.a[varname][index] = eval_expr(ast[3])
            --if (state.a[varname] == nil) then
              --print("In the if block for assigning to index: " ..astToStr(ast[3]))
              --state.a[varname] = {[index] = eval_expr(ast[3])}
            --else
              --print("In the else block for assigning to index: " ..astToStr(ast[3]))
              --state.a[varname][index] = eval_expr(ast[3])
            --end
          end
        elseif ast[1] == RETURN_STMT then
          --print("Return statement: " .. astToStr(ast))
          temp = eval_expr(ast[2])
          state.v["return"] = temp
        elseif ast[1] == IF_STMT then
          --print(astToStr(ast))
          --print(astToStr(ast[4]))
          --if (eval_expr(ast[2]) ~= 0) then
            --interp_stmt_list(ast[3])
          --elseif (#ast > 3) then
            --interp_stmt_list(ast[4])
          --end
          
          for i = 2, #ast - 1, 2 do
            if (eval_expr(ast[i]) ~= 0) then
              interp_stmt_list(ast[i+1])
              break
            elseif (#ast > (i+1)) then
              interp_stmt_list(ast[i+2])
            end
          end
        
      elseif ast[1] == FOR_LOOP then
        --print(astToStr(ast))
        local cond
        
        
        --if ast[2] ~= nil then
        interp_stmt(ast[2])
        --end
        
        while (ast[3] == nil or eval_expr(ast[3]) ~= 0) do
          interp_stmt_list(ast[#ast])
          if ast[#ast-1] ~= nil then
            interp_stmt(ast[#ast-1])
          end
        end
        
  
          
        else
            --print("*** UNIMPLEMENTED STATEMENT")
            
            
        end
        
    end


    -- eval_expr
    -- Given the AST for an expression, evaluate it and return the
    -- value.
    function eval_expr(ast)
        local result, op, arg1, arg2, temp, varname
        --print("outer call: " .. astToStr(ast))

        if ast[1] == NUMLIT_VAL then
            --print("Value: " .. astToStr(ast))
            result = strToNum(ast[2])
            --print("result computed in NUMLIT")
        elseif ast[1] == SIMPLE_VAR then
            if (state.v[ast[2]] == nil) then
              result = 0
            else
              --print(astToStr(ast))
              temp = state.v[ast[2]]
              result = temp
            end
            -- result = numToInt(temp)
        elseif ast[1] == ARRAY_VAR then
            --temp = strToNum(state.a[ast[2]][ast[3]])
            --print(astToStr(ast))
            if (state.a[ast[2]] == nil) then
              temp = 0
            else
              temp = state.a[ast[2]][eval_expr(ast[3])]
            end
            if (temp == nil) then
              temp = 0
            end
            result = temp
            -- result = numToInt(temp)
        elseif ast[1] == BOOLLIT_VAL then
            val = false
            if ast[2] == "true" then
              val = true
            end
            result = boolToInt(val)
        elseif ast[1] == FUNC_CALL then
            --print(astToStr(ast))
            temp = interp_stmt(ast)
            result = state.v["return"]
        elseif ast[1] == READNUM_CALL then
            progrIn = incall()
            --result = temp
            result = numToInt(strToNum(progrIn))
        else
            --print("*** UNIMPLEMENTED EXPRESSION")
            --result = 42  -- DUMMY VALUE
            
            if ast[1][1] == UN_OP then
              if ast[1][2] == "+" then
                result = eval_expr(ast[2])
                --print(astToStr(ast))
              elseif ast[1][2] == "-" then
                result = -eval_expr(ast[2])
              elseif ast[1][2] == "not" then
                --print(astToStr(ast))
                if (eval_expr(ast[2]) == 0) then
                  result = 1
                else
                  result = 0
                end
              end
            end
            
            if ast[1][1] == BIN_OP then
              op = ast[1][2]
              --print(op)
              arg1 = eval_expr(ast[2])
              arg2 = eval_expr(ast[3])
              --print(astToStr(ast))
              --print(op)
              --print(arg1)
              --print(arg2)
              
              if op == "+" then
                result = numToInt(arg1 + arg2)
              elseif op == "-" then
                result = numToInt(arg1 - arg2)
              elseif op == "*" then
                --print(arg1 .. "*" .. arg2)
                result = numToInt(arg1 * arg2)
              elseif op == "/" then
                --print(arg1 .. "/" .. arg2)
                if (arg2 == 0) then
                  result = numToInt(0)
                else
                  result = numToInt(arg1 / arg2)
                end
              elseif op == "=" then
                varname = ast[2][2]
              elseif op == "%" then
                if (arg2 == 0) then
                  result = numToInt(0)
                else
                  result = numToInt(arg1 % arg2)
                end
              elseif op == "==" then
                if (arg1 == arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == "!=" then
                if (arg1 ~= arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == "<" then
                if (arg1 < arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == "<=" then
                if (arg1 <= arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == ">" then
                if (arg1 > arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == ">=" then
                if (arg1 >= arg2) then
                  result = 1
                else
                  result = 0
                end
              elseif op == "and" then
                --print(astToStr(ast))
                if ((arg1 ~= 0) and (arg2 ~= 0)) then
                  result = 1
                else
                  result = 0
                end
              elseif op == "or" then
                if ((arg1 ~= 0) or (arg2 ~= 0)) then
                  result = 1
                else
                  result = 0
                end
              end
              
            end
        end

        --print("result: " .. result)
        return result
    end

    -- Body of function interp
    interp_stmt_list(ast)
    return state
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return interpit


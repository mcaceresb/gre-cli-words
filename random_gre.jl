#!/usr/bin/env julia

grelines = open(ARGS[1]) do f readlines(f) end
k = rand(1:length(grelines))
println(strip(unescape_string(grelines[k]), '|'))

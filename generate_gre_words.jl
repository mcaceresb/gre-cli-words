#!/usr/bin/env julia

# ---------------------------------------------------------------------
# Program: generate_gre_words.jl
# Author:  Mauricio Caceres <caceres@nber.org>
# Created: Sun Aug 14 19:26:37 EDT 2016
# Updated: Sun Aug 14 21:17:42 EDT 2016
# Purpose: Generate GRE words
# Note:    Not very flexible ):

using DataFrames

maindir = pwd()
lexicon = "lib/lexicons/subjectivity_clues_hltemnlp05/subjclueslen1-HLTEMNLP05.tff"
effwn   = "lib/lexicons/effectwordnet/wncustom.ttf"
effgs   = "lib/lexicons/effectwordnet/gscustom.ttf"
vocab   = "lib/500words.quizlet.txt"
outfile = "custom_gre_word_list"

# Parse positive and negative effect
# ----------------------------------

parseff = Dict('+' => "positive", '-' => "negative", 'N' => "neutral")
wnlines = open(joinpath(maindir, effwn)) do f readlines(f) end
gslines = open(joinpath(maindir, effgs)) do f readlines(f) end
eflines = [wnlines; gslines]
efeffs  = [match(r"^\s*[+-N]", s).match[1] for s in eflines]
efeffs  = [parseff[k] * " effect" for k in efeffs]
efwords = [match(r"(Effect|Null)\s+(.*)", s).captures[2] for s in eflines]
efwords = [strip(s, '\r') for s in efwords]

alleff   = []
allwords = []
for (eff, word) in zip(efeffs, efwords)
    for w in split(word, ',')
        push!(alleff, eff)
        push!(allwords, w)
    end
end
edf = unique(DataFrame(word = allwords, polarity = alleff))

# Parse lexicon
# -------------

ldf     = readtable(joinpath(maindir, lexicon), separator = ' ', header = false)
lnames  = [match(r"^([a-z]+)\d?=", s).captures[1] for s in Array(ldf[1,:])]
names!(ldf, convert(Array{Symbol}, lnames[:]))
for col in names(ldf)
    ldf[col] = map(s -> replace(s, r"^([a-z]+)\d?=", s""), ldf[col])
end
ldf[:type]     = [replace(s, "subj", "") for s in ldf[:type]]
ldf[:polarity] = [replace(s, "both", "pos or neg") for s in ldf[:priorpolarity]]
#= ldf[:polarity] = [s * " polarity" for s in ldf[:polarity]] =#

# Parse GRE vocab
# ---------------

vlines  = open(joinpath(maindir, vocab)) do f readlines(f) end
vwords  = [match(r"^(\w+)\s", s).captures[1] for s in vlines]
vdefs   = [match(r"^\w+\s(\(.+)", s).captures[1] for s in vlines]
vdefsl  = maximum([length(split(d, ';')) for d in vdefs])
vdf     = DataFrame(word = vwords, defs = vdefs)
vdf[:parsed] = [replace(s, r"\(v\.\)", s"(verb)") for s in vdf[:defs]]
vdf[:parsed] = [replace(s, r"\(n\.\)", s"(noun)") for s in vdf[:parsed]]
vdf[:parsed] = [replace(s, r"\(adj\.\)", s"(adjective)") for s in vdf[:parsed]]
vdf[:parsed] = [replace(s, r"\(adv\.\)", s"(adverb)") for s in vdf[:parsed]]

function hardwrap(text  :: AbstractString,
                  jstr  :: AbstractString = "\n",
                  width :: Number = 71)

    width = round(Int, width)
    L     = length(text)
    nl    = round(Int, floor(L / width))
    l     = 0
    hw    = text[min(l * width + 1, L):min((l + 1) * width, L)]
    add   = text[min((l + 1) * width, L)] == ' '
    add   = add || text[min((l + 1) * width + 1, L)] == ' '
    add   = add || l >= nl
    hw    = [hw * (add? "": "-")]
    while l < nl && L > width
        l  += 1
        hwl = text[min(l * width + 1, L):min((l + 1) * width, L)]
        add = text[min((l + 1) * width, L)] == ' '
        add = add || text[min((l + 1) * width + 1, L)] == ' '
        add = add || l >= nl
        push!(hw, hwl * (add? "": "-"))
    end

    prematch = match(r"^\s*\([^\)]+\)", text)
    return join(hw, jstr * replace(prematch.match, r".", " ") * " ")
end

function cprint(line::DataFrames.DataFrame)
    word = line[1, :word]
    sw   = line[1, :type]
    subj = line[1, :polarity]
    add  = isna(sw)? "": sw * ", "

    if isna(subj)
        wordline = "\x1b[1m$(word)\x1b[0m "
        predefs  = replace(word, r".", " ") * " "
        defs     = replace("$(line[1, :parsed])", r";\s+\(", "\n\(")
        width    = 78 - length(word)
        wrapped  = [hardwrap(s, "\n$predefs", width) for s in split(defs, '\n')]
        wdefs    = join(wrapped, "\n$predefs")
    else
        wordline = "\x1b[1m$(word)\x1b[0m - \x1B[3m$(add * subj)\x1B[23m\n"
        predefs  = replace(word, r".", " ") * "   "
        defs     = replace("$(line[1, :parsed])", r";\s+\(", "\n\(")
        width    = 76 - length(word)
        wrapped  = [hardwrap(s, "\n$predefs", width) for s in split(defs, '\n')]
        wdefs    = predefs * join(wrapped, "\n$predefs")
    end

    return wordline * wdefs
end

pdf1 = vdf[[:word, :parsed]]
pdf2 = join(pdf1, ldf[[:word]], on = :word, kind = :anti)
pdf2 = join(pdf2, join(edf, ldf[[:word]], on = :word, kind = :left),
            on = :word, kind = :left)
pdf3 = join(pdf1, ldf[[:word, :type, :polarity]], on = :word, kind = :inner)
pdf  = unique(vcat(pdf2, pdf3))

x = DataFrame(x = [cprint(pdf[l, :]) for l in 1:size(pdf, 1)])
writetable(joinpath(maindir, outfile), x, header = false, quotemark = '|')

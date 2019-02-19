module anagrams
    export storeanagrams
    export readanagrams

    using JLD2, FileIO

    JLDBFILENAME = ""::String
    const JLDBKEY = "ANAGRAMS"

    function readwords()::Vector{String}
        wordslist = []
        for line in eachline("words.txt")
            push!(wordslist, line)
        end
        return wordslist
    end

    function get_anagrams(wordslist::Vector{String})::Dict{String, Vector{String}}
        wordsset = Dict{String, Vector{String}}()

        for word in wordslist
            key = join(sort([l for l in word]))
            wordsset[key] = push!(get!(wordsset, key, []), word)
        end
        return filter!(kv -> length(kv[2]) >= 2, wordsset)
    end

    function JLDSAVE(filename::String, dict::Dict{String, Vector{String}})
        global JLDBKEY
        save(filename, Dict(JLDBKEY=>dict))
    end

    function JLDLOAD(filename::String)
        global JLDBKEY
        return load(filename)[JLDBKEY]
    end

    function storeanagrams(name::String)
        global JLDBFILENAME
        basewords::Vector{String} = readwords()
        anagramsbook::Dict{String, Vector{String}} = get_anagrams(basewords)
        name = name*".jld2"
        try
            JLDSAVE(name, anagramsbook)
            JLDBFILENAME = name
        catch exc
            println("(!) Error: $exc")
        end
    end

    function readanagrams(word::String)::Vector{String}
        RET::Vector{String} = []
        word = join(sort!([w for w in word]))
        global JLDBFILENAME
        try
            if isfile(JLDBFILENAME)
                RET = JLDLOAD(JLDBFILENAME)[word]
            else
                error("(!) Error: DB File Doesn't Exist, create one by calling storeanagrams(filename)")
            end
        catch exc
            println("(!) Error: $exc")
        finally
            return RET
        end
    end
end
# coding: UTF-8

# Copyright (C) 2011-2012 by Masamitsu MURASE
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require "cgi"
require "open-uri"

module GchartFormula
  class GchartFormula
    SHORT_EXPR = {
      "Delta" => "De",
      "Diamond" => "Di",
      "Downarrow" => "Do",
      "Gamma" => "G",
      "Im" => "I",
      "Lambda" => "Lam",
      "Leftarrow" => "Le",
      "Leftrightarrow" => "Leftr",
      "Longleftarrow" => "Longl",
      "Longleftrightarrow" => "Longleftr",
      "Longrightarrow" => "Longr",
      "Phi" => "Ph",
      "Psi" => "Ps",
      "Re" => "R",
      "Rightarrow" => "Ri",
      "Sigma" => "Si",
      "Theta" => "T",
      "Uparrow" => "Upa",
      "Updownarrow" => "Upd",
      "Upsilon" => "U",
      "Xi" => "X",
      "aleph" => "ale",
      "alpha" => "al",
      "amalg" => "am",
      "approx" => "ap",
      "arccos" => "arc",
      "arcsin" => "arcs",
      "arctan" => "arct",
      "arg" => "ar",
      "ast" => "as",
      "asymp" => "asy",
      "bar" => "ba",
      "beta" => "be",
      "bigcap" => "bigca",
      "bigcirc" => "bigci",
      "bigcup" => "bigc",
      "bigoplus" => "bigop",
      "bigotimes" => "bigot",
      "bigsqcup" => "bigsq",
      "bigtriangledown" => "bigtriangled",
      "bigtriangleup" => "bigt",
      "biguplus" => "bigu",
      "bigvee" => "bigv",
      "bigwedge" => "bigw",
      "bot" => "bo",
      "boxdot" => "boxd",
      "bullet" => "bu",
      "cdot" => "cd",
      "chi" => "ch",
      "circ" => "ci",
      "clubsuit" => "cl",
      "cos" => "co",
      "csc" => "cs",
      "cup" => "cu",
      "curlyvee" => "cur",
      "curlywedge" => "curlyw",
      "dagger" => "da",
      "dashv" => "das",
      "ddagger" => "dda",
      "ddot" => "dd",
      "deg" => "de",
      "delta" => "del",
      "diamond" => "dia",
      "dim" => "di",
      "displaystyle" => "displayst",
      "dot" => "do",
      "downarrow" => "dow",
      "ell" => "el",
      "empty" => "em",
      "emptyset" => "em",
      "epsilon" => "ep",
      "equiv" => "eq",
      "eta" => "et",
      "exists" => "exi",
      "exp" => "e",
      "flat" => "fla",
      "forall" => "fo",
      "frac" => "fr",
      "frown" => "fro",
      "gamma" => "ga",
      "gcd" => "gc",
      "hat" => "h",
      "hom" => "ho",
      "imath" => "imat",
      "infty" => "inft",
      "iota" => "io",
      "jmath" => "j",
      "kappa" => "ka",
      "ker" => "k",
      "lambda" => "lam",
      "lbrace" => "lbr",
      "left" => "lef",
      "leftarrow" => "lefta",
      "leftharpoondown" => "leftharpoond",
      "leftharpoonup" => "lefth",
      "leftrightarrow" => "leftr",
      "lg" => "l",
      "lim" => "li",
      "liminf" => "limin",
      "limsup" => "lims",
      "log" => "lo",
      "longleftarrow" => "longl",
      "longleftrightarrow" => "longleftr",
      "longrightarrow" => "longr",
      "mapsto" => "map",
      "mathbb" => "mathb",
      "mathcal" => "mathc",
      "mathfrak" => "mathf",
      "mathit" => "mat",
      "mathrm" => "mathr",
      "max" => "ma",
      "mbox" => "mb",
      "min" => "mi",
      "mu" => "m",
      "nabla" => "na",
      "natural" => "nat",
      "nearrow" => "nea",
      "neq" => "ne",
      "ntriangleleft" => "nt",
      "ntriangleright" => "ntriangler",
      "nu" => "n",
      "nwarrow" => "nw",
      "odot" => "od",
      "oint" => "oi",
      "omega" => "om",
      "ominus" => "omi",
      "operatorname" => "ope",
      "oplus" => "op",
      "oslash" => "os",
      "otimes" => "ot",
      "overline" => "overl",
      "parallel" => "para",
      "partial" => "pa",
      "perp" => "pe",
      "phi" => "ph",
      "pi" => "p",
      "pmod" => "pmo",
      "prec" => "pr",
      "preceq" => "prece",
      "prime" => "pri",
      "propto" => "prop",
      "psi" => "ps",
      "qquad" => "qq",
      "quad" => "qu",
      "rbrace" => "rbr",
      "rho" => "rh",
      "rightarrow" => "ri",
      "rightharpoondown" => "rightharpoond",
      "rightharpoonup" => "righth",
      "searrow" => "sea",
      "sec" => "se",
      "setminus" => "set",
      "sharp" => "sh",
      "sigma" => "sig",
      "simeq" => "sime",
      "sin" => "si",
      "smile" => "smi",
      "spadesuit" => "sp",
      "sqcap" => "sqca",
      "sqcup" => "sqc",
      "sqrt" => "sq",
      "sqsubset" => "sqs",
      "sqsupset" => "sqsup",
      "stackrel" => "stac",
      "star" => "st",
      "subset" => "sub",
      "subseteq" => "subsete",
      "succ" => "suc",
      "succeq" => "succe",
      "sup" => "su",
      "supset" => "sups",
      "supseteq" => "supsete",
      "surd" => "sur",
      "swarrow" => "sw",
      "tan" => "ta",
      "theta" => "th",
      "tilde" => "til",
      "times" => "tim",
      "triangle" => "tri",
      "triangleleft" => "trianglel",
      "triangleright" => "triangler",
      "underline" => "un",
      "uparrow" => "upa",
      "updownarrow" => "upd",
      "uplus" => "up",
      "upsilon" => "ups",
      "varepsilon" => "vare",
      "varphi" => "varph",
      "varpi" => "va",
      "varrho" => "varr",
      "varsigma" => "vars",
      "vartheta" => "vart",
      "vdash" => "vd",
      "vec" => "v",
      "wedge" => "we",
      "widehat" => "wideh",
      "wp" => "w",
      "xi" => "x",
      "zeta" => "z"
    }

    DEFAULT_PARAMS = {
      :width => nil,
      :height => nil,
      :color => "000000",
      :background_color => "FFFFFF00",
      :opacity => nil,
      :abbr => true
    }

    def initialize(formula, params = {})
      check_params(params)

      @formula_raw = formula
      @params = DEFAULT_PARAMS.merge(params)
    end

    def to_url
      return "https://chart.googleapis.com/chart?" + query_params(@formula_raw, @params)  # "
    end

    def fetch
      open(to_url) do |io|
        return io.read
      end
    end

    def write(io)
      if (io.respond_to?(:write))
        # io is a kind of stream.
        io.write(fetch)
      else
        # io is a filename.
        File.open(io, "wb") do |file|
          file.write(fetch)
        end
      end
    end

    private
    def check_params(params)
      unknown_key = params.keys.find{ |k| !DEFAULT_PARAMS.key?(k) }
      if (unknown_key)
        raise ArgumentError, "Unknown Key: #{unknown_key}"
      end

      if (params[:width] && !params[:height])
        raise ArgumentError, "Height is not valid."
      end

      return true
    end

    def abbreviate(formula)
      # 1. remove multiple spaces
      formula = formula.gsub(Regexp.new("\\s+"), " ")

      # 2. use short expression
      formula = formula.gsub(Regexp.new(Regexp.escape('\\') + "([a-zA-Z]+)")) do |matched|
        abbr = SHORT_EXPR[$1]
        next (abbr ? ('\\' + abbr) : matched)
      end

      return formula
    end

    def query_params(formula, params)
      check_params(params)
      api_hash = {
        :cht => "tx",
        :chl => (params[:abbr] ? abbreviate(formula) : formula),
        :chco => params[:color],
        :chf => "bg,s,#{params[:background_color]}"
      }

      # size
      if (params[:height])
        api_hash[:chs] = (params[:width] ? "#{params[:width]}x#{params[:height]}" : "#{params[:height]}")
      end

      # opacity
      if (params[:opacity])
        opacity = (params[:opacity].kind_of?(Float) ? (params[:opacity] * 255).to_i : params[:opacity])
        api_hash[:chf] << '|a,s,' << "000000#{opacity.to_s(16).rjust(2, '0')}"
      end

      return api_hash.collect{ |k, v| "#{k}=#{CGI.escape(v)}" }.join("&")
    end
  end

  def self.formula(*args)
    return GchartFormula.new(*args)
  end
end


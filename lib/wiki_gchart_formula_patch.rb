# coding: UTF-8

# Copyright (C) 2011 by Masamitsu MURASE
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

require 'gchart_formula/gchart_formula'

module WikiGchartFormulaPatch
  FORMULA_PATTERN = /\{\{latex\((.*?)\)\}\}/

  def self.included(base)
    base.send(:include, InstanceMethod)

    base.class_eval do
      # 
      if (!const_defined?(:RULES))
        raise "Constant 'RULES' is not defined."
      end

      rules_base = const_get(:RULES)
      remove_const(:RULES)
      const_set(:RULES, rules_base + [ :inline_wiki_gchart_formula ])
    end
  end

  module InstanceMethod
    def inline_wiki_gchart_formula(text)
      text.gsub!(FORMULA_PATTERN) do
        match_data = $~

        formula_url = GoogleChart.formula(match_data[1]).to_url
        tag("img", :src => formula_url, :alt => match_data[1], :class => "gchart_latex")
      end
    end
  end
end

Redmine::WikiFormatting::Textile::Formatter.send(:include, WikiGchartFormulaPatch)


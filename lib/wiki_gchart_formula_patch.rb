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

require_dependency 'application_helper'
require 'gchart_formula/gchart_formula'

module WikiGchartFormulaPatch
  FORMULA_PATTERN = /(!)?(\{\{latex\((.*?)\)\}\})/
  OPTIONAL_ARG_PATTERN = /,\s*\(([^\(\)]+)\)$/
  bg_option = {
    :name => :background_color,
    :converter => :to_s.to_proc
  }
  OPTIONAL_ARGS = {
    "opacity" => {
      :name => :opacity,
      :converter => :to_i.to_proc
    },
    "background_color" => bg_option,
    "bg_color" => bg_option,
    "bg" => bg_option
  }

  IMAGE_TAG_CLASS_NAME = "gchart_formula"

  def self.included(base)
    base.send(:include, InstanceMethod)

    base.class_eval do
      if (method_defined?(:parse_macros))
        # for Redmine 1.3.0
        alias_method_chain :parse_macros, :gchart_formula
      elsif (method_defined?(:parse_inline_attachments))
        # for Redmine 1.2.X
        alias_method_chain :parse_inline_attachments, :gchart_formula
      end

      alias_method :inline_wiki_gchart_formula, :def_inline_wiki_gchart_formula
      alias_method :parse_wiki_gchart_pattern, :def_parse_wiki_gchart_pattern
    end
  end

  module InstanceMethod
    def parse_macros_with_gchart_formula(text, project, obj, attr, only_path, options)
      inline_wiki_gchart_formula(text)
      parse_macros_without_gchart_formula(text, project, obj, attr, only_path, options)
    end

    def parse_inline_attachments_with_gchart_formula(text, project, obj, attr, only_path, options)
      inline_wiki_gchart_formula(text)
      parse_inline_attachments_without_gchart_formula(text, project, obj, attr, only_path, options)
    end

    def def_inline_wiki_gchart_formula(text)
      text.gsub!(FORMULA_PATTERN) do
        match_data = $~

        # '!' is an escape character.
        next match_data[2] if (match_data[1])

        data = parse_wiki_gchart_pattern(match_data[3])
        formula_url = GoogleChart.formula(data[:formula], data[:option] || {}).to_url
        next tag("img", :src => formula_url, :alt => data[:formula],
                 :title => data[:formula], :class => IMAGE_TAG_CLASS_NAME)
      end
    end

    def def_parse_wiki_gchart_pattern(text)
      match_data = text.match(OPTIONAL_ARG_PATTERN)
      if (match_data)
        optional_args = match_data[1].split(",").map{ |i| i.split("=", 2).map(&:strip) }
        if (optional_args.map(&:first).all?{ |i| OPTIONAL_ARGS.key?(i) })
          option = {}
          optional_args.each do |arg|
            info = OPTIONAL_ARGS[arg[0]]
            option[info[:name]] = info[:converter].call(arg[1])
          end

          return {
            :formula => match_data.pre_match,
            :option => option
          }
        end
      end

      return { :formula => text }
    end
  end
end

ApplicationHelper.send(:include, WikiGchartFormulaPatch)


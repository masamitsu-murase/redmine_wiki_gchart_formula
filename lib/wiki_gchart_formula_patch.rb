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

require_dependency 'application_helper'
require 'wiki_gchart_formula'
require 'wiki_gchart_formula_macro'

module WikiGchartFormula
  module WikiGchartFormulaPatch
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
      end
    end

    module InstanceMethod
      def parse_macros_with_gchart_formula(text, project, obj, attr, only_path, options)
        WikiGchartFormulaMacro.inline_wiki_gchart_formula(text)
        parse_macros_without_gchart_formula(text, project, obj, attr, only_path, options)
      end

      def parse_inline_attachments_with_gchart_formula(text, project, obj, attr, only_path, options)
        WikiGchartFormulaMacro.inline_wiki_gchart_formula(text)
        parse_inline_attachments_without_gchart_formula(text, project, obj, attr, only_path, options)
      end
    end
  end
end

ApplicationHelper.send(:include, WikiGchartFormula::WikiGchartFormulaPatch)


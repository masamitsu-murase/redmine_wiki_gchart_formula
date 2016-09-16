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

plugin_name = :redmine_wiki_gchart_formula

Rails.configuration.to_prepare do
  require_dependency 'google_chart/formula'
  require_patch plugin_name, %w'application_helper'
end

Redmine::Plugin.register plugin_name do
  name 'Redmine Wiki Gchart LaTeX-style Formula plugin'
  author 'Masamitsu MURASE'
  description 'This plugin enables Redmine to render LaTeX-style formula images in Wiki.'
  version '0.0.6'
  url 'https://github.com/masamitsu-murase/redmine_wiki_gchart_formula/'
  author_url 'http://masamitsu-murase.blogspot.com/'
  requires_redmine version_or_higher: '3.3.0'
end


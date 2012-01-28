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

require_dependency "redmine/export/pdf"
require 'wiki_gchart_formula'
require "wiki_gchart_formula_macro"

if (WikiGchartFormula.support_pdf?)

module WikiGchartFormula
  class WikiGchartFormulaTempPngManager
    class << self
      def create_temp_png_files(data, &block)
        manager = self.new(data)
        begin
          block.call(manager)
        ensure
          manager.release
        end
      end
    end

    def initialize(data)
      @temp_png_files = {}
      data.each do |item|
        key = item[:key]
        png_data = item[:png].unpack("m")[0]

        Tempfile.open([ "gchart_", ".png" ]) do |file|
          file.binmode if (file.respond_to?(:binmode))
          file.write(png_data)
          @temp_png_files[key] = file
        end
      end
    end

    def exist?(url)
      key = chl(CGI.unescapeHTML(url))
      return @temp_png_files.key?(key)
    end

    def temp_file(url)
      key = chl(CGI.unescapeHTML(url))
      return @temp_png_files[key]
    end

    def release
      @temp_png_files.each{ |key, value| value.close! }
      @temp_png_files.clear
    end

    private
    def chl(url)
      info = WikiGchartFormula::WikiGchartFormulaMacro.parse_wiki_gchart_url(url)
      return info ? info[:params][:chl] : nil
    end
  end
end

#
# Refer to lib/redmine/export/pdf.rb
#
# THIS IS a typical BAD DESIGN!
# I think that we should not have dead copies.
# Tell me a better way...
module Redmine
  module Export
    module PDF

      #
      # GChartPDF supports PNG temporary images.
      class GChartPDF < ITCPDF
        def initialize(lang, gchart_png_manager)
          @gchart_png_manager = gchart_png_manager
          super(lang)
        end

        def RDMwriteHTMLCell(w, h, x, y, txt='', attachments=[], border=0, ln=1, fill=0)
          @attachments = attachments
          text = Redmine::WikiFormatting.to_html(Setting.text_formatting, txt)
          WikiGchartFormula::WikiGchartFormulaMacro.inline_wiki_gchart_formula(text)
          writeHTMLCell(w, h, x, y, fix_text_encoding(text), border, ln, fill)
        end

        def getImageFilename(attrname)
          # attrname: general_pdf_encoding string file/uri name
          atta = RDMPdfEncoding.attach(@attachments, attrname, l(:general_pdf_encoding))
          if atta
            return atta.diskfile
          elsif (@gchart_png_manager.exist?(attrname))
            return @gchart_png_manager.temp_file(attrname).path
          else
            return nil
          end
        end
      end

      #
      # 'issue_to_gchart_pdf' is almost same as 'issue_to_pdf'.
      # The only difference is using GChartPDF instead of ITCPDF.
      # Returns a PDF string of a single issue
      def issue_to_gchart_pdf(issue, mgr)
        pdf = GChartPDF.new(current_language, mgr)
        pdf.SetTitle("#{issue.project} - ##{issue.tracker} #{issue.id}")
        pdf.alias_nb_pages
        pdf.footer_date = format_date(Date.today)
        pdf.AddPage
        pdf.SetFontStyle('B',11)
        buf = "#{issue.project} - #{issue.tracker} # #{issue.id}"
        pdf.RDMMultiCell(190, 5, buf)
        pdf.Ln
        pdf.SetFontStyle('',8)
        base_x = pdf.GetX
        i = 1
        issue.ancestors.each do |ancestor|
          pdf.SetX(base_x + i)
          buf = "#{ancestor.tracker} # #{ancestor.id} (#{ancestor.status.to_s}): #{ancestor.subject}"
          pdf.RDMMultiCell(190 - i, 5, buf)
          i += 1 if i < 35
        end
        pdf.Ln

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_status) + ":","LT")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, issue.status.to_s,"RT")
        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_priority) + ":","LT")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, issue.priority.to_s,"RT")
        pdf.Ln

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_author) + ":","L")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, issue.author.to_s,"R")
        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_category) + ":","L")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, issue.category.to_s,"R")
        pdf.Ln

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_created_on) + ":","L")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, format_date(issue.created_on),"R")
        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_assigned_to) + ":","L")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, issue.assigned_to.to_s,"R")
        pdf.Ln

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_updated_on) + ":","LB")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, format_date(issue.updated_on),"RB")
        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_due_date) + ":","LB")
        pdf.SetFontStyle('',9)
        pdf.RDMCell(60,5, format_date(issue.due_date),"RB")
        pdf.Ln

        for custom_value in issue.custom_field_values
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(35,5, custom_value.custom_field.name + ":","L")
          pdf.SetFontStyle('',9)
          pdf.RDMMultiCell(155,5, (show_value custom_value),"R")
        end

        y0 = pdf.GetY

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35,5, l(:field_subject) + ":","LT")
        pdf.SetFontStyle('',9)
        pdf.RDMMultiCell(155,5, issue.subject,"RT")
        pdf.Line(pdf.GetX, y0, pdf.GetX, pdf.GetY)

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(35+155, 5, l(:field_description), "LRT", 1)
        pdf.SetFontStyle('',9)

        # Set resize image scale
        pdf.SetImageScale(1.6)
        pdf.RDMwriteHTMLCell(35+155, 5, 0, 0,
              issue.description.to_s, issue.attachments, "LRB")

        unless issue.leaf?
          # for CJK
          truncate_length = ( l(:general_pdf_encoding).upcase == "UTF-8" ? 90 : 65 )
  
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(35+155,5, l(:label_subtask_plural) + ":", "LTR")
          pdf.Ln
          issue_list(issue.descendants.sort_by(&:lft)) do |child, level|
            buf = truncate("#{child.tracker} # #{child.id}: #{child.subject}",
                           :length => truncate_length)
            level = 10 if level >= 10
            pdf.SetFontStyle('',8)
            pdf.RDMCell(35+135,5, (level >=1 ? "  " * level : "") + buf, "L")
            pdf.SetFontStyle('B',8)
            pdf.RDMCell(20,5, child.status.to_s, "R")
            pdf.Ln
          end
        end

        relations = issue.relations.select { |r| r.other_issue(issue).visible? }
        unless relations.empty?
          # for CJK
          truncate_length = ( l(:general_pdf_encoding).upcase == "UTF-8" ? 80 : 60 )
  
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(35+155,5, l(:label_related_issues) + ":", "LTR")
          pdf.Ln
          relations.each do |relation|
            buf = ""
            buf += "#{l(relation.label_for(issue))} "
            if relation.delay && relation.delay != 0
              buf += "(#{l('datetime.distance_in_words.x_days', :count => relation.delay)}) "
            end
            if Setting.cross_project_issue_relations?
              buf += "#{relation.other_issue(issue).project} - "
            end
            buf += "#{relation.other_issue(issue).tracker}" +
                   " # #{relation.other_issue(issue).id}: #{relation.other_issue(issue).subject}"
            buf = truncate(buf, :length => truncate_length)
            pdf.SetFontStyle('', 8)
            pdf.RDMCell(35+155-60, 5, buf, "L")
            pdf.SetFontStyle('B',8)
            pdf.RDMCell(20,5, relation.other_issue(issue).status.to_s, "")
            pdf.RDMCell(20,5, format_date(relation.other_issue(issue).start_date), "")
            pdf.RDMCell(20,5, format_date(relation.other_issue(issue).due_date), "R")
            pdf.Ln
          end
        end
        pdf.RDMCell(190,5, "", "T")
        pdf.Ln

        if issue.changesets.any? &&
             User.current.allowed_to?(:view_changesets, issue.project)
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(190,5, l(:label_associated_revisions), "B")
          pdf.Ln
          for changeset in issue.changesets
            pdf.SetFontStyle('B',8)
            csstr  = "#{l(:label_revision)} #{changeset.format_identifier} - "
            csstr += format_time(changeset.committed_on) + " - " + changeset.author.to_s
            pdf.RDMCell(190, 5, csstr)
            pdf.Ln
            unless changeset.comments.blank?
              pdf.SetFontStyle('',8)
              pdf.RDMwriteHTMLCell(190,5,0,0,
                    changeset.comments.to_s, issue.attachments, "")
            end
            pdf.Ln
          end
        end

        pdf.SetFontStyle('B',9)
        pdf.RDMCell(190,5, l(:label_history), "B")
        pdf.Ln
        indice = 0
        for journal in issue.journals.find(
                          :all, :include => [:user, :details],
                          :order => "#{Journal.table_name}.created_on ASC")
          indice = indice + 1
          pdf.SetFontStyle('B',8)
          pdf.RDMCell(190,5,
             "#" + indice.to_s +
             " - " + format_time(journal.created_on) +
             " - " + journal.user.name)
          pdf.Ln
          pdf.SetFontStyle('I',8)
          for detail in journal.details
            pdf.RDMMultiCell(190,5, "- " + show_detail(detail, true))
          end
          if journal.notes?
            pdf.Ln unless journal.details.empty?
            pdf.SetFontStyle('',8)
            pdf.RDMwriteHTMLCell(190,5,0,0,
                  journal.notes.to_s, issue.attachments, "")
          end
          pdf.Ln
        end

        if issue.attachments.any?
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(190,5, l(:label_attachment_plural), "B")
          pdf.Ln
          for attachment in issue.attachments
            pdf.SetFontStyle('',8)
            pdf.RDMCell(80,5, attachment.filename)
            pdf.RDMCell(20,5, number_to_human_size(attachment.filesize),0,0,"R")
            pdf.RDMCell(25,5, format_date(attachment.created_on),0,0,"R")
            pdf.RDMCell(65,5, attachment.author.name,0,0,"R")
            pdf.Ln
          end
        end
        pdf.Output
      end

      #
      # 'wiki_to_gchart_pdf' is almost same as 'wiki_to_pdf'.
      # The only difference is using GChartPDF instead of ITCPDF.
      #
      # Returns a PDF string of a single wiki page
      def wiki_to_gchart_pdf(page, project, mgr)
        pdf = GChartPDF.new(current_language, mgr)
        pdf.SetTitle("#{project} - #{page.title}")
        pdf.alias_nb_pages
        pdf.footer_date = format_date(Date.today)
        pdf.AddPage
        pdf.SetFontStyle('B',11)
        pdf.RDMMultiCell(190,5,
             "#{project} - #{page.title} - # #{page.content.version}")
        pdf.Ln
        # Set resize image scale
        pdf.SetImageScale(1.6)
        pdf.SetFontStyle('',9)
        pdf.RDMwriteHTMLCell(190,5,0,0,
              page.content.text.to_s, page.attachments, "TLRB")
        if page.attachments.any?
          pdf.Ln
          pdf.SetFontStyle('B',9)
          pdf.RDMCell(190,5, l(:label_attachment_plural), "B")
          pdf.Ln
          for attachment in page.attachments
            pdf.SetFontStyle('',8)
            pdf.RDMCell(80,5, attachment.filename)
            pdf.RDMCell(20,5, number_to_human_size(attachment.filesize),0,0,"R")
            pdf.RDMCell(25,5, format_date(attachment.created_on),0,0,"R")
            pdf.RDMCell(65,5, attachment.author.name,0,0,"R")
            pdf.Ln
          end
        end
        pdf.Output
      end
    end
  end
end

module WikiGchartFormula
  class IssueListener < Redmine::Hook::ViewListener
    def view_layouts_base_html_head(context)
      if (context[:controller].controller_name == "issues" && context[:controller].action_name == "show")
        config = <<"EOS"
var gWikiGchartFormula = {
  img_class: '#{escape_javascript(WikiGchartFormulaMacro::IMAGE_TAG_CLASS_NAME)}'
};
EOS
        return javascript_tag(config) +
          javascript_include_tag('wiki_gchart_formula.js', :plugin => "redmine_wiki_gchart_formula")
      end
      return ""
    end
  end
end

end

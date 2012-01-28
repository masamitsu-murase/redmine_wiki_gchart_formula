require("wiki_gchart_formula_pdf_patch")

class WikiGchartFormulaController < ApplicationController
  include Redmine::Export::PDF

  def show
    if (WikiGchartFormula.support_pdf?)
      issue = Issue.find(params[:id])

      gchart = params[:gchart]
      WikiGchartFormula::WikiGchartFormulaTempPngManager.create_temp_png_files(gchart) do |mgr|
        respond_to do |format|
          format.pdf do
            send_data(issue_to_gchart_pdf(issue, mgr),
                      :type => 'application/pdf', :filename => "test.pdf")
          end
        end
      end
    end
  end
end

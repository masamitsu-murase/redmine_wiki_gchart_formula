module RedmineWikiGchartFormula::ApplicationHelperPatch
  extend ActiveSupport::Concern

  included do
    alias_method_chain :textilizable, :gchart_formula

    FORMULA_PATTERN = /(!)?(\{\{latex\((.*?)\)\}\})/

    def inject_gchart_formula(text)
      text.gsub(FORMULA_PATTERN) do
        match_data = $~

        # '!' is an escape character.
        if match_data[1]
          next match_data[2]
        else
          data = catch_gchart_formula(match_data[3])
          formula_url = GoogleChart.formula(data[:formula], data[:option] || {}).to_url

          next "!(gchart_formula)#{formula_url}(#{data[:formula]})!"
        end
      end
    end

    OPTIONAL_ARG_PATTERN = /,\s*\(([^\(\)]+)\)\z/
    bg_option = {
        name: :background_color,
        converter: :to_s.to_proc
    }
    OPTIONAL_ARGS = {
        'opacity' => {
            name: :opacity,
            converter: :to_i.to_proc
        },
        'background_color' => bg_option,
        'bg_color' => bg_option,
        'bg' => bg_option
    }

    def catch_gchart_formula(text)
      match_data = text.match(OPTIONAL_ARG_PATTERN)

      if match_data
        optional_args = match_data[1].split(',').map{ |i| i.split('=', 2).map(&:strip) }

        if optional_args.map(&:first).all?{ |i| OPTIONAL_ARGS.key?(i) }
          option = {}

          optional_args.each do |arg|
            info = OPTIONAL_ARGS[arg[0]]
            option[info[:name]] = info[:converter].call(arg[1])
          end

          {formula: match_data.pre_match, option: option}
        end
      end

      {formula: text}
    end
  end

  # Formats text according to system settings.
  # 2 ways to call this method:
  # * with a String: textilizable(text, options)
  # * with an object and one of its attribute: textilizable(issue, :description, options)
  def textilizable_with_gchart_formula(*args)
    options = args.last.is_a?(Hash) ? args.pop : {}
    case args.size
      when 1
        obj = options[:object]
        text = args.shift
      when 2
        obj = args.shift
        attr = args.shift
        text = obj.send(attr).to_s
      else
        raise ArgumentError, 'invalid arguments to textilizable'
    end

    return '' if text.blank?
    text_with_gchartformula = inject_gchart_formula(text)

    textilizable_without_gchart_formula(text_with_gchartformula, options.merge(object: obj))
  end
end
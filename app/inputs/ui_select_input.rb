class UiSelectInput < SimpleForm::Inputs::Base
  def input
    display = options.delete(:display)
    template.content_tag('ui-select', select_options) do
      template.concat select_match display
      template.concat select_choices display
    end
  end

  private

  def select_match(display)
    prefix = input_html_options.has_key?(:multiple) ? '$item' : '$select.selected'
    text = display ? "{{#{prefix}.#{display}}}" : "{{#{prefix}}}"
    template.content_tag('ui-select-match', text, select_match_options)
  end

  def select_choices(display)
    template.content_tag('ui-select-choices', select_choices_options) do
      template.content_tag('ui-select-choice', '', select_choice_options(display))
    end
  end

  def select_options
    select_options = input_html_options || {}
    theme = options.delete(:theme) || 'bootstrap'
    {'ng-model' => options.delete(:model), theme: theme}.merge select_options
  end

  def select_match_options
    match_options = options[:ui_select_match] || {}
    {placeholder: options.delete(:placeholder)}.merge match_options
  end

  def select_choices_options
    choices_options = options[:ui_select_choices] || {}
    collection = options.delete(:collection)
    filter = options.delete(:filter) || '$select.search'
    {'group-by'=> "'#{options[:group_by]}'", repeat: "item in #{collection} | filter: #{filter}"}.merge choices_options
  end

  def select_choice_options(display)
    choice_options = options[:ui_select_choice] || {}
    highlight = options.delete(:highlight) || '$select.search'
    text = display ? "item.#{display}" : 'item'
    {:'ng-bind-html' => "#{text} | highlight: #{highlight}"}.merge choice_options
  end

end
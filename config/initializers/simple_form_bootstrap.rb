# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.error_notification_class = 'alert alert-danger'
  config.button_class = 'btn btn-default'
  config.boolean_label_class = nil

  config.wrappers :vertical_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'control-label'

    b.use :input, class: 'form-control'
    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :vertical_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :readonly
    b.use :label, class: 'control-label'

    b.use :input
    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :vertical_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: 'div', class: 'checkbox' do |ba|
      ba.use :label_input
    end

    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :vertical_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: 'control-label'
    b.use :input
    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :horizontal_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input, class: 'form-control'
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :readonly
    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_boolean, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: 'div', class: 'col-sm-offset-3 col-sm-9' do |wr|
      wr.wrapper tag: 'div', class: 'checkbox' do |ba|
        ba.use :label_input, class: 'col-sm-9'
      end

      wr.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      wr.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_radio_and_checkboxes, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly

    b.use :label, class: 'col-sm-3 control-label'

    b.wrapper tag: 'div', class: 'col-sm-9' do |ba|
      ba.use :input
      ba.use :error, wrap_with: {tag: 'span', class: 'help-block'}
      ba.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_col_6_radio_and_checkboxes, tag: 'div', class: 'form-group col-xs-12 col-sm-6 no-padding-right no-margin-right', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-xs-12 col-sm-3 control-label no-padding-right'
    b.wrapper tag: 'div', class: 'col-xs-12 col-sm-9 no-padding-right no-margin-right' do |ba|
      ba.use :input, class: 'checkbox'
      b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    end
  end

  config.wrappers :inline_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'sr-only'

    b.use :input, class: 'form-control'
    b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    b.use :hint, wrap_with: {tag: 'p', class: 'help-block'}
  end

  config.wrappers :horizontal_col_6_text_input, tag: 'div', class: 'form-group col-xs-12 col-sm-6 no-padding-right no-margin-right', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'col-xs-12 col-sm-3 control-label no-padding-right'
    b.wrapper tag: 'div', class: 'col-xs-12 col-sm-9 no-padding-right no-margin-right' do |ba|
      ba.use :input, class: 'form-control col-xs-12'
      b.use :error, wrap_with: {tag: 'span', class: 'help-block'}
    end
  end

  config.wrappers :horizontal_col_6_select_input, tag: 'div', class: 'form-group col-xs-12 col-sm-6 no-padding-right no-margin-right', error_class: 'has-error' do |b|
    b.use :html5
    b.use :label, class: 'col-xs-12 col-sm-3 control-label no-padding-right'
    b.wrapper tag: 'div', class: 'col-xs-12 col-sm-9 no-padding-right no-margin-right' do |ba|
      ba.use :input
    end
  end

  config.wrappers :horizontal_col_12_select_input, tag: 'div', class: 'form-group col-xs-12 col-sm-12 no-padding-right no-margin-right', error_class: 'has-error' do |b|
    b.use :html5
    b.use :label, class: 'col-xs-12 col-sm-4 control-label no-padding-right'
    b.wrapper tag: 'div', class: 'col-xs-12 col-sm-8 no-padding-right no-margin-right' do |ba|
      ba.use :input
    end
  end

  config.wrappers :vertical_col_4_select_input, tag: 'div', class: 'form-group col-xs-12 col-sm-4', error_class: 'has-error' do |b|
    b.use :html5
    b.use :label, class: 'no-padding-right'
    b.wrapper tag: 'div', class: '' do |ba|
      ba.use :input
    end
  end

  config.wrappers :vertical_col_4_date_picker, tag: 'div', class: 'form-group col-xs-12 col-sm-4', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: 'no-padding-right'
    b.wrapper tag: 'div', class: 'input-group' do |ba|
      ba.use :input, class: 'form-control'
      ba.wrapper tag: 'span', class: 'input-group-btn' do |bb|
        bb.wrapper :button_wrapper, tag: 'button', class: 'btn btn-white', html: {type: 'button'} do |bc|
          bc.wrapper tag: 'i', class: 'fa fa-calendar' do |bd|
          end
        end
      end
    end
  end

  # Wrappers for forms and inputs using the Bootstrap toolkit.
  # Check the Bootstrap docs (http://getbootstrap.com)
  # to learn about the different styles for forms and inputs,
  # buttons and other elements.
  config.default_wrapper = :vertical_form
  config.wrapper_mappings = {
      check_boxes: :vertical_radio_and_checkboxes,
      radio_buttons: :vertical_radio_and_checkboxes,
      file: :vertical_file_input,
      boolean: :vertical_boolean
  }
end

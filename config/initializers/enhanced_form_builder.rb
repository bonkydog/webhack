ActionView::Base.default_form_builder = EnhancedFormBuilder::FormBuilder
EnhancedFormBuilder::FormBuilder.default_options[:field_wrapper] = "div"

library frp_production;

import 'dart:html';
import 'sing_up_interaction.dart';

class DomSignUpForm implements SignUpForm {
  Element form;
  DomSignUpForm(this.form);

  get loginFieldValues         => _fieldValues("input[name=login]");
  get passwordFieldValues      => _fieldValues("input[name=password]");
  get confirmationFieldValues  => _fieldValues("input[name=confirmation]");
  toggleButton(enabled)        => form.query("input[type=button]").disabled = !enabled;

  _fieldValues(selector) => form.query(selector).onKeyUp.map((_) => _.target.value);
}

main(){
  singUpInteraction(new DomSignUpForm(query("form")));
}
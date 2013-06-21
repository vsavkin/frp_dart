library core;

import 'dart:async';
import 'package:frp/frp.dart' as _;

bool isPresent(String _) => _.trim().isNotEmpty;

abstract class SignUpForm {
  Stream<String> get loginFieldValues;
  Stream<String> get passwordFieldValues;
  Stream<String> get confirmationFieldValues;
  void toggleButton(bool enabled);
}

signUpInteraction(SignUpForm form){
  var password = _.fromStream("", form.passwordFieldValues);
  var passwordPresent = password.derive(isPresent);

  var confirmation = _.fromStream("", form.confirmationFieldValues);
  var passwordConfirmed = _.same([password, confirmation]);

  var login = _.fromStream("", form.loginFieldValues);
  var loginPresent = login.derive(isPresent);

  var validForm = _.and([loginPresent, passwordPresent, passwordConfirmed]);

  validForm.onChange(form.toggleButton);
}

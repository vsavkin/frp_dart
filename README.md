# Functional Reactive Programming in Dart

Functional reactive programming is a paradigm for modeling interactions in a reactive style. It enables rich composition and allows the testability of complex interactions. Sean Kirby and I put together a small library prototype (which is available at: [https://github.com/vsavkin/frp_dart](https://github.com/vsavkin/frp_dart)) to show how this paradigm can be used in Dart. 


## What is Functional Reactive Programming?

As I have said it is a programming paradigm that is built on top of the following concepts:

1. The concept of streams, which model sequences of discrete events.
2. The concept of properties, which model continuous values.

An example of a stream would be all keyups triggered on some input element. The input element's text can be modeled as a property.


## Adding Property

Since the Dart SDK gives us only one of the two basic FRP abstractions - streams, we had to implement the property ourselves.

		abstract class Property {
		  //the current value of the property at any given moment in time
		  get value;

		  //the stream you can subscribe to to be notified when the property changes
		  Stream changes;

		  //a shortcut to attach a listener to the changes stream
		  void onChange(Function listener);

		  //broadcasts the current values to all the listeners
		  void notify();

		  //creates a derived property
		  Property derive(Function mapper);
		}


## Creating Properties

A property can be created using one of the following ways:

1. Using a constant

		var propertyThatIsAlways10 = fromConst(10)

2. Using an initial value and a stream

		targetValue(_) => _.target.value;
		var login = fromStream("", loginField.onKeyUp.map(targetValue));

3. By deriving a property

		bool isPresent(String _) => _.trim().isNotEmpty;
		var loginPresent = login.derive(isPresent);

4. Using a function

		var coin = new ComputedProperty(() => new Random().nextInt(1));


## Combining Properties

What really makes FRP interesting is that properties can be composed of other properties. One example would be joining a bunch of them together. 

		var password = fromStream("", passwordField.onKeyUp.map(targetValue));
		var passwordConfirmation = fromStream("", passwordConfirmationField.onKeyUp.map(targetValue));

		var tuples = join([password, passwordConfirmation]);

At the beginning, the value of the tuples property is: `["", ""]`. If I type 'a' into the password field, the value will change to `["a", ""]`. Similarly, after entering 'b' into the confirmation field, the value will become `["a", "b"]`.

There is a bunch of combinators that will be used in pretty much any interaction. One of them is `and`.

		var loginPresent = ...;
		var passwordPresent = ...;
		var bothFieldsPresent = and([loginPresent, passwordPresent]);


## Example

Now, having gone through the basics of functional reactive programming, let’s see how we can it for modeling a simple interaction.

Suppose we have a sing up form.

SCREENSHOT

We would like to enable the button when the login field is present, the password field is present, and the password and confirmation fields match. 

First of all, let’s define the form's interface.
		
		abstract class SignUpForm {
		  Stream<String> get loginFieldValues;
		  Stream<String> get passwordFieldValues;
		  Stream<String> get confirmationFieldValues;
		  void toggleButton(bool enabled);
		}

This separates the DOM specific code from the interaction itself, which allows the replacement of the real form with a test double when needed.

Second, import the frp library.

		import 'package:frp/frp.dart' as _;

Next, implement the interaction itself.

		singUpInteraction(SignUpForm form){
		  var password = _.fromStream("", form.passwordFieldValues);
		  var passwordPresent = password.derive(isPresent);

		  var confirmation = _.fromStream("", form.confirmationFieldValues);
		  var passwordConfirmed = _.same([password, confirmation]);

		  var login = _.fromStream("", form.loginFieldValues);
		  var loginPresent = login.derive(isPresent);

		  var validForm = _.and([loginPresent, passwordPresent, passwordConfirmed]);

		  validForm.onChange(form.toggleButton);
		}

Finally, we need to instantiate the form and call the interaction.

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


## Wrapping Up

* Functional reactive programming can be used for expressing complex UI interactions in a declarative way.

* Properties can be created from streams and derived from other properties. In addition, they can be combined using such combinators as `join`.

* The library presented in this article is just a prototype, but since the Dart SDK provides streams, building a production-ready library similar to Bacon.JS should not be very difficult.
library frp;

import 'dart:async';

abstract class Property {
  get value;
  Stream changes;

  StreamController _controller;

  Property() {
    _controller = new StreamController();
    changes = _controller.stream.asBroadcastStream();
  }

  void onChange(listener(T)){changes.listen(listener);}

  void notify() => _controller.add(value);

  Property derive(mapper(T)) => new ComputedProperty(() => mapper(value), this.changes);
}

class StreamProperty extends Property {
  var _lastValue;
  get value => _lastValue;

  StreamProperty(this._lastValue, Stream changes) {
    changes.listen(_updateValue);
  }

  _updateValue(newValue){
    if (_lastValue != newValue) {
      _lastValue = newValue;
      notify();
    }
  }
}

class ComputedProperty extends Property {
  Function _valueProvider;
  var _lastValue;

  ComputedProperty(this._valueProvider, [Stream changeSignals]) {
    _lastValue = _valueProvider();

    if(changeSignals != null){
      changeSignals.listen((_) => _updateValue());
    }
  }

  _updateValue(){
    if (_lastValue != value) {
      _lastValue = value;
      notify();
    }
  }

  get value => _valueProvider();
}

Property fromStream(initialValue, Stream stream) => new StreamProperty(initialValue, stream);

Property fromConst(value) => new ComputedProperty(() => value);

Property join(List<Property> props) {
  var joinedValue = () => props.map((_) => _.value).toList();

  var joinController = new StreamController();
  props.forEach((prop) => prop.changes.listen(joinController.add));

  return new ComputedProperty(joinedValue, joinController.stream);
}

Property same(List<Property> props){
  var allItemsEqual = (_) => _.toSet().length == 1;
  return join(props).derive(allItemsEqual);
}

Property and(List<Property> props) {
  var reduceAnd = ((_) => _.reduce((a, b) => a && b));
  return join(props).derive(reduceAnd);
}
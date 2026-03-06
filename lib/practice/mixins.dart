import 'package:flutter/widgets.dart';

mixin CanFly {
  void fly() => debugPrint('$runtimeType is flying!');
}

mixin CanSwim {
  void swim()=>  debugPrint('$runtimeType is swimming!');
}


class Animal {
  String get name => 'Animal';
  void breathe()=> debugPrint('breathing');
}

//Use with keyword
class Duck extends Animal with CanFly, CanSwim {}
class Airplane with CanFly {}

//Mixin with restricts which class use it
mixin Domestic on Animal {
  void greetOwner(){
    debugPrint('$name says hello!');
  }
}

class Dog extends Animal with Domestic {}

// class Car with Domestic {} ← ERROR — Car doesn't extend Animal
//class Car with Domestic{}

mixin Validatable {
  bool validate();

  void submitIfValid(){
    if(validate()){
      debugPrint('submitting...');
      return;
    }
    debugPrint('Invalid!');
  }
}

class LoginForm with Validatable{
  final String email;
  LoginForm(this.email);

  @override
  bool validate() => email.contains('@');
}

void main() {
  Duck().fly();
  Duck().swim();

  Dog().greetOwner();
  Dog().breathe();
}
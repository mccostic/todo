//S - Single Responsibility
//BAD - does too many things

import 'package:flutter/cupertino.dart';

class UserManger{
  void saveUser(User user){}
  void sendEmail(User user){}
  void generateReport(User user){}
}


// GOOD - one responsibility each
class UserRepository{
  void saveUser(User user){}
}

class EmailService{
  void sendEmail(User user){}
}

class User{}



// O - Open/Closed
//Open for extension, closed for modification

class AreaCalculator{
  double calculate(dynamic shape){
    if(shape is Circle) return 3.14 * 10 * 100;
    if(shape is Rectangle) return 100 * 100;
    return -1;
    //Keep modifying ... which is not a good principle
  }
}

//Good - extend by adding new class
abstract class Shape{
  double get area;
}

class Circle extends Shape{
  final double radius;
  Circle(this.radius);

  @override
  double get area => 3.14 * radius * radius;
}

class Rectangle extends Shape{
  final double width,height;

  Rectangle({required this.width,required this.height});

  @override
  double get area => width * height;

}


// L - Liskov substitution
//Subclass should be replaceable for parent without breaking

//BAD - breaks parent contract
class Bird{
  void fly()=> debugPrint('flying');
}

class Penguin extends Bird{
  @override
  void fly() => throw Exception('Penguins cannot fly'); //breaks it!
}

// GOOD - restructure hierarchy
abstract class LBird{
  void eat();
}

abstract class FlyingBird extends LBird{
  void fly();
}

class Eagle extends FlyingBird{
  @override
  void eat() {
    debugPrint("Eagle eating");
  }

  @override
  void fly() {
    debugPrint("Eagle flying");
  }
}

class LPenguin extends LBird{

  @override
  void eat(){
    debugPrint("Penguin eating");
  }

  // no fly - does not need it
}


void main(){
  FlyingBird b =  Eagle();
  b.eat();
  b.fly();
}

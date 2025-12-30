import 'dart:io';

void main()
{
  var listForTesting = [1,2,3,4,5,6,7,8,9];

  var mapForTesting = {
    "One" : 1,
    "Two" : "SecondValue",
   };

  var classObject = ehtasham();

  classObject.printing();
}

class ehtasham{
  var Name = "Ehtasham";

  void printing(){
    stdout.write("my name is = $Name");
  }
}

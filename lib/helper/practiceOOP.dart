void main() {
  Dog<String> d = new Dog('KATE', 12, 'Mr. jack', nickname: 'Oyesd');
  d.age = 75;
  Dog<int> d1 = new Dog('Jamin', 12, 'Mr. jack', nickname: 776);
  print(d.gender);
//  print(d.count);
  Dog.getCount();
}

class Dog<T>{
  static int count = 0;

  String name;
  int secretAge;
  String _belong;
  DogGender gender;

  T nickname;

  Dog(
      this.name,
      this.secretAge,
      this._belong,
      {
        this.gender = DogGender.male,
        this.nickname
      }
      ) {
    _addOneDog();
  }


  int get age {
    return secretAge;
  }

  set age(int newAge) {
    secretAge = newAge;
  }

  void _addOneDog() {
    count += 1;
  }

  static getCount() {
    print(count);
  }
}

enum DogGender {
  male,
  female
}

void foo() {} // A top-level function

class A {
  static void bar() {} // A static method
  void baz() {} // An instance method
}


void main() {
  print(CalcTool.getName('Master'));

  var foo = [1,2,3];
  String a = '1.1';
  print(double.parse(a));

  String aa = '单引号：'
  '也是可以拼接'
  "部分文字的";

  String bb = """双引号：
  多行汉字的拼接, 会导致换行格式被保存
  类似python
  """;

  print(aa);
  print(bb);

  List ooo = ['1', 1, 'aaa'];

  int c1 = 12;
  int k = 12 + c1++;

  print('后++在运行中，参与计算的还是之前的值：${k}');
  print('后++在运行完后，自身的值才会增加：${c1}');

  print('用is测试变量类型: ${1 is int}');

  var a1 = 13;
  var b2 = 17;
  b2 ??= a1;

  var kk;

  kk = a1 ?? b2;

  print(kk);

  Dog pp = new Dog('Big Huang');
  pp.cry()..eat()..digest();

  var g;
  g?.age = 18;

  print(pp.runtimeType);

  Student sd = new Student('Chou', 45);
  print(sd.age);

  Clssd cd = new Clssd(78);
  print(cd);
//  cd.k = 77889;
  print(cd.k);

  Shop fruitShop = new Shop('fruitShop');
  Shop meatShop = new Shop('meatShop');

  print(Shop._myShops);

  final Map<String, int> cans = {};
  cans['kaka'] = 14000;
  cans['cluo'] = 23;

  final int a12 = 12;
  Bk v = new Bk('kkk');
  print('${v.age}');
  v.haha();
}

// omit：忽略
// shorthand: 简便的
// shortcut 捷径
// alias：缩写
// Lexical 词汇的
// curly braces: 花括号
// colon: 冒号
// semicolon: 分号
// add subtract multiply(time) divide




// =====【 一 】====
// -1, 静态类本身不需要被实例化，可以作为configuration使用
// 0, Assert（断言表达式）
// 1, const 有啥用 （abundant(丰富的) - redundant(多余的)）
// 2, 类型转换，数字 <--> 字符串，带精度
// 3, 长字符串的拼接和[分开写法， 类似"""str"""]
// 4, 字符串的raw写法
// 5, List 泛型（generic type）写法 omit 遗漏
// 6. 闭包
// 7. 只有null, 没有undefined
// 8. ??  ^=  is!
//    【b ??= a】当b为null时，将a赋值给b,否则保持b的原值。类似值反预置值。
//    【var k = b ?? a】当b为null时，把a赋值给k; 类似JavaScript中的 || 操作
//    【exp1 ?? exp2】...
// 9. 链式操作（..method）, 前提方法必须是返回自己
// 10. 各种场景中的const



/**
 * =====【 二 】====
 * 流程控制：略
 */




/**
 * =====【 三 】====
 * 错误捕捉
 * 1. try-catch 中的精准捕捉
 *  try {
 *    ...do somthing
 *  } on SomeException catch(e) {
 *    ...handle special Error
 *  } catch(e,s) {
 *    ...handle rest Error
 *  } finally {
 *    ...whenever whatever however
 *    ...i will run
 *  }
 *
 *  2. 常见错误均继承自Exception
 *   OutOfLlamasException
 *
 *  3. 自定义错误的写法
 */



/// =====【 四 】====
/// Class 类!!!
/// 1. Aobject?.attr = 'something';   ☆☆ ?.如果Aobject 非空，则为attr属性赋值；
///
/// 2. 多个constructors;
///   ☆☆ 比如factory Product.fromJson, 返回一个调用基础constructor后的实例；
///   ☆☆ 比如 Product.standard (int a) { this.a = a }, 待名字的构造函数；
///
/// 3. Aobject.runtimeType;   ☆☆ 获取class类型, 注意个is的区别
///
/// 4. 继承中的super, 类似es6。
///   ☆☆ super当方法是为父类的标准构造函数，
///   ☆☆ super当对象用时，为父类本身，可以调用内部所有方法。
///
/// 5. 子类中，初始化方法默认会调用父类的无参构造函数，
///   ☆☆ 为了防止错误，可以增加：super(params) 防止错误，并在紧接的{}中，增加自己的构造行为
///   ☆☆ 类中，【类名.xxx 都是构造函数】。利用构造函数重定向，如下
///       Point.createSpecialObj(string str): this(str, otherParams);
///       :this 即转调用基础构造函数
///
/// 6. 理解factory 构造函数，本质是构造重定向，真正构造函数可能是private的；
///
/// 7. 怎么理解继承：
///   ☆☆ 根本不需要理解继承是怎么样的，只关心构造函数用的是谁的！
///   ☆☆ 一切都能继承
///
/// 8. getter setter 注意写法，比如是lamba写法
///
/// 9. 抽象方法只存在抽象类中，没有curly braces {};


class Clssd {
  final int k;
  Clssd(this.k);
}

class Al {
  String a;
  int _age = 77;

  int get age () { return _age;}

  Al(this.a);
  haha () {
    print('经');
  }
}

class Bk extends Al {
  Bk(String b):super(b);
}

class Shop {
  String shopType;

  static final Map<String, Shop> _myShops = <String, Shop>{};


  factory Shop(String st) {
    if (_myShops.containsKey(st)) {
      return _myShops[st];
    } else {
      Shop newShop = Shop._open(st);
      _myShops[st] = newShop;

      return newShop;
    }
  }


  Shop._open(this.shopType);
}

class Dog {
  String name;
  int age = 999;

  Dog(this.name);

  Dog cry() {
    print('MY NAME IS === ${this.name}');
    return this;
  }

  Dog eat() {
    print('i am eating');
    return this;
  }

  Dog digest() {
    print('i am digesting');
    return this;
  }
}

class Person {
  String firstName;

  haha(){
    print('jjdhhjsd');
  }

  Person(String fn) {
    print('no argu constrtor');
    this.firstName = fn;
  }
}

class Student extends Person {
  String firstName;
  int age;
  Student(String fn, int age): super(fn) {
    this.age = age;
  }
}


class CalcTool
{
  static String getName(String prefix) {
    return '${prefix}-baby';
  }

  static int height = 131;
}

abstract class Animal {
  String name;
  int age;

//  Animal(this.name, this.age);

  void cry();
}

class Cat extends Animal {
//  String name;
//  int age;
//  Cat(this.name, this.age):super();
//
  @override
  void cry() {
    print('miaomiao');
  }
}
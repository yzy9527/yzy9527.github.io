---
title: JavaScript之Object.defineProperty函数相关知识点
date: 2019-7-21 12:20:24
categories: JavaScript
---

 > Object.defineProperty(obj, prop, desc)
    
  - obj 需要定义属性的当前对象
  - prop 当前需要定义的属性名
  -  desc 属性描述符
 
对象里目前存在的属性描述符有两种主要形式：`数据描述符`和`存取描述符`

 - `数据描述符`是一个具有值的属性，该值可以是可写的，也可以是不可写的。  
 - `存取描述符`是由 getter 函数和 setter 函数所描述的属性。

> *一个描述符只能是这两者其中之一；不能同时是两者*

 <!--more-->
 1. `数据描述符`具有以下可选键值:  
 - **`value`**：该属性对应的值。可以是任何有效的JavaScript值（数值，对象，函数等）。
**默认为** `undefined`。
 - **`writable`**：当且仅当该属性的writable键值为true时，属性的值，也就是上面的value，才能被赋值运算符改变。
**默认为** `false`不可修改。
 2. `存取描述符`具有以下可选键值：
 - **`get`**：属性的 getter 函数，如果没有 getter，则为 undefined。当访问该属性时，会调用此函数。执行时不传入任何参数，但是会传入 this 对象（由于继承关系，这里的this并不一定是定义该属性的对象）。该函数的返回值会被用作属性的值。
**默认为** `undefined`。
 - **`set`**：属性的 setter 函数，如果没有 setter，则为 undefined。当属性值被修改时，会调用此函数。该方法接受一个参数（也就是被赋予的新值），会传入赋值时的 this 对象。
**默认为** `undefined`。

`共享键值`（默认值是指在使用 Object.defineProperty() 定义属性时的默认值）：
 - **`configurable`**：当且仅当该属性的 configurable 键值为 true 时，该属性的描述符才能够被改变，同时该属性也能从对应的对象上被删除。
**默认为** `false`。
 - **`enumerable`**：当且仅当该属性的 enumerable 键值为 true 时，该属性才会出现在对象的枚举属性中。
**默认为** `false`。
 
**描述符默认值汇总**

|  属性名   | 默认值  |
|  :-: |:-: |
| value  | undefined |
| writable  | false |
| get  | undefined |
| set  | undefined |
| configurable  | false |
| enumerable  | false |

所以，属性描述符只能有两种形式：
```JavaScript
     Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: false, // 是否可以改变
        configurable: false,//是否可配置
        enumerable: true //是否出现在对象的枚举属性中
    })
```

或者

```JavaScript
    let userName = '胖虎'
    Object.defineProperty(Person, 'name', {
        get() {
            return userName
        },
        set(v) {
            userName = v
        },
        enumerable: false,//是否可配置
        writable: false, // 是否可以改变
    })
```

### enumerable

```JavaScript
    let Person = {
        age: 12,
    }
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: false, // 不可以改变
        configurable: false,//不可删除
        enumerable: false //不出现在对象的枚举属性中
    })
    Person.name = '大雄' //writable：false 修改失败
    delete Person.name //configurable：false 删除失败，严格模式会报错
    for (let key in Person) {
        console.log(key) //age
    }
    console.log(Person, Person.name) //{ age: 12 } 胖虎
```
当我们将 `enumerable` 设置为`true`时，我们就可以在对象的属性中拿到`name`字段
```JavaScript    
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: false,
        configurable: false,
        enumerable: true 
    })
    for (let key in Person) {
        console.log(key) //age name
    }
    console.log(Person, Person.name) //{ age: 12, name: '胖虎' } 胖虎
```

### configurable

基本使用
```JavaScript
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: false, 
        configurable: true,//可配置
        enumerable: true
    })
    Person.name = '大雄'
    delete Person.name //删除成功
    console.log(Person, Person.name) //{ age: 12 } undefined
```
<br>

```JavaScript
    let Person = {
        age: 12,
    }
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: false,
        configurable: true,
        enumerable: true
    })
    //Person.name = '大雄' //writable: false；{ age: 12, name: '胖虎' } 胖虎
    Object.defineProperty(Person, 'name', {
        value:'大雄',
        writable: false,
    })
    console.log(Person, Person.name) //{ age: 12, name: '大雄' } 大雄
```
上述例子中  

 - 由于`configurable: true`,所以重新利用`Object.defineProperty`定义了`Person`的`name`字段后，成功的修改了`name`的值；如果将可配置项`configurable`设置为`true`，那么在利用这种方法修改`name`值就会报错
 - 若果`configurable: true`，那么可自由设置`writable`；反之，只能将`writable`由`true`转为`false`

### writable
 将`writable`设置为`true`时，name属性就可以改变了
```JavaScript
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: true, // 是否可以改变
        configurable: false,//是否可配置
        enumerable: true //是否出现在对象的枚举属性中
    })
    Person.name = '大雄'
    console.log(Person, Person.name) //{ age: 12, name: '大雄' } 大雄
```
### getter和setter

获取值使用get方法；设置一个属性值时使用set方法
```JavaScript
    function userList() {
        let userName = null;
        let lists = [];
        Object.defineProperty(this, 'userName', {
            get() {
                return userName;
            },
            set(value) { //value为接受的参数
                userName = value;
                lists.push({name: userName});
            }
        });
    
        this.getLists = function () {
            return lists;
        };
    }
    
    var p1 = new userList();
    console.log(p1.userName)//null
    
    p1.userName = '胖虎';
    console.log(p1.userName)//胖虎
    
    p1.userName = '大雄';
    console.log(p1.userName) //大雄
    
    let res = p1.getLists();
    console.log(res)// [ { name: '胖虎' }, { name: '大雄' } ]
    
    var p2 = new userList();
    let res2 = p2.getLists();
    console.log(res2)// []
```

### 禁止扩展
如果你想禁止一个对象添加新属性并且保留已有属性，就可以使用***Object.preventExtensions(...)***
```JavaScript
    let Person = {
        age: 12,
    }
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: true,
        configurable: true,
        enumerable: true
    })
    Object.preventExtensions(Person)
    Person.grade = '一年级' //不可添加
    Person.name = '大雄' //可修改
    console.log(Person) //{ age: 12, name: '大雄' }
```
### 密封
***Object.seal()***会创建一个密封的对象，这个方法实际上会在一个现有对象上调用object.preventExtensions(...)并把所有现有属性标记为configurable:false。
```JavaScript
    let Person = {
        age: 12,
    }
    Object.defineProperty(Person, 'name', {
        value: '胖虎',
        writable: true,
        configurable: true,
        enumerable: true
    })
    Object.seal(Person)
    delete Person.name
    console.log(Person) //{ age: 12, name: '胖虎' }
 ```

### 冻结

 - Object.freeze()会创建一个冻结对象，这个方法实际上会在一个现有对象上调用Object.seal(),并把所有现有属性标记为writable: false,这样就无法修改它们的值。
 - 或则说 冻结对象是指那些不能添加新的属性，不能修改已有属性的值，不能删除已有属性，以及不能修改已有属性的可枚举性、可配置性、可写性的对象。也就是说，这个对象永远是不可变的；
```JavaScript
let Person = {
    age: 12,
}
Object.defineProperty(Person, 'name', {
    value: '胖虎',
    writable: true,
    configurable: true,
    enumerable: true
})
Object.freeze(Person)
Person.name = '大雄'
delete Person.name
console.log(Person) //{ age: 12, name: '胖虎' }
```
title: 关于background-clip属性
date: 2019-6-12 9:26:33
categories: CSS
---

background-clip属性的作用就是指定元素背景所在的区域

语法：

background-clip: border-box|padding-box|content-box;
```html
    <div class="box">
```
```css
	.box {
		display: inline-block;
		width: 100px;
		height: 100px;
		padding: 10px;
		border: 10px solid red;
		background-color: currentColor;
		background-clip: border-box;
	}
```
border-box是默认值，表示元素的背景从border区域（包括border）以内开始保留
<!--more-->
![border-box](http://qiniu.xiaoxilao.com/b_20190202_1.png "border-box") 

background-clip:padding-box;  
padding-box表示元素的背景从padding区域(包括padding)以内开始保留。

![padding-box](http://qiniu.xiaoxilao.com/b_20190202_2.png "padding-box")   

background-clip:content-box;  
content-box表示元素的背景从内容区域以内开始保留。  

![content-box](http://qiniu.xiaoxilao.com/b_20190202_3.png "content-box") 

实例：创建一些图标按钮  
```html
    <div class="box"> 
```
```css
    .box {
		display: inline-block;
		width: 100px;
		height: 100px;
		padding: 10px;
		border: 10px solid;
		border-radius: 50%;
		background-color: currentColor;
		background-clip: content-box;
	}
```
![按钮](http://qiniu.xiaoxilao.com/b_20190202_4.png "按钮")  
```css
	.box {
		display: inline-block;
		width: 140px;
		height: 10px;
		padding: 35px 0;
		border-top:10px solid;
		border-bottom:10px solid;
		background-color: currentColor;
		background-clip: content-box;
	}
```
![按钮](http://qiniu.xiaoxilao.com/b_20190202_5.png "按钮")  


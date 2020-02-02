title: display:inline-block流动布局
date: 2019-9-12 9:26:33
categories: css
---
在使用 float:left  列表布局时当有两行时，第一行中间高度比该行其他的div高,第二行会被第一行最高的块给挡住,如下图

![清除浮动前](http://qiniu.xiaoxilao.com/b_20200202_134612.png "清除浮动前") 

此时，父级元素坍塌，清除浮动可用伪元素:after或父元素使用display:inline-block。 
<!--more-->

![清除浮动前](http://qiniu.xiaoxilao.com/b_20200202_134613.png "清除浮动后")

流动布局
E6/IE7浏览器同时满足上面的inline标签化以及结束标签连续化，再加上先前现代浏览器下的首尾标签留空，IE6/IE7浏览器也就能够实现列表元素的两端对齐啦！  
like this

	<span>
		<a href="#">
		    <img src="test.jpg" />
		</a>
		<span>描述</span></span>
		

#### 1.两端对齐  
    列表（或文字）要两端对齐的前提就是内容必须超过一行，所以，要解决最后一行元素无法两端对齐的文字其实很简单，就是在列表（或文字段）的最后创建一个高度为0的宽度100%的透明的inline-block的标签层就可以了

	 <ul>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li>
    <li><span class="list"><img src="./x.jpg" width="120px"/>
      属性规定</span></li><span class="justify_fix"></span>
    </ul>
    
    ul{text-align:justify;}
	li{display:inline-block;}
	.justify_fix{
		    display:inline-block;
		    width:100%;
		    height:0; 
		    overflow:hidden;
		    
	}
对上述插入额外的标签可用伪元素代替,width: 100%;旨在充满整行，这里高度设为1方便查看效果

	ul:after{
	  content: "";
	  width: 100%;
	  height: 1px;
	  background: red;
	  display: inline-block;
	
	}
	
![两端对齐](http://qiniu.xiaoxilao.com/b_20200202_134614.png "两端对齐")

#### 2.左对齐  
很多时候，我们希望列表的最后一行是左对齐排列的，而不是两端对齐，这时候怎么办呢？原理与上面的两端对齐一致。就是复制几个列表元素的外层标签，等宽，但高度为0，里面就是个&nbsp;(不可缺)，复制的个数一般就是每行元素的列表个数啦，这样肯定可以保证最后一行元素一定是左对齐排列的啦！,height:0px

	<span class="list left_fix"> </span>
	.left_fix{ 
		padding:0; 
		overflow:hidden;
		height: 1px;
		background: red;
	}
	
![左对齐](http://qiniu.xiaoxilao.com/b_20200202_134614.png "左对齐")

使用inline-block流动布局的好处就是随着窗口的变化，里面的内容也会跟着自动变化

<!--more-->
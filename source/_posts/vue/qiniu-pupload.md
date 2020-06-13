---
title: Vue分片上传七牛云
date: 2020-5-12 21:18:18
categories:
 - vue
---

最近项目碰到前端视频等大文件上传，之前项目都是后台通过七牛进行分片处理上传；现在对前端分片上传做个小笔记吧。

本实例采用vue + elementui + [qiniujs](https://github.com/qiniu/js-sdk/tree/1.x "七牛") + pupload实现视频等大文件的上传，实现断点续传、暂停、继续，以及分片上传

展示效果](![](https://qiniu.xiaoxilao.com/b_flex_auto.gif)

<!--more-->
### HTML

展示大小、速度、已上传、进度条；暂停，继续可根据需要添加

```html
  <div id="video_container">
    <div>
      <div v-if="showInfo" class="upload_info">
        共{{ fileSize }}MB | 已上传{{ fileLoaded }} | {{ fileSpeed }}/s
        <el-progress :percentage="filePercent"/>
      </div>
    </div>
  </div>
```
### js

```js

//引入qiniu.min.js
require('qiniu-js/dist/qiniu.min.js')
//获取七牛token
import { getQiNiuAccessToken } from '@/api/base'

export default {
  props: {
    browse_button: {
      type: String,
      required: true
    },
    //文件上传大小限制
    maxSize: {
      type: String,
      default: '1mb'
    },
    //可否多选
    multi_selection: {
      type: Boolean,
      default: false
    },
    //是否自动上传
    auto_start: {
      type: Boolean,
      default: true
    }
  },
  data() {
    return {
      //七牛数据
      domain: '',
      uptoken: '',
      
      fileSize: 0, 
      fileLoaded: 0,
      fileSpeed: 0,
      filePercent: 0,
      fileName: '',
      uploader: null,
      showInfo: false //是否显示上传数据
    }
  },
  mounted() {
    this.getToken().then(res => {
      this.start()
    })
  },
  methods: {
    start() {
      const _this = this
      this.uploader = Qiniu.uploader({
        multi_selection: _this.multi_selection,
        runtimes: 'html5,flash,html4', // 上传模式，依次退化
        browse_button: _this.browse_button, // 上传选择的点选按钮，必需
        uptoken: _this.uptoken, // uptoken是上传凭证，由其他程序生成
        get_new_uptoken: false, // 设置上传文件的时候是否每次都重新获取新的uptoken
        unique_names: false, // 默认false，key为文件名。若开启该选项，JS-SDK会为每个文件自动生成key（文件名）
        save_key: false, // 默认false。若在服务端生成uptoken的上传策略中指定了sava_key，则开启，SDK在前端将不对key进行任何处理
        domain: _this.domain,
        container: 'video_container',
        max_file_size: _this.maxSize, // 最大文件体积限制
        dragdrop: true, // 开启可拖曳上传
        drop_element: 'video_container', // 拖曳上传区域元素的ID，拖曳文件或文件夹后可触发上传
        chunk_size: '4mb', // 分块上传时，每块的体积  html5 模式大于 4M 时可分块上传，小于4M时直传
        max_retries: 3, // 上传失败最大重试次数
        auto_start: _this.auto_start, // 选择文件后自动上传，若关闭需要自己绑定事件触发上传
        filters: {
          mime_types: [{ title: 'files', extensions: 'mp4' }]
        },
        init: {
          'FilesAdded': function(up, files) {
            console.log('files', files)
            plupload.each(files, function(file) {
              // 文件添加进队列后，处理相关的事情
              console.log('FilesAdded')
              _this.fileSize = _this.toDecimal(file.size)
            })
          },
          'BeforeUpload': function(up, file) {
            // 每个文件上传前，处理相关的事情
            console.log('BeforeUpload')
            _this.showInfo = true
            _this.$emit('beforeUpload', true)
          },
          'ChunkUploaded': function(up, file, info) {
            console.log('ChunkUploaded')
          },
          'UploadProgress': function(up, file) {
            // 每个文件上传时，处理相关的事情
            // console.log('_this.filePause =')
            // console.log(_this.filePause)
            console.log('UploadProgress')
            _this.filePercent = parseInt(file.percent)
            _this.fileLoaded = plupload.formatSize(file.loaded).toUpperCase()
            _this.fileSpeed = plupload.formatSize(file.speed).toUpperCase()
            console.log('filePercent', _this.filePercent)
          },
          'FileUploaded': function(up, file, info) {
            console.log('FileUploaded')
            const domain = up.getOption('domain')
            const res = JSON.parse(info.response)
            const sourceLink = domain + res.key
            console.log(sourceLink)
            //返回文件名
            _this.$emit('fileName', file.name)
            //返回url
            _this.$emit('onSuccess', sourceLink)
          },
          'Error': function(up, err, errTip) {
            // 上传出错时，处理相关的事情
            console.log('Error =')
            console.log(err)
            console.log('errTip =')
            console.log(errTip)
            _this.$message({
              message: errTip,
              type: 'danger'
            })
          },
          'UploadComplete': function() {
            // 队列文件处理完毕后，处理相关的事情
            console.log('UploadComplete')
          }

        }
      })
    },
    toDecimal(size) {
      size = size / 1024 / 1024
      var f = parseFloat(size)
      if (isNaN(f)) {
        return
      }
      f = Math.round(size * 10) / 10
      var s = f.toString()
      var rs = s.indexOf('.')
      if (rs < 0) {
        rs = s.length
        s += '.'
      }
      while (s.length <= rs + 1) {
        s += '0'
      }
      return s
    },
    pauseUpload() {
      console.log('pauseUpload')
      this.uploader.stop()
    },
    continueUpload() {
      console.log('continueUpload')
      this.uploader.start()
    },
    initUpload() {
      this.fileSize = 0
      this.fileLoaded = 0
      this.fileSpeed = 0
      this.filePercent = 0
      this.fileName = ''
      this.showInfo = false
      this.$emit('fileName', '')
    },
    //获取token
    getToken() {
      return new Promise(resolve => {
        getQiNiuAccessToken().then(res => {
          const { accessToken, domainUrl } = res.data
          this.domain = domainUrl
          this.uptoken = accessToken
          resolve()
        })
      })
    }
  }
}
```

chunk_size:'4mb'
当`chunk_size`设置小于4mb时 会报错
error":"block 0: unexpected block size

七牛qiniu.min.js 版本1.x ,在使用2.x版本时会提示找不到`uploader`

需在`index.html` 引入了 `plupload.js`
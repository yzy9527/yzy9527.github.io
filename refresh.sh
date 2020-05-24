cd /Users/mc/Documents/文件/blog/yzy9527.github.io 
echo "删除原来打包文件"
hexo clean
echo "正在生成新文件..."
hexo generate
echo "发布中..."
hexo deploy
echo "发布成功！！"
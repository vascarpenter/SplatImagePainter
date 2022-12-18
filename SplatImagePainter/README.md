#  SplatImagePainter

- splatdraw 用の bmpdata.h を生成するためのプログラム
  - 参考：https://androiphone.uvs.jp/?p=3884
  
- Openボタンを押して320x120 の画像(JPEGなど)を開く
  - 白黒であることを確認

- Save ボタンを押して bmpdata.h を保存
- bmpdata.h をテキストエディタで開き、Select All, Copyして Arduino IDEで開いた bmpdata.h を置き換える
- spladraw.ino をコンパイル、転送する

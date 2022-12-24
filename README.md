#  SplatImagePainter

- spladraw 用の bmpdata.h を生成するためのプログラム
  - 参考：https://androiphone.uvs.jp/?p=3884
  
- Openボタンを押して320x120 の画像(JPEGなど)を開く
  - 白黒であることを確認
  - 画像の加工は他の画像編集ソフトで行ってください(手抜き） 320 x 120ピクセルで PNGあるいはJPEGで保存してしてください

- Save ボタンを押して bmpdata.h を保存します
- bmpdata.h をテキストエディタで開き、Select All, Copyして Arduino IDEで開いた bmpdata.h を置き換えてください
- spladraw.ino をコンパイル、転送する
- 転送が終わったら splatoon3を開き、ポストに触れ、イラストを投稿するを選ぶ
  - 画像編集画面になったらおもむろに Arduino を接続
  - しばらくまっていると画像の点描が始まります

- 変更履歴
  - 0.2 menu item を使用可能とした app構造変更
  - 0.3 https://github.com/koher/swift-image を使用したところ非常にすっきり
  - 0.4 画像の誤差拡散読み込みを実装

# Nginxセットアップ用スクリプト

https://qiita.com/mocaberos/items/599bc16962bf474eac7b

### 確認済み動作環境
- Debian 10（Buster)

### インストール詳細
- nginx 1.21.1
- mruby拡張(最新版)
  - nginxでmrubyを使用するための拡張
- naxsi 1.3
  - オープンソースのWAF(ウェブアプリケーションファイアウォール)
- pagespeed 1.13.35.2-stable
  - Google製のWebサイト高速化拡張(ソースコード圧縮、jsの最適化、画像最適化、など)
- headers-more-nginx-module(最新版)
  - nginxでヘッダーの設定を柔軟にする拡張
- brotli(最新版)
  - Google製圧縮モジュール

### その他
ビルド途中のファイルはすべて`~/nginx`に配置され、セットアップが完了すると、不要なファイルは削除されます。

設定ファイルは`/etc/nginx`に配置されます。
